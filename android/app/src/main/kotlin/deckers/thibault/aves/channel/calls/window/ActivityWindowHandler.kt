package deckers.thibault.aves.channel.calls.window

import android.app.Activity
import android.content.pm.ActivityInfo
import android.os.Build
import android.view.WindowManager
import deckers.thibault.aves.utils.getDisplayCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ActivityWindowHandler(private val activity: Activity) : WindowHandler(activity) {
    override fun isActivity(call: MethodCall, result: MethodChannel.Result) {
        result.success(true)
    }

    private fun setWindowFlag(call: MethodCall, result: MethodChannel.Result, flag: Int) {
        val on = call.argument<Boolean>("on")
        if (on == null) {
            result.error("keepOn-args", "missing arguments", null)
            return
        }

        val window = activity.window
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

    override fun keepScreenOn(call: MethodCall, result: MethodChannel.Result) {
        setWindowFlag(call, result, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun secureScreen(call: MethodCall, result: MethodChannel.Result) {
        setWindowFlag(call, result, WindowManager.LayoutParams.FLAG_SECURE)
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

    override fun isCutoutAware(call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
    }

    override fun getCutoutInsets(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error("getCutoutInsets-sdk", "unsupported SDK version=${Build.VERSION.SDK_INT}", null)
            return
        }

        val cutout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            activity.getDisplayCompat()?.cutout
        } else {
            activity.window.decorView.rootWindowInsets.displayCutout
        }

        val density = activity.resources.displayMetrics.density
        result.success(
            hashMapOf(
                "left" to (cutout?.safeInsetLeft ?: 0) / density,
                "top" to (cutout?.safeInsetTop ?: 0) / density,
                "right" to (cutout?.safeInsetRight ?: 0) / density,
                "bottom" to (cutout?.safeInsetBottom ?: 0) / density,
            )
        )
    }

    override fun supportsWideGamut(call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity.resources.configuration.isScreenWideColorGamut)
    }

    override fun supportsHdr(call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity.resources.configuration.isScreenHdr)
    }

    override fun setHdrColorMode(call: MethodCall, result: MethodChannel.Result) {
        val on = call.argument<Boolean>("on")
        if (on == null) {
            result.error("setHdrColorMode-args", "missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.window.colorMode = if (on) ActivityInfo.COLOR_MODE_HDR else ActivityInfo.COLOR_MODE_DEFAULT
        }
        result.success(null)
    }
}