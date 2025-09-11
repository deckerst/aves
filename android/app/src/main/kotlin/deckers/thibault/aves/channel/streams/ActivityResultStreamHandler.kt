package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.net.toUri
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.PendingStorageAccessResultHandler
import deckers.thibault.aves.channel.calls.AppAdapterHandler
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.PermissionManager
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

// starting activity to get a result (e.g. storage access via native dialog)
// breaks the regular `MethodChannel` so we use a stream channel instead
class ActivityResultStreamHandler(private val activity: Activity, arguments: Any?) : BaseStreamHandler() {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var op: String? = null
    private lateinit var args: Map<*, *>

    init {
        if (arguments is Map<*, *>) {
            op = arguments["op"] as String?
            args = arguments
        }
    }

    override val logTag = LOG_TAG

    override fun onCall(args: Any?) {
        // do not automatically close stream when launching activity,
        // as it will be closed when getting that activity result
        val closeStream = false
        when (op) {
            "requestDirectoryAccess" -> ioScope.launch { safeSuspend(::requestDirectoryAccess, closeStream) }
            "requestMediaFileAccess" -> ioScope.launch { safe(::requestMediaFileAccess, closeStream) }
            "createFile" -> ioScope.launch { safeSuspend(::createFile, closeStream) }
            "openFile" -> ioScope.launch { safeSuspend(::openFile, closeStream) }
            "copyFile" -> ioScope.launch { safeSuspend(::copyFile, closeStream) }
            "edit" -> safe(::edit, closeStream)
            "pickCollectionFilters" -> safe(::pickCollectionFilters, closeStream)
            else -> endOfStream()
        }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        super.error(errorCode, errorMessage, errorDetails)
        endOfStream()
    }

    private suspend fun requestDirectoryAccess() {
        val path = args["path"] as String?
        if (path == null) {
            error("requestDirectoryAccess-args", "missing arguments", null)
            return
        }

        PermissionManager.requestDirectoryAccess(activity, ensureTrailingSeparator(path), {
            success(true)
            endOfStream()
        }, {
            success(false)
            endOfStream()
        })
    }

    private fun requestMediaFileAccess() {
        val uris = (args["uris"] as List<*>?)?.mapNotNull { if (it is String) it.toUri() else null }
        val mimeTypes = (args["mimeTypes"] as List<*>?)?.mapNotNull { it as? String }
        if (uris.isNullOrEmpty() || mimeTypes == null || mimeTypes.size != uris.size) {
            error("requestMediaFileAccess-args", "missing arguments", null)
            return
        }

        if (uris.any { !StorageUtils.isMediaStoreContentUri(it) }) {
            error("requestMediaFileAccess-nonmediastore", "request is only valid for Media Store content URIs, uris=$uris", null)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            error("requestMediaFileAccess-unsupported", "media file bulk access is not allowed before Android 11", null)
            return
        }

        try {
            val granted = PermissionManager.requestMediaFileAccess(activity, uris, mimeTypes)
            success(granted)
            endOfStream()
        } catch (e: Exception) {
            error("requestMediaFileAccess-request", "failed to request access to ${uris.size} uris=$uris", e.message)
        }
    }

    private suspend fun safeStartActivityForStorageAccessResult(intent: Intent, requestCode: Int, onGranted: (uri: Uri) -> Unit, onDenied: () -> Unit) {
        if (intent.resolveActivity(activity.packageManager) != null) {
            MainActivity.pendingStorageAccessResultHandlers[requestCode] = PendingStorageAccessResultHandler(null, onGranted, onDenied)
            if (!safeStartActivityForResult(intent, requestCode)) {
                MainActivity.notifyError("failed to start activity for intent=$intent extras=${intent.extras}")
                onDenied()
            }
        } else {
            MainActivity.notifyError("failed to resolve activity for intent=$intent extras=${intent.extras}")
            onDenied()
        }
    }

