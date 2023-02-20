package deckers.thibault.aves.channel.calls.window

import android.content.ContextWrapper
import android.provider.Settings
import android.util.Log
import deckers.thibault.aves.channel.calls.Coresult
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

abstract class WindowHandler(private val contextWrapper: ContextWrapper) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isActivity" -> Coresult.safe(call, result, ::isActivity)
            "keepScreenOn" -> Coresult.safe(call, result, ::keepScreenOn)
            "secureScreen" -> Coresult.safe(call, result, ::secureScreen)
            "isRotationLocked" -> Coresult.safe(call, result, ::isRotationLocked)
            "requestOrientation" -> Coresult.safe(call, result, ::requestOrientation)
            "isCutoutAware" -> Coresult.safe(call, result, ::isCutoutAware)
            "getCutoutInsets" -> Coresult.safe(call, result, ::getCutoutInsets)
            else -> result.notImplemented()
        }
    }

    abstract fun isActivity(call: MethodCall, result: MethodChannel.Result)

    abstract fun keepScreenOn(call: MethodCall, result: MethodChannel.Result)

    abstract fun secureScreen(call: MethodCall, result: MethodChannel.Result)

    private fun isRotationLocked(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        var locked = false
        try {
            locked = Settings.System.getInt(contextWrapper.contentResolver, Settings.System.ACCELEROMETER_ROTATION) == 0
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get settings with error=${e.message}", null)
        }
        result.success(locked)
    }

    abstract fun requestOrientation(call: MethodCall, result: MethodChannel.Result)

    abstract fun isCutoutAware(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result)

    abstract fun getCutoutInsets(call: MethodCall, result: MethodChannel.Result)

    companion object {
        private val LOG_TAG = LogUtils.createTag<WindowHandler>()
        const val CHANNEL = "deckers.thibault/aves/window"
    }
}
