package deckers.thibault.aves.channel.streams.platformtodart

import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel

class ErrorStreamHandler : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    // e.g. when resuming the app after the activity got destroyed
    private var eventSink: EventChannel.EventSink? = null
    private var handler: Handler? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

    fun notifyError(error: String) {
        handler?.post {
            try {
                eventSink?.success(error)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ErrorStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/error"
    }
}