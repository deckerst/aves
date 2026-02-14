package deckers.thibault.aves.channel.calls

import android.app.WallpaperManager
import android.app.WallpaperManager.FLAG_LOCK
import android.app.WallpaperManager.FLAG_SYSTEM
import android.content.ContextWrapper
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class WallpaperHandler(private val contextWrapper: ContextWrapper) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setWallpaper" -> ioScope.launch { safe(call, result, ::setWallpaper) }
            else -> result.notImplemented()
        }
    }

    private fun setWallpaper(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val home = call.argument<Boolean>("home")
        val lock = call.argument<Boolean>("lock")
        if (bytes == null || home == null || lock == null) {
            result.error("setWallpaper-args", "missing arguments", null)
            return
        }

        val manager = WallpaperManager.getInstance(contextWrapper)
        if (!manager.isWallpaperSupported || !manager.isSetWallpaperAllowed) {
            result.error("setWallpaper-unsupported", "failed because setting wallpaper is not allowed", null)
            return
        }

        bytes.inputStream().use { input ->
            val flags = (if (home) FLAG_SYSTEM else 0) or (if (lock) FLAG_LOCK else 0)
            manager.setStream(input, null, true, flags)
        }
        result.success(true)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/wallpaper"
    }
}