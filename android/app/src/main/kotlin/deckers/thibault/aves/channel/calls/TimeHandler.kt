package deckers.thibault.aves.channel.calls

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class TimeHandler : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDefaultTimeZone" -> result.success(TimeZone.getDefault().id)
            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/time"
    }
}