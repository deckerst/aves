package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.view.WindowManager
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WindowHandler(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "keepScreenOn" -> safe(call, result, ::keepScreenOn)
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

    companion object {
        const val CHANNEL = "deckers.thibault/aves/window"
    }
}