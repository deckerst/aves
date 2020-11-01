package deckers.thibault.aves.channel.streams

import android.content.Context
import android.os.Handler
import android.os.Looper
import deckers.thibault.aves.model.provider.FieldMap
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class MediaStoreStreamHandler(private val context: Context, arguments: Any?) : EventChannel.StreamHandler {
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler

    private var knownEntries: Map<Int, Int?>? = null

    init {
        if (arguments is Map<*, *>) {
            @Suppress("UNCHECKED_CAST")
            knownEntries = arguments["knownEntries"] as Map<Int, Int?>?
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())

        GlobalScope.launch { fetchAll() }
    }

    override fun onCancel(arguments: Any?) {}

    private fun success(result: FieldMap) {
        handler.post { eventSink.success(result) }
    }

    private fun endOfStream() {
        handler.post { eventSink.endOfStream() }
    }

    private suspend fun fetchAll() {
        MediaStoreImageProvider().fetchAll(context, knownEntries ?: emptyMap()) { success(it) }
        endOfStream()
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/mediastorestream"
    }
}