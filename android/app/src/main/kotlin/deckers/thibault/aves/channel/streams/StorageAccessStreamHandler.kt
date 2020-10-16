package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.os.Handler
import android.os.Looper
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

        requestVolumeAccess(activity, path!!, { success(true) }, { success(false) })
    }

    override fun onCancel(arguments: Any?) {}

    private fun success(result: Boolean) {
        handler.post { eventSink.success(result) }
        endOfStream()
    }

    private fun endOfStream() {
        handler.post { eventSink.endOfStream() }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/storageaccessstream"
    }
}