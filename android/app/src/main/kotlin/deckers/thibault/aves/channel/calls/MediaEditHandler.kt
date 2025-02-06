package deckers.thibault.aves.channel.calls

import android.content.ContextWrapper
import android.util.Log
import androidx.core.net.toUri
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.NameConflictStrategy
import deckers.thibault.aves.model.provider.ImageProvider.ImageOpCallback
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class MediaEditHandler(private val contextWrapper: ContextWrapper) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "cancelFileOp" -> safe(call, result, ::cancelFileOp)
            "captureFrame" -> ioScope.launch { safeSuspend(call, result, ::captureFrame) }
            else -> result.notImplemented()
        }
    }

    private fun cancelFileOp(call: MethodCall, result: MethodChannel.Result) {
        val opId = call.argument<String>("opId")
        if (opId == null) {
            result.error("cancelFileOp-args", "missing arguments", null)
            return
        }

        Log.i(LOG_TAG, "cancelling file op $opId")
        cancelledOps.add(opId)

        result.success(null)
    }

    private suspend fun captureFrame(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.toUri()
        val desiredName = call.argument<String>("desiredName")
        val exifFields = call.argument<FieldMap>("exif") ?: HashMap()
        val bytes = call.argument<ByteArray>("bytes")
        var destinationDir = call.argument<String>("destinationPath")
        val nameConflictStrategy = NameConflictStrategy.get(call.argument<String>("nameConflictStrategy"))
        if (uri == null || desiredName == null || bytes == null || destinationDir == null || nameConflictStrategy == null) {
            result.error("captureFrame-args", "missing arguments", null)
            return
        }

        val provider = getProvider(contextWrapper, uri)
        if (provider == null) {
            result.error("captureFrame-provider", "failed to find provider for uri=$uri", null)
            return
        }

        destinationDir = ensureTrailingSeparator(destinationDir)
        provider.captureFrame(contextWrapper, desiredName, exifFields, bytes, destinationDir, nameConflictStrategy, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("captureFrame-failure", "failed to capture frame for uri=$uri", throwable.message)
        })
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaEditHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_edit"

        val cancelledOps = HashSet<String>()
    }
}