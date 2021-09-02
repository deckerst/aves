package deckers.thibault.aves.channel.calls

import android.os.Build
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class DeviceHandler : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPerformanceClass" -> safe(call, result, ::getPerformanceClass)
            else -> result.notImplemented()
        }
    }

    private fun getPerformanceClass(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            result.success(Build.VERSION.MEDIA_PERFORMANCE_CLASS)
            return
        }
        result.success(Build.VERSION.SDK_INT)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/device"
    }
}