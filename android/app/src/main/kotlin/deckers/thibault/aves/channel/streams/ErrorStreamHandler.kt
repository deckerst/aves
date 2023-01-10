package deckers.thibault.aves.channel.streams

import android.util.Log
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class ErrorStreamHandler : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    // e.g. when resuming the app after the activity got destroyed
    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

    suspend fun notifyError(error: String) {
        FlutterUtils.runOnUiThread {
            eventSink?.success(error)
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ErrorStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/error"
    }
}