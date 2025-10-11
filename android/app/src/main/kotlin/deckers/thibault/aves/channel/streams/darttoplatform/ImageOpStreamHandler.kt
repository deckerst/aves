package deckers.thibault.aves.channel.streams.darttoplatform

import android.app.Activity
import android.util.Log
import androidx.core.net.toUri
import deckers.thibault.aves.channel.calls.MediaEditHandler.Companion.cancelledOps
import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.NameConflictStrategy
import deckers.thibault.aves.model.provider.ImageProvider.ImageOpCallback
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import kotlinx.coroutines.launch

class ImageOpStreamHandler(private val activity: Activity, private val arguments: Any?) : BaseStreamHandler() {
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

    override val logTag = LOG_TAG

    override fun onCall(args: Any?) {
        when (op) {
            "delete" -> ioScope.launch { safe(::delete) }
            "convert" -> ioScope.launch { safeSuspend(::convert) }
            "move" -> ioScope.launch { safeSuspend(::move) }
            "rename" -> ioScope.launch { safeSuspend(::rename) }
            else -> endOfStream()
        }
    }

    override fun endOfStream() {
        cancelledOps.remove(opId)
        super.endOfStream()
    }

    private fun isCancelledOp() = cancelledOps.contains(opId)

    private fun delete() {
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
                result["success"] = false
                getProvider(activity, uri)?.let { provider ->
                    try {
                        provider.delete(activity, uri, path, mimeType)
                        result["success"] = true
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to delete entry with path=$path", e)
                    }
                }
            }
            success(result)
        }
        endOfStream()
    }

    private suspend fun convert() {
        if (arguments !is Map<*, *> || entryMapList.isEmpty()) {
            endOfStream()
            return
        }

        var destinationDir = arguments["destinationPath"] as String?
        val mimeType = arguments["mimeType"] as String?
        val quality = (arguments["quality"] as Number?)?.toInt()
        val lengthUnit = arguments["lengthUnit"] as String?
        val width = (arguments["width"] as Number?)?.toInt()
        val height = (arguments["height"] as Number?)?.toInt()
        val writeMetadata = arguments["writeMetadata"] as Boolean?
        val nameConflictStrategy = NameConflictStrategy.get(arguments["nameConflictStrategy"] as String?)
        if (destinationDir == null || mimeType == null || quality == null || lengthUnit == null || width == null || height == null || writeMetadata == null || nameConflictStrategy == null) {
            error("convert-args", "missing arguments", null)
            return
        }

        // assume same provider for all entries
        val firstEntry = entryMapList.first()
        val provider = (firstEntry["uri"] as String?)?.toUri()?.let { getProvider(activity, it) }
        if (provider == null) {
            error("convert-provider", "failed to find provider for entry=$firstEntry", null)
            return
        }

        destinationDir = ensureTrailingSeparator(destinationDir)
        val entries = entryMapList.map(::AvesEntry)
        provider.convertMultiple(
            activity = activity,
            imageExportMimeType = mimeType,
            targetDir = destinationDir,
            entries = entries,
            quality = quality,
            lengthUnit = lengthUnit,
            width = width,
            height = height,
            writeMetadata = writeMetadata,
            nameConflictStrategy = nameConflictStrategy,
            callback = object : ImageOpCallback {
                override fun onSuccess(fields: FieldMap) = success(fields)
                override fun onFailure(throwable: Throwable) = error("convert-failure", "failed to convert entries", throwable)
            },
        )
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

        provider.moveMultiple(
            activity = activity,
            copy = copy,
            nameConflictStrategy = nameConflictStrategy,
            entriesByTargetDir = entriesByTargetDir,
            isCancelledOp = ::isCancelledOp,
            callback = object : ImageOpCallback {
                override fun onSuccess(fields: FieldMap) = success(fields)
                override fun onFailure(throwable: Throwable) = error("move-failure", "failed to move entries", throwable)
            },
        )
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

        val byProvider = entriesToNewName.entries.groupBy { kv -> getProvider(activity, kv.key.uri) }
        for ((provider, entryList) in byProvider) {
            if (provider == null) {
                error("rename-provider", "failed to find provider for entry=${entryList.firstOrNull()}", null)
                return
            }

            val entryMap = mapOf(*entryList.map { Pair(it.key, it.value) }.toTypedArray())
            provider.renameMultiple(
                activity = activity,
                entriesToNewName = entryMap,
                isCancelledOp = ::isCancelledOp,
                callback = object : ImageOpCallback {
                    override fun onSuccess(fields: FieldMap) = success(fields)
                    override fun onFailure(throwable: Throwable) = error("rename-failure", "failed to rename", throwable.message)
                },
            )
        }

        endOfStream()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ImageOpStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_op_stream"
    }
}