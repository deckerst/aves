package deckers.thibault.aves.channel.calls

import android.content.ContextWrapper
import android.net.Uri
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.metadata.Mp4TooLargeException
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.provider.ImageProvider.ImageOpCallback
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.io.FileNotFoundException

class MetadataEditHandler(private val contextWrapper: ContextWrapper) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "rotate" -> ioScope.launch { safe(call, result, ::rotate) }
            "flip" -> ioScope.launch { safe(call, result, ::flip) }
            "editDate" -> ioScope.launch { safe(call, result, ::editDate) }
            "editMetadata" -> ioScope.launch { safe(call, result, ::editMetadata) }
            "removeTrailerVideo" -> ioScope.launch { safe(call, result, ::removeTrailerVideo) }
            "removeTypes" -> ioScope.launch { safe(call, result, ::removeTypes) }
            else -> result.notImplemented()
        }
    }

    private fun rotate(call: MethodCall, result: MethodChannel.Result) {
        val clockwise = call.argument<Boolean>("clockwise")
        if (clockwise == null) {
            result.error("rotate-args", "missing arguments", null)
            return
        }

        val op = if (clockwise) ExifOrientationOp.ROTATE_CW else ExifOrientationOp.ROTATE_CCW
        editOrientation(call, result, op)
    }

    private fun flip(call: MethodCall, result: MethodChannel.Result) {
        editOrientation(call, result, ExifOrientationOp.FLIP)
    }

    private fun editOrientation(call: MethodCall, result: MethodChannel.Result, op: ExifOrientationOp) {
        val entryMap = call.argument<FieldMap>("entry")
        if (entryMap == null) {
            result.error("editOrientation-args", "missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("editOrientation-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(contextWrapper, uri)
        if (provider == null) {
            result.error("editOrientation-provider", "failed to find provider for uri=$uri", null)
            return
        }

        val callback = MetadataOpCallback("editOrientation", entryMap, result)
        provider.editOrientation(contextWrapper, path, uri, mimeType, op, callback)
    }

    private fun editDate(call: MethodCall, result: MethodChannel.Result) {
        val dateMillis = call.argument<Number>("dateMillis")?.toLong()
        val shiftMinutes = call.argument<Number>("shiftMinutes")?.toLong()
        val fields = call.argument<List<String>>("fields")
        val entryMap = call.argument<FieldMap>("entry")
        if (entryMap == null || fields == null) {
            result.error("editDate-args", "missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("editDate-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(contextWrapper, uri)
        if (provider == null) {
            result.error("editDate-provider", "failed to find provider for uri=$uri", null)
            return
        }

        val callback = MetadataOpCallback("editDate", entryMap, result)
        provider.editDate(contextWrapper, path, uri, mimeType, dateMillis, shiftMinutes, fields, callback)
    }

    private fun editMetadata(call: MethodCall, result: MethodChannel.Result) {
        val metadata = call.argument<FieldMap>("metadata")
        val entryMap = call.argument<FieldMap>("entry")
        val autoCorrectTrailerOffset = call.argument<Boolean>("autoCorrectTrailerOffset")
        if (entryMap == null || metadata == null || autoCorrectTrailerOffset == null) {
            result.error("editMetadata-args", "missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("editMetadata-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(contextWrapper, uri)
        if (provider == null) {
            result.error("editMetadata-provider", "failed to find provider for uri=$uri", null)
            return
        }

        val callback = MetadataOpCallback("editMetadata", entryMap, result)
        provider.editMetadata(contextWrapper, path, uri, mimeType, metadata, autoCorrectTrailerOffset, callback)
    }

    private fun removeTrailerVideo(call: MethodCall, result: MethodChannel.Result) {
        val entryMap = call.argument<FieldMap>("entry")
        if (entryMap == null) {
            result.error("removeTrailerVideo-args", "missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("removeTrailerVideo-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(contextWrapper, uri)
        if (provider == null) {
            result.error("removeTrailerVideo-provider", "failed to find provider for uri=$uri", null)
            return
        }

        val callback = MetadataOpCallback("removeTrailerVideo", entryMap, result)
        provider.removeTrailerVideo(contextWrapper, path, uri, mimeType, callback)
    }

    private fun removeTypes(call: MethodCall, result: MethodChannel.Result) {
        val types = call.argument<List<String>>("types")
        val entryMap = call.argument<FieldMap>("entry")
        if (entryMap == null || types == null) {
            result.error("removeTypes-args", "missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("removeTypes-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(contextWrapper, uri)
        if (provider == null) {
            result.error("removeTypes-provider", "failed to find provider for uri=$uri", null)
            return
        }

        val callback = MetadataOpCallback("removeTypes", entryMap, result)
        provider.removeMetadataTypes(contextWrapper, path, uri, mimeType, types.toSet(), callback)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/metadata_edit"
    }
}

private class MetadataOpCallback(
    private val errorCodeBase: String,
    private val entryMap: FieldMap,
    private val result: MethodChannel.Result,
) : ImageOpCallback {
    override fun onSuccess(fields: FieldMap) = result.success(fields)
    override fun onFailure(throwable: Throwable) {
        val errorCode = if (throwable is Mp4TooLargeException) {
            if (throwable.type == "moov") {
                "$errorCodeBase-mp4largemoov"
            } else {
                "$errorCodeBase-mp4largeother"
            }
        } else if (throwable is FileNotFoundException) {
            "$errorCodeBase-filenotfound"
        } else {
            "$errorCodeBase-failure"
        }
        result.error(errorCode, "failed for entry=$entryMap", throwable)
    }
}
