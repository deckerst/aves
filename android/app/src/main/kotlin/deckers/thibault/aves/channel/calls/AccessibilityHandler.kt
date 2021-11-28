package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.content.Context
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityManager
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class AccessibilityHandler(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "areAnimationsRemoved" -> safe(call, result, ::areAnimationsRemoved)
            "hasRecommendedTimeouts" -> safe(call, result, ::hasRecommendedTimeouts)
            "getRecommendedTimeoutMillis" -> safe(call, result, ::getRecommendedTimeoutMillis)
            else -> result.notImplemented()
        }
    }

    private fun areAnimationsRemoved(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        var removed = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            try {
                removed = Settings.Global.getFloat(activity.contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE) == 0f
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get settings with error=${e.message}", null)
            }
        }
        result.success(removed)
    }

    private fun hasRecommendedTimeouts(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
    }

    private fun getRecommendedTimeoutMillis(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.error("getRecommendedTimeoutMillis-sdk", "unsupported SDK version=${Build.VERSION.SDK_INT}", null)
            return
        }

        val originalTimeoutMillis = call.argument<Int>("originalTimeoutMillis")
        val content = call.argument<List<String>>("content")
        if (originalTimeoutMillis == null || content == null) {
            result.error("getRecommendedTimeoutMillis-args", "failed because of missing arguments", null)
            return
        }

        var uiContentFlags = 0
        content.forEach {
            uiContentFlags = when (it) {
                "controls" -> uiContentFlags or AccessibilityManager.FLAG_CONTENT_CONTROLS
                "icons" -> uiContentFlags or AccessibilityManager.FLAG_CONTENT_ICONS
                "text" -> uiContentFlags or AccessibilityManager.FLAG_CONTENT_TEXT
                else -> {
                    result.error("getRecommendedTimeoutMillis-flag", "unsupported UI content flag=$it", null)
                    return
                }
            }
        }

        val am = activity.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
        if (am == null) {
            result.error("getRecommendedTimeoutMillis-service", "failed to get accessibility manager", null)
            return
        }

        val millis = am.getRecommendedTimeoutMillis(originalTimeoutMillis, uiContentFlags)
        result.success(millis)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AccessibilityHandler>()
        const val CHANNEL = "deckers.thibault/aves/accessibility"
    }
}