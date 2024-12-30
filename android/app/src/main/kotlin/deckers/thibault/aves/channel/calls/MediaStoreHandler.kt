package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class MediaStoreHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkObsoleteContentIds" -> ioScope.launch { safe(call, result, ::checkObsoleteContentIds) }
            "checkObsoletePaths" -> ioScope.launch { safe(call, result, ::checkObsoletePaths) }
            "getChangedUris" -> ioScope.launch { safe(call, result, ::getChangedUris) }
            "getGeneration" -> ioScope.launch { safe(call, result, ::getGeneration) }
            "scanFile" -> ioScope.launch { safe(call, result, ::scanFile) }
            else -> result.notImplemented()
        }
    }

    private fun checkObsoleteContentIds(call: MethodCall, result: MethodChannel.Result) {
        val knownContentIds = call.argument<List<Number?>>("knownContentIds")?.map { it?.toLong() }
        if (knownContentIds == null) {
            result.error("checkObsoleteContentIds-args", "missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().checkObsoleteContentIds(context, knownContentIds))
    }

    private fun checkObsoletePaths(call: MethodCall, result: MethodChannel.Result) {
        val knownPathById = call.argument<Map<Number?, String?>>("knownPathById")?.mapKeys { it.key?.toLong() }
        if (knownPathById == null) {
            result.error("checkObsoletePaths-args", "missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().checkObsoletePaths(context, knownPathById))
    }

    private fun getChangedUris(call: MethodCall, result: MethodChannel.Result) {
        val sinceGeneration = call.argument<Int>("sinceGeneration")
        if (sinceGeneration == null) {
            result.error("getChangedUris-args", "missing arguments", null)
            return
        }
        val uris = MediaStoreImageProvider().getChangedUris(context, sinceGeneration)
        result.success(uris)
    }

    private fun getGeneration(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val generation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                MediaStore.getGeneration(context, MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } catch (e: Exception) {
                // may yield `IllegalArgumentException: Volume external_primary not found`
                val volumes = MediaStore.getExternalVolumeNames(context).joinToString(", ")
                result.error("getGeneration-primary", e.message + " (available volumes are [$volumes])", e)
                return
            }
        } else {
            null
        }
        result.success(generation)
    }

    private fun scanFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val mimeType = call.argument<String>("mimeType")
        MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, uri: Uri? -> result.success(uri?.toString()) }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/media_store"
    }
}