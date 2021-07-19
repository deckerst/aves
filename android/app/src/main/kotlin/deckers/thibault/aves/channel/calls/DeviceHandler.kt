package deckers.thibault.aves.channel.calls

import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class DeviceHandler : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPerformanceClass" -> result.success(getPerformanceClass())
            else -> result.notImplemented()
        }
    }

    private fun getPerformanceClass(): Int {
        // TODO TLAD uncomment when the future is here
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            return Build.VERSION.MEDIA_PERFORMANCE_CLASS
//        }
        return Build.VERSION.SDK_INT
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/device"
    }
}