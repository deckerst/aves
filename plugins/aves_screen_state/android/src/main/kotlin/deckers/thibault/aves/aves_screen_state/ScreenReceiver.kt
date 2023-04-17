package deckers.thibault.aves.aves_screen_state

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel.EventSink

class ScreenReceiver(private val eventSink: EventSink) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        eventSink.success(intent.action)
    }
}