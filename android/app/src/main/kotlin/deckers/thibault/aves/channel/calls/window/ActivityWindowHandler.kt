package deckers.thibault.aves.channel.calls.window

import android.app.Activity
import android.os.Build
import android.view.WindowManager
import deckers.thibault.aves.utils.getDisplayCompat
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

    override fun isCutoutAware(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
    }

    override fun getCutoutInsets(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error("getCutoutInsets-sdk", "unsupported SDK version=${Build.VERSION.SDK_INT}", null)
            return
        }

        val cutout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            activity.getDisplayCompat()?.cutout
        } else {
            activity.window.decorView.rootWindowInsets.displayCutout
        }
        if (cutout == null) {
            result.error("getCutoutInsets-null", "cutout insets are null", null)
            return
        }

        val density = activity.resources.displayMetrics.density
        result.success(
            hashMapOf(
                "left" to cutout.safeInsetLeft / density,
                "top" to cutout.safeInsetTop / density,
                "right" to cutout.safeInsetRight / density,
                "bottom" to cutout.safeInsetBottom / density,
            )
        )
    }
}