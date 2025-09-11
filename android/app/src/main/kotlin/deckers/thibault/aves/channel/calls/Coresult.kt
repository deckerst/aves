package deckers.thibault.aves.channel.calls

import deckers.thibault.aves.MainActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// ensure `result` methods are called on the main looper thread
class Coresult internal constructor(private val call: MethodCall, private val methodResult: MethodChannel.Result) : MethodChannel.Result {
    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun success(result: Any?) {
        mainScope.launch {
            try {
                methodResult.success(result)
            } catch (e: Exception) {
                MainActivity.notifyError("failed to reply success for method=${call.method}, result=$result, exception=\n${e.stackTraceToString()}")
            }
        }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        mainScope.launch {
            try {
                methodResult.error(errorCode, errorMessage, errorDetails)
            } catch (e: Exception) {
                MainActivity.notifyError("failed to reply error for method=${call.method}, errorCode=$errorCode, errorMessage=$errorMessage, errorDetails=$errorDetails, exception=\n${e.stackTraceToString()}")
            }
        }
    }

    override fun notImplemented() {
        mainScope.launch {
            try {
                methodResult.notImplemented()
            } catch (e: Exception) {
                MainActivity.notifyError("failed to reply notImplemented for method=${call.method}, exception=\n${e.stackTraceToString()}")
            }
        }
    }

    companion object {
        fun safe(
            call: MethodCall,
            result: MethodChannel.Result,
            function: (call: MethodCall, result: MethodChannel.Result) -> Unit
        ) {
            val res = Coresult(call, result)
            try {
                function(call, res)
            } catch (e: Exception) {
                res.error("safe-exception", e.message, e.stackTraceToString())
            }
        }

        suspend fun safeSuspend(
            call: MethodCall,
            result: MethodChannel.Result,
            function: suspend (call: MethodCall, result: MethodChannel.Result) -> Unit
        ) {
            val res = Coresult(call, result)
            try {
                function(call, res)
            } catch (e: Exception) {
                res.error("safeSuspend-exception", e.message, e.stackTraceToString())
            }
        }
    }
}
