package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WindowHandler(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "keepScreenOn" -> safe(call, result, ::keepScreenOn)
            "isRotationLocked" -> safe(call, result, ::isRotationLocked)
            "requestOrientation" -> safe(call, result, ::requestOrientation)
            "canSetCutoutMode" -> safe(call, result, ::canSetCutoutMode)
            "setCutoutMode" -> safe(call, result, ::setCutoutMode)
            else -> result.notImplemented()
        }
    }

    private fun keepScreenOn(call: MethodCall, result: MethodChannel.Result) {
        val on = call.argument<Boolean>("on")
        if (on == null) {
            result.error("keepOn-args", "failed because of missing arguments", null)
            return
        }

        val window = activity.window
        val flag = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        if (on) {
            window.addFlags(flag)
        } else {
            window.clearFlags(flag)
        }
        result.success(null)
    }

    private fun isRotationLocked(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        var locked = false
        try {
            locked = Settings.System.getInt(activity.contentResolver, Settings.System.ACCELEROMETER_ROTATION) == 0
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get settings", e)
        }
        result.success(locked)
    }

    private fun requestOrientation(call: MethodCall, result: MethodChannel.Result) {
        val orientation = call.argument<Int>("orientation")
        if (orientation == null) {
            result.error("requestOrientation-args", "failed because of missing arguments", null)
            return
        }
        activity.requestedOrientation = orientation
        result.success(true)
    }

    private fun canSetCutoutMode(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
    }

    private fun setCutoutMode(call: MethodCall, result: MethodChannel.Result) {
        val use = call.argument<Boolean>("use")
        if (use == null) {
            result.error("setCutoutMode-args", "failed because of missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val mode = if (use) {
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            } else {
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER
            }
            activity.window.attributes.layoutInDisplayCutoutMode = mode
        }
        result.success(true)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<WindowHandler>()
        const val CHANNEL = "deckers.thibault/aves/window"
    }
}