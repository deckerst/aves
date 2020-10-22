package deckers.thibault.aves.channel.calls

import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

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
}
