package deckers.thibault.aves.channel.calls

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.reflect.KSuspendFunction2

// ensure `result` methods are called on the main looper thread
class Coresult internal constructor(private val methodResult: MethodChannel.Result) : MethodChannel.Result {
    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun success(result: Any?) {
        mainScope.launch { methodResult.success(result) }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        mainScope.launch { methodResult.error(errorCode, errorMessage, errorDetails) }
    }

    override fun notImplemented() {
        mainScope.launch { methodResult.notImplemented() }
    }

    companion object {
        fun safe(call: MethodCall, result: MethodChannel.Result, function: (call: MethodCall, result: MethodChannel.Result) -> Unit) {
            val res = Coresult(result)
            try {
                function(call, res)
            } catch (e: Exception) {
                res.error("safe-exception", e.message, e.stackTraceToString())
            }
        }

        suspend fun safesus(call: MethodCall, result: MethodChannel.Result, function: KSuspendFunction2<MethodCall, MethodChannel.Result, Unit>) {
            val res = Coresult(result)
            try {
                function(call, res)
            } catch (e: Exception) {
                res.error("safe-exception", e.message, e.stackTraceToString())
            }
        }
    }
}
