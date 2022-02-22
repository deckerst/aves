package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
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
            "scanFile" -> ioScope.launch { safe(call, result, ::scanFile) }
            else -> result.notImplemented()
        }
    }

    private fun checkObsoleteContentIds(call: MethodCall, result: MethodChannel.Result) {
        val knownContentIds = call.argument<List<Int?>>("knownContentIds")
        if (knownContentIds == null) {
            result.error("checkObsoleteContentIds-args", "failed because of missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().checkObsoleteContentIds(context, knownContentIds))
    }

    private fun checkObsoletePaths(call: MethodCall, result: MethodChannel.Result) {
        val knownPathById = call.argument<Map<Int?, String?>>("knownPathById")
        if (knownPathById == null) {
            result.error("checkObsoletePaths-args", "failed because of missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().checkObsoletePaths(context, knownPathById))
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