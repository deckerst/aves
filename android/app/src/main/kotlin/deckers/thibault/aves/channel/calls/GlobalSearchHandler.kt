package deckers.thibault.aves.channel.calls

import android.annotation.SuppressLint
import android.content.Context
import deckers.thibault.aves.SearchSuggestionsProvider
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class GlobalSearchHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "registerCallback" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::registerCallback) }
            else -> result.notImplemented()
        }
    }

    @SuppressLint("CommitPrefEdits")
    private fun registerCallback(call: MethodCall, result: MethodChannel.Result) {
        val callbackHandle = call.argument<Number>("callbackHandle")?.toLong()
        if (callbackHandle == null) {
            result.error("registerCallback-args", "failed because of missing arguments", null)
            return
        }

        context.getSharedPreferences(SearchSuggestionsProvider.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            .edit()
            .putLong(SearchSuggestionsProvider.CALLBACK_HANDLE_KEY, callbackHandle)
            .apply()
        result.success(true)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/global_search"
    }
}