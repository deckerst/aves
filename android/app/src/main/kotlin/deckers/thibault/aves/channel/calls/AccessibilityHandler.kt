package deckers.thibault.aves.channel.calls

import android.content.Context
import android.content.ContextWrapper
import android.content.res.Configuration
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.ViewConfiguration
import android.view.accessibility.AccessibilityManager
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class AccessibilityHandler(private val contextWrapper: ContextWrapper) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "areAnimationsRemoved" -> safe(call, result, ::areAnimationsRemoved)
            "getLongPressTimeout" -> safe(call, result, ::getLongPressTimeout)
            "hasRecommendedTimeouts" -> safe(call, result, ::hasRecommendedTimeouts)
            "getRecommendedTimeoutMillis" -> safe(call, result, ::getRecommendedTimeoutMillis)
            "shouldUseBoldFont" -> safe(call, result, ::shouldUseBoldFont)
            else -> result.notImplemented()
        }
    }

    private fun areAnimationsRemoved(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        var removed = false
        try {
            removed = Settings.Global.getFloat(contextWrapper.contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE) == 0f
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get settings with error=${e.message}", null)
        }
        result.success(removed)
    }

    private fun getLongPressTimeout(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(ViewConfiguration.getLongPressTimeout())
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
            result.error("getRecommendedTimeoutMillis-args", "missing arguments", null)
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

        val am = contextWrapper.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
        if (am == null) {
            result.error("getRecommendedTimeoutMillis-service", "failed to get accessibility manager", null)
            return
        }

        val millis = am.getRecommendedTimeoutMillis(originalTimeoutMillis, uiContentFlags)
        result.success(millis)
    }

    // Flutter v3.4 already checks the system `Configuration.fontWeightAdjustment` to update `MediaQuery`
    // but we need to also check the non-standard Samsung field `bf` representing the bold font toggle
    private fun shouldUseBoldFont(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        var shouldBold = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val config = contextWrapper.resources.configuration
            val fontWeightAdjustment = config.fontWeightAdjustment
            shouldBold = if (fontWeightAdjustment != Configuration.FONT_WEIGHT_ADJUSTMENT_UNDEFINED && fontWeightAdjustment != 0) {
                fontWeightAdjustment >= BOLD_TEXT_WEIGHT_ADJUSTMENT
            } else {
                // fallback to Samsung non-standard field
                Regex(" bf=([01]) ").find(config.toString())?.groups?.get(1)?.value == "1"
            }
        }
        result.success(shouldBold)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AccessibilityHandler>()
        const val CHANNEL = "deckers.thibault/aves/accessibility"

        // match Flutter way: https://github.com/flutter/engine/blob/main/shell/platform/android/io/flutter/view/AccessibilityBridge.java#L125
        const val BOLD_TEXT_WEIGHT_ADJUSTMENT = 300
    }
}