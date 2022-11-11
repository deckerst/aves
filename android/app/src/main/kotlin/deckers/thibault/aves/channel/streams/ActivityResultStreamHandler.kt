package deckers.thibault.aves.channel.streams

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.PendingStorageAccessResultHandler
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

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            error("requestDirectoryAccess-unsupported", "directory access is not allowed before Android Lollipop", null)
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
        if (uris == null || uris.isEmpty() || mimeTypes == null || mimeTypes.size != uris.size) {
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
            error("requestMediaFileAccess-request", "failed to request access to uris=$uris", e.message)
        }
        endOfStream()
    }

    private fun createFile() {
        @SuppressLint("ObsoleteSdkInt")
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            error("createFile-sdk", "unsupported SDK version=${Build.VERSION.SDK_INT}", null)
            return
        }

        val name = args["name"] as String?
        val mimeType = args["mimeType"] as String?
        val bytes = args["bytes"] as ByteArray?
        if (name == null || mimeType == null || bytes == null) {
            error("createFile-args", "missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        MainActivity.pendingStorageAccessResultHandlers[MainActivity.CREATE_FILE_REQUEST] = PendingStorageAccessResultHandler(null, { uri ->
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
        }, {
            success(null)
            endOfStream()
        })
        activity.startActivityForResult(intent, MainActivity.CREATE_FILE_REQUEST)
    }


    private suspend fun openFile() {
        @SuppressLint("ObsoleteSdkInt")
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            error("openFile-sdk", "unsupported SDK version=${Build.VERSION.SDK_INT}", null)
            return
        }

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
        if (intent.resolveActivity(activity.packageManager) != null) {
            MainActivity.pendingStorageAccessResultHandlers[MainActivity.OPEN_FILE_REQUEST] = PendingStorageAccessResultHandler(null, ::onGranted, ::onDenied)
            activity.startActivityForResult(intent, MainActivity.OPEN_FILE_REQUEST)
        } else {
            MainActivity.notifyError("failed to resolve activity for intent=$intent extras=${intent.extras}")
            onDenied()
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

    override fun onCancel(arguments: Any?) {}

    private fun success(result: Any?) {
        handler.post {
            try {
                eventSink.success(result)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    @Suppress("SameParameterValue")
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
        private const val BUFFER_SIZE = 2 shl 17 // 256kB
    }
}