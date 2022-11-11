package deckers.thibault.aves.channel.calls

import android.content.ContextWrapper
import android.net.Uri
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
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

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("editOrientation-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.editOrientation(contextWrapper, path, uri, mimeType, op, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("editOrientation-failure", "failed to change orientation for mimeType=$mimeType uri=$uri", throwable)
        })
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

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("editDate-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.editDate(contextWrapper, path, uri, mimeType, dateMillis, shiftMinutes, fields, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("editDate-failure", "failed to edit date for mimeType=$mimeType uri=$uri", throwable)
        })
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

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("editMetadata-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.editMetadata(contextWrapper, path, uri, mimeType, metadata, autoCorrectTrailerOffset, callback = object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("editMetadata-failure", "failed to edit metadata for mimeType=$mimeType uri=$uri", throwable)
        })
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

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("removeTrailerVideo-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.removeTrailerVideo(contextWrapper, path, uri, mimeType, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("removeTrailerVideo-failure", "failed to remove trailer video for mimeType=$mimeType uri=$uri", throwable)
        })
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

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("removeTypes-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.removeMetadataTypes(contextWrapper, path, uri, mimeType, types.toSet(), object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("removeTypes-failure", "failed to remove metadata for mimeType=$mimeType uri=$uri", throwable)
        })
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/metadata_edit"
    }
}