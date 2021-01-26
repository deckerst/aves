package deckers.thibault.aves.channel.streams

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class IntentStreamHandler : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    // e.g. when resuming the app after the activity got destroyed
    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {}

    fun notifyNewIntent(intentData: MutableMap<String, Any?>?) {
        eventSink?.success(intentData)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/intent"
    }
}