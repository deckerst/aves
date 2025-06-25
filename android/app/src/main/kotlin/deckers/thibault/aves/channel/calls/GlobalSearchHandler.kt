package deckers.thibault.aves.channel.calls

import android.content.Context
import androidx.core.content.edit
import deckers.thibault.aves.SearchSuggestionsProvider
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class GlobalSearchHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "registerCallback" -> ioScope.launch { safe(call, result, ::registerCallback) }
            else -> result.notImplemented()
        }
    }

    private fun registerCallback(call: MethodCall, result: MethodChannel.Result) {
        val callbackHandle = call.argument<Number>("callbackHandle")?.toLong()
        if (callbackHandle == null) {
            result.error("registerCallback-args", "missing arguments", null)
            return
        }

        val preferences = context.getSharedPreferences(SearchSuggestionsProvider.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
        preferences.edit {
            putLong(SearchSuggestionsProvider.CALLBACK_HANDLE_KEY, callbackHandle)
        }
        result.success(true)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/global_search"
    }
}