package deckers.thibault.aves.channel.streams

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class IntentStreamHandler : EventChannel.StreamHandler {
    private lateinit var eventSink: EventSink

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {}

    fun notifyNewIntent() {
        eventSink.success(true)
    }
}