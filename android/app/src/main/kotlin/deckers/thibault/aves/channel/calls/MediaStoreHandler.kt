package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.media.MediaScannerConnection
import android.net.Uri
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class MediaStoreHandler(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkObsoleteContentIds" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::checkObsoleteContentIds) }
            "checkObsoletePaths" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::checkObsoletePaths) }
            "scanFile" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::scanFile) }
            else -> result.notImplemented()
        }
    }

    private fun checkObsoleteContentIds(call: MethodCall, result: MethodChannel.Result) {
        val knownContentIds = call.argument<List<Int>>("knownContentIds")
        if (knownContentIds == null) {
            result.error("checkObsoleteContentIds-args", "failed because of missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().checkObsoleteContentIds(activity, knownContentIds))
    }

    private fun checkObsoletePaths(call: MethodCall, result: MethodChannel.Result) {
        val knownPathById = call.argument<Map<Int, String>>("knownPathById")
        if (knownPathById == null) {
            result.error("checkObsoletePaths-args", "failed because of missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().checkObsoletePaths(activity, knownPathById))
    }

    private fun scanFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val mimeType = call.argument<String>("mimeType")
        MediaScannerConnection.scanFile(activity, arrayOf(path), arrayOf(mimeType)) { _, uri: Uri? -> result.success(uri?.toString()) }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/media_store"
    }
}