    private suspend fun createFile() {
        val name = args["name"] as String?
        val mimeType = args["mimeType"] as String?
        val bytes = args["bytes"] as ByteArray?
        if (name == null || mimeType == null || bytes == null) {
            error("createFile-args", "missing arguments", null)
            return
        }

        fun onGranted(uri: Uri) {
            ioScope.launch {
                try {
                    // truncate is necessary when overwriting a longer file
                    activity.contentResolver.openOutputStream(uri, "wt")?.use { output ->
                        output.write(bytes)
                    }
                    success(true)
                    endOfStream()
                } catch (e: Exception) {
                    error("createFile-write", "failed to write file at uri=$uri", e.message)
                }
            }
        }

        fun onDenied() {
            success(null)
            endOfStream()
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        safeStartActivityForStorageAccessResult(intent, MainActivity.CREATE_FILE_REQUEST, ::onGranted, ::onDenied)
    }

    private suspend fun openFile() {
        val mimeType = args["mimeType"] as String? // optional

        fun onGranted(uri: Uri) {
            ioScope.launch {
                try {
                    activity.contentResolver.openInputStream(uri)?.use(::streamBytes)
                    endOfStream()
                } catch (e: Exception) {
                    error("openFile-read", "failed to read file at uri=$uri", e.message)
                }
            }
        }

        fun onDenied() {
            success(ByteArray(0))
            endOfStream()
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            setTypeAndNormalize(mimeType ?: MimeTypes.ANY)
        }
        safeStartActivityForStorageAccessResult(intent, MainActivity.OPEN_FILE_REQUEST, ::onGranted, ::onDenied)
    }

    private suspend fun copyFile() {
        val name = args["name"] as String?
        val mimeType = args["mimeType"] as String?
        val sourceUri = (args["sourceUri"] as String?)?.toUri()
        if (name == null || mimeType == null || sourceUri == null) {
            error("copyFile-args", "missing arguments", null)
            return
        }

        fun onGranted(uri: Uri) {
            ioScope.launch {
                try {
                    StorageUtils.openInputStream(activity, sourceUri)?.use { input ->
                        // truncate is necessary when overwriting a longer file
                        activity.contentResolver.openOutputStream(uri, "wt")?.use { output ->
                            val buffer = ByteArray(BUFFER_SIZE)
                            var len: Int
                            while (input.read(buffer).also { len = it } != -1) {
                                output.write(buffer, 0, len)
                            }
                        }
                    }
                    success(true)
                    endOfStream()
                } catch (e: Exception) {
                    error("copyFile-write", "failed to copy file from sourceUri=$sourceUri to uri=$uri", e.message)
                }
            }
        }

        fun onDenied() {
            success(null)
            endOfStream()
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        safeStartActivityForStorageAccessResult(intent, MainActivity.CREATE_FILE_REQUEST, ::onGranted, ::onDenied)
    }

    private fun edit() {
        val uri = args["uri"] as String?
        val mimeType = args["mimeType"] as String? // optional
        if (uri == null) {
            error("edit-args", "missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_EDIT)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            .setDataAndType(AppAdapterHandler.getShareableUri(activity, uri.toUri()), mimeType)

        if (intent.resolveActivity(activity.packageManager) == null) {
            error("edit-resolve", "cannot resolve activity for this intent for uri=$uri mimeType=$mimeType", null)
            return
        }

        MainActivity.pendingEditIntentHandler = { fields ->
            success(fields)
            endOfStream()
        }
        if (!safeStartActivityForResult(intent, MainActivity.EDIT_REQUEST)) {
            error("edit-start", "cannot start activity for this intent for uri=$uri mimeType=$mimeType", null)
        }
    }

    private fun pickCollectionFilters() {
        val initialFilters = (args["initialFilters"] as? List<*>)?.mapNotNull { it as? String } ?: listOf()
        val intent = Intent(MainActivity.INTENT_ACTION_PICK_COLLECTION_FILTERS, null, activity, MainActivity::class.java)
            .putExtra(MainActivity.EXTRA_KEY_FILTERS_ARRAY, initialFilters.toTypedArray())
            .putExtra(MainActivity.EXTRA_KEY_FILTERS_STRING, initialFilters.joinToString(MainActivity.EXTRA_STRING_ARRAY_SEPARATOR))
        MainActivity.pendingCollectionFilterPickHandler = { filters ->
            success(filters)
            endOfStream()
        }
        activity.startActivityForResult(intent, MainActivity.PICK_COLLECTION_FILTERS_REQUEST)
    }

    private fun safeStartActivityForResult(intent: Intent, requestCode: Int): Boolean {
        return try {
            activity.startActivityForResult(intent, requestCode)
            true
        } catch (_: SecurityException) {
            if (intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION != 0) {
                // in some environments, providing the write flag yields a `SecurityException`:
                // "UID XXXX does not have permission to content://XXXX"
                // so we retry without it
                Log.i(LOG_TAG, "retry intent=$intent without FLAG_GRANT_WRITE_URI_PERMISSION")
                intent.flags = intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION.inv()
                safeStartActivityForResult(intent, requestCode)
            } else {
                false
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ActivityResultStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/activity_result_stream"
    }
}