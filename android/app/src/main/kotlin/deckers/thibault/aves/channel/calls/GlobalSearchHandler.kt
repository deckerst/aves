package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.content.Context
import android.util.Log
import deckers.thibault.aves.SearchSuggestionsProvider
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class GlobalSearchHandler(private val context: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "registerCallback" -> safe(call, result, ::registerCallback)
            else -> result.notImplemented()
        }
    }

    private fun registerCallback(call: MethodCall, result: MethodChannel.Result) {
        val callbackHandle = call.argument<Number>("callbackHandle")?.toLong()
        if (callbackHandle == null) {
            result.error("registerCallback-args", "failed because of missing arguments", null)
            return
        }

        Log.i(LOG_TAG, "register global search callback")
        context.getSharedPreferences(SearchSuggestionsProvider.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            .edit()
            .putLong(SearchSuggestionsProvider.CALLBACK_HANDLE_KEY, callbackHandle)
            .apply()
        result.success(true)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<GlobalSearchHandler>()
        const val CHANNEL = "deckers.thibault/aves/global_search"
    }
}