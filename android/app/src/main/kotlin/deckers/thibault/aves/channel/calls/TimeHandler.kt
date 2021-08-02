package deckers.thibault.aves.channel.calls

import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class TimeHandler : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDefaultTimeZone" -> safe(call, result, ::getDefaultTimeZone)
            else -> result.notImplemented()
        }
    }

    private fun getDefaultTimeZone(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        result.success(TimeZone.getDefault().id)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/time"
    }
}