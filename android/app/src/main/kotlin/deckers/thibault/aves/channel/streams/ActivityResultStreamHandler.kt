package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.PendingStorageAccessResultHandler
import deckers.thibault.aves.channel.calls.AppAdapterHandler
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.PermissionManager
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

// starting activity to get a result (e.g. storage access via native dialog)
// breaks the regular `MethodChannel` so we use a stream channel instead
class ActivityResultStreamHandler(private val activity: Activity, arguments: Any?) : EventChannel.StreamHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler

    private var op: String? = null
    private lateinit var args: Map<*, *>

    init {
        if (arguments is Map<*, *>) {
            op = arguments["op"] as String?
            args = arguments
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())

        when (op) {
            "requestDirectoryAccess" -> ioScope.launch { requestDirectoryAccess() }
            "requestMediaFileAccess" -> ioScope.launch { requestMediaFileAccess() }
            "createFile" -> ioScope.launch { createFile() }
            "openFile" -> ioScope.launch { openFile() }
            "edit" -> edit()
            "pickCollectionFilters" -> pickCollectionFilters()
            else -> endOfStream()
        }
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
        val uris = (args["uris"] as List<*>?)?.mapNotNull { if (it is String) Uri.parse(it) else null }
        val mimeTypes = (args["mimeTypes"] as List<*>?)?.mapNotNull { if (it is String) it else null }
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
        } catch (e: Exception) {
            error("requestMediaFileAccess-request", "failed to request access to ${uris.size} uris=$uris", e.message)
        }
        endOfStream()
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
                } catch (e: Exception) {
                    error("createFile-write", "failed to write file at uri=$uri", e.message)
                }
                endOfStream()
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
                    activity.contentResolver.openInputStream(uri)?.use { input ->
                        val buffer = ByteArray(BUFFER_SIZE)
                        var len: Int
                        while (input.read(buffer).also { len = it } != -1) {
                            success(buffer.copyOf(len))
                        }
                    }
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "failed to open input stream for uri=$uri", e)
                } finally {
                    endOfStream()
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

    private fun edit() {
        val uri = args["uri"] as String?
        val mimeType = args["mimeType"] as String? // optional
        if (uri == null) {
            error("edit-args", "missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_EDIT)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            .setDataAndType(AppAdapterHandler.getShareableUri(activity, Uri.parse(uri)), mimeType)

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
        val initialFilters = (args["initialFilters"] as? List<*>)?.mapNotNull { if (it is String) it else null } ?: listOf()
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
        } catch (e: SecurityException) {
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

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

    private fun success(result: Any?) {
        handler.post {
            try {
                eventSink.success(result)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    private fun error(errorCode: String, errorMessage: String, errorDetails: Any?) {
        handler.post {
            try {
                eventSink.error(errorCode, errorMessage, errorDetails)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
        endOfStream()
    }

    private fun endOfStream() {
        handler.post {
            try {
                eventSink.endOfStream()
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ActivityResultStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/activity_result_stream"
        private const val BUFFER_SIZE = 1 shl 18 // 256kB
    }
}