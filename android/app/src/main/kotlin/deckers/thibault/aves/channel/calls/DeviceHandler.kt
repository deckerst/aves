package deckers.thibault.aves.channel.calls

import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.location.Geocoder
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.content.pm.ShortcutManagerCompat
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.model.FieldMap
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class DeviceHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canManageMedia" -> safe(call, result, ::canManageMedia)
            "getCapabilities" -> safe(call, result, ::getCapabilities)
            "getDefaultTimeZoneRawOffsetMillis" -> safe(call, result, ::getDefaultTimeZoneRawOffsetMillis)
            "getLocales" -> safe(call, result, ::getLocales)
            "getPerformanceClass" -> safe(call, result, ::getPerformanceClass)
            "isSystemFilePickerEnabled" -> safe(call, result, ::isSystemFilePickerEnabled)
            "requestMediaManagePermission" -> safe(call, result, ::requestMediaManagePermission)
            else -> result.notImplemented()
        }
    }

    private fun canManageMedia(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaStore.canManageMedia(context) else false)
    }

    private fun getCapabilities(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val sdkInt = Build.VERSION.SDK_INT
        result.success(
            hashMapOf(
                "canGrantDirectoryAccess" to (sdkInt >= Build.VERSION_CODES.LOLLIPOP),
                "canPinShortcut" to ShortcutManagerCompat.isRequestPinShortcutSupported(context),
                "canRenderFlagEmojis" to (sdkInt >= Build.VERSION_CODES.M),
                "canRenderSubdivisionFlagEmojis" to (sdkInt >= Build.VERSION_CODES.O),
                "canRequestManageMedia" to (sdkInt >= Build.VERSION_CODES.S),
                "canSetLockScreenWallpaper" to (sdkInt >= Build.VERSION_CODES.N),
                "canUseCrypto" to (sdkInt >= Build.VERSION_CODES.LOLLIPOP),
                "hasGeocoder" to Geocoder.isPresent(),
                "isDynamicColorAvailable" to (sdkInt >= Build.VERSION_CODES.S),
                "showPinShortcutFeedback" to (sdkInt >= Build.VERSION_CODES.O),
                "supportEdgeToEdgeUIMode" to (sdkInt >= Build.VERSION_CODES.Q),
            )
        )
    }

    private fun getDefaultTimeZoneRawOffsetMillis(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(TimeZone.getDefault().rawOffset)
    }

    private fun getLocales(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        fun toMap(locale: Locale): FieldMap {
            val fields: HashMap<String, Any?> = hashMapOf(
                "language" to locale.language,
                "country" to locale.country,
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                fields["script"] = locale.script
            }
            return fields
        }

        val locales = ArrayList<FieldMap>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // when called from a window-less service, locales from `context.resources`
            // do not reflect the current system settings, so we use `Resources.getSystem()` instead
            val list = Resources.getSystem().configuration.locales
            for (i in 0 until list.size()) {
                locales.add(toMap(list.get(i)))
            }
        } else {
            locales.add(toMap(Locale.getDefault()))
        }
        result.success(locales)
    }

    private fun getPerformanceClass(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val performanceClass = Build.VERSION.MEDIA_PERFORMANCE_CLASS
            if (performanceClass > 0) {
                result.success(performanceClass)
                return
            }
        }
        result.success(Build.VERSION.SDK_INT)
    }

    private fun isSystemFilePickerEnabled(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val enabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).resolveActivity(context.packageManager) != null
        } else {
            false
        }
        result.success(enabled)
    }

    private fun requestMediaManagePermission(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            result.error("requestMediaManagePermission-unsupported", "media management permission is not available before Android 12", null)
            return
        }

        val intent = Intent(Settings.ACTION_REQUEST_MANAGE_MEDIA, Uri.parse("package:${context.packageName}"))
        context.startActivity(intent)
        result.success(true)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/device"
    }
}