package deckers.thibault.aves.channel.calls

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.core.net.toUri
import com.bumptech.glide.Glide
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
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

class MediaFetchObjectHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getEntry" -> ioScope.launch { safe(call, result, ::getEntry) }
            "clearImageDiskCache" -> ioScope.launch { safe(call, result, ::clearImageDiskCache) }
            "clearImageMemoryCache" -> ioScope.launch { safe(call, result, ::clearImageMemoryCache) }
            else -> result.notImplemented()
        }
    }

    private fun getEntry(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType") // MIME type is optional
        val uri = call.argument<String>("uri")?.toUri()
        val allowUnsized = call.argument<Boolean>("allowUnsized") ?: false
        if (uri == null) {
            result.error("getEntry-args", "missing arguments", null)
            return
        }

        val provider = getProvider(context, uri)
        if (provider == null) {
            result.error("getEntry-provider", "failed to find provider for uri=$uri mimeType=$mimeType", null)
            return
        }

        provider.fetchSingle(context, uri, mimeType, allowUnsized, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("getEntry-failure", "failed to get entry for uri=$uri mimeType=$mimeType", throwable.message)
        })
    }

    private fun clearImageDiskCache(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        Glide.get(context).clearDiskCache()
        result.success(null)
    }

    private fun clearImageMemoryCache(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        Handler(Looper.getMainLooper()).post {
            Glide.get(context).clearMemory()
        }
        result.success(null)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/media_fetch_object"
    }
}