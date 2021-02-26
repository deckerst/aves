package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.PermissionManager.requestVolumeAccess
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

// starting activity to give access with the native dialog
// breaks the regular `MethodChannel` so we use a stream channel instead
class StorageAccessStreamHandler(private val activity: Activity, arguments: Any?) : EventChannel.StreamHandler {
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler
    private var path: String? = null

    init {
        if (arguments is Map<*, *>) {
            path = arguments["path"] as String?
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())

        if (path == null) {
            error("requestVolumeAccess-args", "failed because of missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            error("requestVolumeAccess-unsupported", "volume access is not allowed before Android Lollipop", null)
            return
        }

        requestVolumeAccess(activity, path!!, { success(true) }, { success(false) })
    }

    override fun onCancel(arguments: Any?) {}

    private fun success(result: Boolean) {
        handler.post {
            try {
                eventSink.success(result)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
        endOfStream()
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
        private val LOG_TAG = LogUtils.createTag(StorageAccessStreamHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/storageaccessstream"
    }
}