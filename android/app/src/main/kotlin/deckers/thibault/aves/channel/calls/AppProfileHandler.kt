package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.content.Context
import android.content.pm.CrossProfileApps
import android.os.Build
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class AppProfileHandler(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canInteractAcrossProfiles" -> safe(call, result, ::canInteractAcrossProfiles)
            "canRequestInteractAcrossProfiles" -> safe(call, result, ::canRequestInteractAcrossProfiles)
            "requestInteractAcrossProfiles" -> safe(call, result, ::requestInteractAcrossProfiles)
            "switchProfile" -> safe(call, result, ::switchProfile)
            "getProfileSwitchingLabel" -> safe(call, result, ::getProfileSwitchingLabel)
            "getTargetUserProfiles" -> safe(call, result, ::getTargetUserProfiles)
            else -> result.notImplemented()
        }
    }

    private fun canInteractAcrossProfiles(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(false)
            return
        }

        val crossProfileApps = activity.getSystemService(Context.CROSS_PROFILE_APPS_SERVICE) as? CrossProfileApps
        val canInteract = crossProfileApps?.canInteractAcrossProfiles() ?: false
        result.success(canInteract)
    }

    private fun canRequestInteractAcrossProfiles(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(false)
            return
        }

        val crossProfileApps = activity.getSystemService(Context.CROSS_PROFILE_APPS_SERVICE) as? CrossProfileApps
        val canRequest = crossProfileApps?.canRequestInteractAcrossProfiles() ?: false
        result.success(canRequest)
    }

    private fun requestInteractAcrossProfiles(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(false)
            return
        }

        val crossProfileApps = activity.getSystemService(Context.CROSS_PROFILE_APPS_SERVICE) as? CrossProfileApps
        if (crossProfileApps == null) {
            result.error("requestInteractAcrossProfiles-service", "cross profile apps service unavailable", null)
            return
        }

        val intent = crossProfileApps.createRequestInteractAcrossProfilesIntent()
        val started = activity.startActivity(intent)

        result.success(started)
    }

    private fun switchProfile(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.success(false)
            return
        }

        val crossProfileApps = activity.getSystemService(Context.CROSS_PROFILE_APPS_SERVICE) as? CrossProfileApps
        if (crossProfileApps == null) {
            result.error("switchProfile-service", "cross profile apps service unavailable", null)
            return
        }

        val userHandles = crossProfileApps.targetUserProfiles
        crossProfileApps.startMainActivity(activity.componentName, userHandles.first())
        result.success(null)
    }

    private fun getProfileSwitchingLabel(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.success(null)
            return
        }

        val crossProfileApps = activity.getSystemService(Context.CROSS_PROFILE_APPS_SERVICE) as? CrossProfileApps
        if (crossProfileApps == null) {
            result.error("getProfileSwitchingLabel-service", "cross profile apps service unavailable", null)
            return
        }

        val userHandles = crossProfileApps.targetUserProfiles
        val label = if (userHandles.isEmpty()) "" else crossProfileApps.getProfileSwitchingLabel(userHandles.first())

        result.success(label)
    }

    private fun getTargetUserProfiles(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.success(false)
            return
        }

        val crossProfileApps = activity.getSystemService(Context.CROSS_PROFILE_APPS_SERVICE) as? CrossProfileApps
        if (crossProfileApps == null) {
            result.error("getTargetUserProfiles-service", "cross profile apps service unavailable", null)
            return
        }

        val userProfiles = crossProfileApps.targetUserProfiles.map { it.toString() }.toList()
        result.success(userProfiles)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/app_profile"
    }
}
