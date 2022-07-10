package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.channel.calls.MediaFileHandler.Companion.cancelledOps
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.NameConflictStrategy
import deckers.thibault.aves.model.provider.ImageProvider.ImageOpCallback
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class ImageOpStreamHandler(private val activity: Activity, private val arguments: Any?) : EventChannel.StreamHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler

    private var op: String? = null
    private var opId: String? = null
    private val entryMapList = ArrayList<FieldMap>()

    init {
        if (arguments is Map<*, *>) {
            op = arguments["op"] as String?
            opId = arguments["id"] as String?
            @Suppress("unchecked_cast")
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
            "delete" -> ioScope.launch { delete() }
            "export" -> ioScope.launch { export() }
            "move" -> ioScope.launch { move() }
            "rename" -> ioScope.launch { rename() }
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
        cancelledOps.remove(opId)
        handler.post {
            try {
                eventSink.endOfStream()
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
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

        val entries = entryMapList.map(::AvesEntry)
        for (entry in entries) {
            val mimeType = entry.mimeType
            val trashed = entry.trashed

            val uri = entry.uri
            val path = if (trashed) entry.trashPath else entry.path

            val result: FieldMap = hashMapOf(
                "uri" to uri.toString(),
            )
            if (isCancelledOp()) {
                result["skipped"] = true
            } else {
                try {
                    provider.delete(activity, uri, path, mimeType)
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to delete entry with path=$path", e)
                    result["success"] = false
                }
            }
            success(result)
        }
        endOfStream()
    }

    private suspend fun export() {
        if (arguments !is Map<*, *> || entryMapList.isEmpty()) {
            endOfStream()
            return
        }

        var destinationDir = arguments["destinationPath"] as String?
        val mimeType = arguments["mimeType"] as String?
        val width = arguments["width"] as Int?
        val height = arguments["height"] as Int?
        val nameConflictStrategy = NameConflictStrategy.get(arguments["nameConflictStrategy"] as String?)
        if (destinationDir == null || mimeType == null || width == null || height == null || nameConflictStrategy == null) {
            error("export-args", "missing arguments", null)
            return
        }

        // assume same provider for all entries
        val firstEntry = entryMapList.first()
        val provider = (firstEntry["uri"] as String?)?.let { Uri.parse(it) }?.let { getProvider(it) }
        if (provider == null) {
            error("export-provider", "failed to find provider for entry=$firstEntry", null)
            return
        }

        destinationDir = ensureTrailingSeparator(destinationDir)
        val entries = entryMapList.map(::AvesEntry)
        provider.exportMultiple(activity, mimeType, destinationDir, entries, width, height, nameConflictStrategy, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = success(fields)
            override fun onFailure(throwable: Throwable) = error("export-failure", "failed to export entries", throwable)
        })
        endOfStream()
    }

    private suspend fun move() {
        if (arguments !is Map<*, *>) {
            endOfStream()
            return
        }

        val copy = arguments["copy"] as Boolean?
        val nameConflictStrategy = NameConflictStrategy.get(arguments["nameConflictStrategy"] as String?)
        val rawEntryMap = arguments["entriesByDestination"] as Map<*, *>?
        if (copy == null || nameConflictStrategy == null || rawEntryMap == null || rawEntryMap.isEmpty()) {
            error("move-args", "missing arguments", null)
            return
        }

        val entriesByTargetDir = HashMap<String, List<AvesEntry>>()
        rawEntryMap.forEach {
            var destinationDir = it.key as String
            if (destinationDir != StorageUtils.TRASH_PATH_PLACEHOLDER) {
                destinationDir = ensureTrailingSeparator(destinationDir)
            }
            @Suppress("unchecked_cast")
            val rawEntries = it.value as List<FieldMap>
            entriesByTargetDir[destinationDir] = rawEntries.map(::AvesEntry)
        }

        // always use Media Store (as we move from or to it)
        val provider = MediaStoreImageProvider()

        provider.moveMultiple(activity, copy, nameConflictStrategy, entriesByTargetDir, ::isCancelledOp, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = success(fields)
            override fun onFailure(throwable: Throwable) = error("move-failure", "failed to move entries", throwable)
        })
        endOfStream()
    }

    private suspend fun rename() {
        if (arguments !is Map<*, *>) {
            endOfStream()
            return
        }

        val rawEntryMap = arguments["entriesToNewName"] as Map<*, *>?
        if (rawEntryMap == null || rawEntryMap.isEmpty()) {
            error("rename-args", "missing arguments", null)
            return
        }

        val entriesToNewName = HashMap<AvesEntry, String>()
        rawEntryMap.forEach {
            @Suppress("unchecked_cast")
            val rawEntry = it.key as FieldMap
            val newName = it.value as String
            entriesToNewName[AvesEntry(rawEntry)] = newName
        }

        // assume same provider for all entries
        val firstEntry = entriesToNewName.keys.first()
        val provider = getProvider(firstEntry.uri)
        if (provider == null) {
            error("rename-provider", "failed to find provider for entry=$firstEntry", null)
            return
        }

        provider.renameMultiple(activity, entriesToNewName, ::isCancelledOp, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = success(fields)
            override fun onFailure(throwable: Throwable) = error("rename-failure", "failed to rename", throwable.message)
        })
        endOfStream()
    }

    private fun isCancelledOp() = cancelledOps.contains(opId)

    companion object {
        private val LOG_TAG = LogUtils.createTag<ImageOpStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_op_stream"
    }
}