package deckers.thibault.aves.channel.calls.window

import android.app.Activity
import android.os.Build
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ActivityWindowHandler(private val activity: Activity) : WindowHandler(activity) {
    override fun isActivity(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(true)
    }

    override fun keepScreenOn(call: MethodCall, result: MethodChannel.Result) {
        val on = call.argument<Boolean>("on")
        if (on == null) {
            result.error("keepOn-args", "missing arguments", null)
            return
        }

        val window = activity.window
        val flag = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON

        val old = (window.attributes.flags and flag) != 0
        if (old != on) {
            if (on) {
                window.addFlags(flag)
            } else {
                window.clearFlags(flag)
            }
        }
        result.success(null)
    }

    override fun requestOrientation(call: MethodCall, result: MethodChannel.Result) {
        val orientation = call.argument<Int>("orientation")
        if (orientation == null) {
            result.error("requestOrientation-args", "missing arguments", null)
            return
        }
        activity.requestedOrientation = orientation
        result.success(true)
    }

    override fun canSetCutoutMode(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
    }

    override fun setCutoutMode(call: MethodCall, result: MethodChannel.Result) {
        val use = call.argument<Boolean>("use")
        if (use == null) {
            result.error("setCutoutMode-args", "missing arguments", null)
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
}