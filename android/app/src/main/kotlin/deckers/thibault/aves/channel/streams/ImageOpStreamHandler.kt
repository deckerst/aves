package deckers.thibault.aves.channel.streams

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.model.AvesImageEntry
import deckers.thibault.aves.model.provider.FieldMap
import deckers.thibault.aves.model.provider.ImageProvider.ImageOpCallback
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.*

class ImageOpStreamHandler(private val context: Context, private val arguments: Any?) : EventChannel.StreamHandler {
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler

    private var op: String? = null
    private val entryMapList = ArrayList<FieldMap>()

    init {
        if (arguments is Map<*, *>) {
            op = arguments["op"] as String?
            @Suppress("UNCHECKED_CAST")
            val rawEntries = arguments["entries"] as List<FieldMap>?
            if (rawEntries != null) {
                entryMapList.addAll(rawEntries)
            }
        }
    }

    override fun onListen(args: Any, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())

        when (op) {
            "delete" -> GlobalScope.launch(Dispatchers.IO) { delete() }
            "move" -> GlobalScope.launch(Dispatchers.IO) { move() }
            else -> endOfStream()
        }
    }

    override fun onCancel(o: Any) {}

    // {String uri, bool success, [Map<String, Object> newFields]}
    private fun success(result: Map<String, *>) {
        handler.post {
            try {
                eventSink.success(result)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    private fun error(errorCode: String, errorMessage: String, errorDetails: Any?) {
        handler.post {
            try {
                eventSink.error(errorCode, errorMessage, errorDetails)
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

    private suspend fun move() {
        if (arguments !is Map<*, *> || entryMapList.isEmpty()) {
            endOfStream()
            return
        }

        // assume same provider for all entries
        val firstEntry = entryMapList.first()
        val provider = (firstEntry["uri"] as String?)?.let { Uri.parse(it) }?.let { getProvider(it) }
        if (provider == null) {
            error("move-provider", "failed to find provider for entry=$firstEntry", null)
            return
        }

        val copy = arguments["copy"] as Boolean?
        var destinationDir = arguments["destinationPath"] as String?
        if (copy == null || destinationDir == null) {
            error("move-args", "failed because of missing arguments", null)
            return
        }

        destinationDir = StorageUtils.ensureTrailingSeparator(destinationDir)
        val entries = entryMapList.map(::AvesImageEntry)
        provider.moveMultiple(context, copy, destinationDir, entries, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = success(fields)
            override fun onFailure(throwable: Throwable) = error("move-failure", "failed to move entries", throwable)
        })
        endOfStream()
    }

    private suspend fun delete() {
        if (entryMapList.isEmpty()) {
            endOfStream()
            return
        }

        // assume same provider for all entries
        val firstEntry = entryMapList.first()
        val provider = (firstEntry["uri"] as String?)?.let { Uri.parse(it) }?.let { getProvider(it) }
        if (provider == null) {
            error("delete-provider", "failed to find provider for entry=$firstEntry", null)
            return
        }

        for (entryMap in entryMapList) {
            val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
            val path = entryMap["path"] as String?
            if (uri != null) {
                val result = hashMapOf<String, Any?>(
                    "uri" to uri.toString(),
                )
                try {
                    provider.delete(context, uri, path)
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to delete entry with path=$path", e)
                    result["success"] = false
                }
                success(result)
            }
        }
        endOfStream()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag(ImageOpStreamHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/imageopstream"
    }
}