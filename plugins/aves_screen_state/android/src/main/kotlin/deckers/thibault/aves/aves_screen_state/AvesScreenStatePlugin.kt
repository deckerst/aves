package deckers.thibault.aves.aves_screen_state

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class AvesScreenStatePlugin : FlutterPlugin, EventChannel.StreamHandler {
    private lateinit var eventChannel: EventChannel
    private var context: Context? = null
    private var screenReceiver: ScreenReceiver? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "deckers.thibault/aves_screen_state/events")
        context = flutterPluginBinding.applicationContext
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink) {
        screenReceiver = ScreenReceiver(events)

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON) // Turn on
            addAction(Intent.ACTION_SCREEN_OFF) // Turn off
            addAction(Intent.ACTION_USER_PRESENT) // Unlock
        }
        context!!.registerReceiver(screenReceiver, filter)
    }

    override fun onCancel(arguments: Any?) {
        context!!.unregisterReceiver(screenReceiver)
    }
}