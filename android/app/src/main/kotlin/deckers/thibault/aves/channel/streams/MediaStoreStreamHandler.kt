package deckers.thibault.aves.channel.streams

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.Dispatchers
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

        GlobalScope.launch(Dispatchers.IO) { fetchAll() }
    }

    override fun onCancel(arguments: Any?) {}

    private fun success(result: FieldMap) {
        handler.post {
            try {
                eventSink.success(result)
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

    private suspend fun fetchAll() {
        MediaStoreImageProvider().fetchAll(context, knownEntries ?: emptyMap()) { success(it) }
        endOfStream()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag(MediaStoreStreamHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/mediastorestream"
    }
}