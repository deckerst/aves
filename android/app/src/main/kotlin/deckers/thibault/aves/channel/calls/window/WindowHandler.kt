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
            "isCrossWindowBlurEnabled" -> Coresult.safe(call, result, ::isCrossWindowBlurEnabled)
            "isInMultiWindowMode" -> Coresult.safe(call, result, ::isInMultiWindowMode)
            "isInPictureInPictureMode" -> Coresult.safe(call, result, ::isInPictureInPictureMode)
            "isRotationLocked" -> Coresult.safe(call, result, ::isRotationLocked)
            "getOrientation" -> Coresult.safe(call, result, ::getOrientation)
            "requestOrientation" -> Coresult.safe(call, result, ::requestOrientation)
            "showSystemUI" -> Coresult.safe(call, result, ::showSystemUI)
            "isCutoutAware" -> Coresult.safe(call, result, ::isCutoutAware)
            "getCutoutInsets" -> Coresult.safe(call, result, ::getCutoutInsets)

            "supportsWideGamut" -> Coresult.safe(call, result, ::supportsWideGamut)
            "supportsHdr" -> Coresult.safe(call, result, ::supportsHdr)
            "isInWideColorGamutMode" -> Coresult.safe(call, result, ::isInWideColorGamutMode)
            "isInHdrMode" -> Coresult.safe(call, result, ::isInHdrMode)
            "getDisplayHdrSdrRatio" -> Coresult.safe(call, result, ::getDisplayHdrSdrRatio)
            "getDesiredHdrHeadroom" -> Coresult.safe(call, result, ::getDesiredHdrHeadroom)
            "setColorMode" -> Coresult.safe(call, result, ::setColorMode)

            "startGlobalDrag" -> Coresult.safe(call, result, ::startGlobalDrag)
            else -> result.notImplemented()
        }
    }

    abstract fun isActivity(call: MethodCall, result: MethodChannel.Result)

    abstract fun keepScreenOn(call: MethodCall, result: MethodChannel.Result)

    abstract fun secureScreen(call: MethodCall, result: MethodChannel.Result)

    abstract fun isCrossWindowBlurEnabled(call: MethodCall, result: MethodChannel.Result)

    abstract fun isInMultiWindowMode(call: MethodCall, result: MethodChannel.Result)

    abstract fun isInPictureInPictureMode(call: MethodCall, result: MethodChannel.Result)

    private fun isRotationLocked(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        var locked = false
        try {
            locked = Settings.System.getInt(contextWrapper.contentResolver, Settings.System.ACCELEROMETER_ROTATION) == 0
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get settings with error=${e.message}", null)
        }
        result.success(locked)
    }

    abstract fun getOrientation(call: MethodCall, result: MethodChannel.Result)

    abstract fun requestOrientation(call: MethodCall, result: MethodChannel.Result)

    abstract fun showSystemUI(call: MethodCall, result: MethodChannel.Result)

    abstract fun isCutoutAware(call: MethodCall, result: MethodChannel.Result)

    abstract fun getCutoutInsets(call: MethodCall, result: MethodChannel.Result)

    abstract fun supportsWideGamut(call: MethodCall, result: MethodChannel.Result)

    abstract fun supportsHdr(call: MethodCall, result: MethodChannel.Result)

    abstract fun isInWideColorGamutMode(call: MethodCall, result: MethodChannel.Result)

    abstract fun isInHdrMode(call: MethodCall, result: MethodChannel.Result)

    abstract fun getDisplayHdrSdrRatio(call: MethodCall, result: MethodChannel.Result)

    abstract fun getDesiredHdrHeadroom(call: MethodCall, result: MethodChannel.Result)

    abstract fun setColorMode(call: MethodCall, result: MethodChannel.Result)

    abstract fun startGlobalDrag(call: MethodCall, result: MethodChannel.Result)

    companion object {
        private val LOG_TAG = LogUtils.createTag<WindowHandler>()
        const val CHANNEL = "deckers.thibault/aves/window"
    }
}
