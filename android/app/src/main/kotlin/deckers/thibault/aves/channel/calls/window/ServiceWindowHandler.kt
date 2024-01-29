package deckers.thibault.aves.channel.calls.window

import android.app.Service
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ServiceWindowHandler(service: Service) : WindowHandler(service) {
    override fun isActivity(call: MethodCall, result: MethodChannel.Result) {
        result.success(false)
    }

    override fun keepScreenOn(call: MethodCall, result: MethodChannel.Result) {
        result.success(null)
    }

    override fun secureScreen(call: MethodCall, result: MethodChannel.Result) {
        result.success(null)
    }

    override fun requestOrientation(call: MethodCall, result: MethodChannel.Result) {
        result.success(false)
    }

    override fun isCutoutAware(call: MethodCall, result: MethodChannel.Result) {
        result.success(false)
    }

    override fun getCutoutInsets(call: MethodCall, result: MethodChannel.Result) {
        result.success(HashMap<String, Any>())
    }

    override fun supportsHdr(call: MethodCall, result: MethodChannel.Result) {
        result.success(false)
    }

    override fun setHdrColorMode(call: MethodCall, result: MethodChannel.Result) {
        result.success(null)
    }
}