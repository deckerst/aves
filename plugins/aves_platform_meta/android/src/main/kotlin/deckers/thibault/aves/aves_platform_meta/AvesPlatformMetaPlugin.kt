package deckers.thibault.aves.aves_platform_meta

import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class AvesPlatformMetaPlugin : FlutterPlugin, MethodCallHandler {
    private var context: Context? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "deckers.thibault/aves/aves_platform_meta")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method == "getMetadata") {
            getMetadata(call, result)
        } else {
            result.notImplemented()
        }
    }


    private fun getMetadata(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        if (key == null) {
            result.error("getMetadata-args", "missing arguments", null)
            return
        }

        val ctx = context
        if (ctx == null) {
            result.error("getMetadata-context", "no context", null)
            return
        }

        val metadata = ctx.packageManager.getApplicationInfoCompat(ctx.packageName, PackageManager.GET_META_DATA).metaData
        val value = metadata.getString(key)
        result.success(value)
    }
}
