package deckers.thibault.aves.channel.calls

import android.os.Build
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class DeviceHandler : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDefaultTimeZone" -> safe(call, result, ::getDefaultTimeZone)
            "getPerformanceClass" -> safe(call, result, ::getPerformanceClass)
            else -> result.notImplemented()
        }
    }

    private fun getDefaultTimeZone(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        result.success(TimeZone.getDefault().id)
    }

    private fun getPerformanceClass(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val performanceClass = Build.VERSION.MEDIA_PERFORMANCE_CLASS
            if (performanceClass > 0) {
                result.success(performanceClass)
                return
            }
        }
        result.success(Build.VERSION.SDK_INT)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/device"
    }
}