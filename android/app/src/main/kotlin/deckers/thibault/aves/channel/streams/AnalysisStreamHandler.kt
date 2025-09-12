package deckers.thibault.aves.channel.streams

import android.util.Log
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel

class AnalysisStreamHandler : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    // e.g. when resuming the app after the activity got destroyed
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

    fun notifyCompletion() {
        eventSink?.success(true)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/analysis_events"
    }
}