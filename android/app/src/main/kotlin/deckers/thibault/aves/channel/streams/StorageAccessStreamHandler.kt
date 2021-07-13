package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.PendingResultHandler
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.PermissionManager
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.FileOutputStream

// starting activity to give access with the native dialog
// breaks the regular `MethodChannel` so we use a stream channel instead
class StorageAccessStreamHandler(private val activity: Activity, arguments: Any?) : EventChannel.StreamHandler {
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
            "requestVolumeAccess" -> requestVolumeAccess()
            "createFile" -> GlobalScope.launch(Dispatchers.IO) { createFile() }
            "openFile" -> GlobalScope.launch(Dispatchers.IO) { openFile() }
            "selectDirectory" -> GlobalScope.launch(Dispatchers.IO) { selectDirectory() }
            else -> endOfStream()
        }
    }

    private fun requestVolumeAccess() {
        val path = args["path"] as String?
        if (path == null) {
            error("requestVolumeAccess-args", "failed because of missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            error("requestVolumeAccess-unsupported", "volume access is not allowed before Android Lollipop", null)
            return
        }

        PermissionManager.requestVolumeAccess(activity, path, {
            success(true)
            endOfStream()
        }, {
            success(false)
            endOfStream()
        })
    }

    private fun createFile() {
        val name = args["name"] as String?
        val mimeType = args["mimeType"] as String?
        val bytes = args["bytes"] as ByteArray?
        if (name == null || mimeType == null || bytes == null) {
            error("createFile-args", "failed because of missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        MainActivity.pendingResultHandlers[MainActivity.CREATE_FILE_REQUEST] = PendingResultHandler(null, { uri ->
            try {
                activity.contentResolver.openOutputStream(uri)?.use { output ->
                    output as FileOutputStream
                    // truncate is necessary when overwriting a longer file
                    output.channel.truncate(0)
                    output.write(bytes)
                }
                success(true)
            } catch (e: Exception) {
                error("createFile-write", "failed to write file at uri=$uri", e.message)
            }
            endOfStream()
        }, {
            success(null)
            endOfStream()
        })
        activity.startActivityForResult(intent, MainActivity.CREATE_FILE_REQUEST)
    }


    private fun openFile() {
        val mimeType = args["mimeType"] as String?
        if (mimeType == null) {
            error("openFile-args", "failed because of missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
        }
        MainActivity.pendingResultHandlers[MainActivity.OPEN_FILE_REQUEST] = PendingResultHandler(null, { uri ->
            activity.contentResolver.openInputStream(uri)?.use { input ->
                val buffer = ByteArray(BUFFER_SIZE)
                var len: Int
                while (input.read(buffer).also { len = it } != -1) {
                    success(buffer.copyOf(len))
                }
                endOfStream()
            }
        }, {
            success(ByteArray(0))
            endOfStream()
        })
        activity.startActivityForResult(intent, MainActivity.OPEN_FILE_REQUEST)
    }

    private fun selectDirectory() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)

            MainActivity.pendingResultHandlers[MainActivity.SELECT_DIRECTORY_REQUEST] = PendingResultHandler(null, { uri ->
                success(StorageUtils.convertTreeUriToDirPath(activity, uri))
                endOfStream()
            }, {
                success(null)
                endOfStream()
            })
            activity.startActivityForResult(intent, MainActivity.SELECT_DIRECTORY_REQUEST)
        } else {
            success(null)
            endOfStream()
        }
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
        private val LOG_TAG = LogUtils.createTag<StorageAccessStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/storage_access_stream"
        private const val BUFFER_SIZE = 2 shl 17 // 256kB
    }
}