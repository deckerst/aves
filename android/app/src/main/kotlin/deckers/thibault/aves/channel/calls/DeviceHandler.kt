package deckers.thibault.aves.channel.calls

import android.annotation.SuppressLint
import android.app.LocaleConfig
import android.app.LocaleManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Resources
import android.location.Geocoder
import android.os.Build
import android.os.LocaleList
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.net.toUri
import com.google.android.material.color.DynamicColors
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.MemoryUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.util.Locale

class DeviceHandler(private val context: Context) : MethodCallHandler {
    private val defaultScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canManageMedia" -> safe(call, result, ::canManageMedia)
            "getCapabilities" -> defaultScope.launch { safe(call, result, ::getCapabilities) }
            "getLocales" -> safe(call, result, ::getLocales)
            "setLocaleConfig" -> safe(call, result, ::setLocaleConfig)
            "getPerformanceClass" -> safe(call, result, ::getPerformanceClass)
            "isLocked" -> safe(call, result, ::isLocked)
            "isSystemFilePickerEnabled" -> safe(call, result, ::isSystemFilePickerEnabled)
            "requestMediaManagePermission" -> safe(call, result, ::requestMediaManagePermission)
            "getAvailableHeapSize" -> safe(call, result, ::getAvailableHeapSize)
            "requestGarbageCollection" -> safe(call, result, ::requestGarbageCollection)
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
                "canPinShortcut" to ShortcutManagerCompat.isRequestPinShortcutSupported(context),
                "canRenderFlagEmojis" to (sdkInt >= Build.VERSION_CODES.M),
                "canRenderSubdivisionFlagEmojis" to (sdkInt >= Build.VERSION_CODES.O),
                "canRequestManageMedia" to (sdkInt >= Build.VERSION_CODES.S),
                "canSetLockScreenWallpaper" to (sdkInt >= Build.VERSION_CODES.N),
                "hasGeocoder" to Geocoder.isPresent(),
                "isDynamicColorAvailable" to DynamicColors.isDynamicColorAvailable(),
                "showPinShortcutFeedback" to (sdkInt >= Build.VERSION_CODES.O),
                "supportEdgeToEdgeUIMode" to (sdkInt >= Build.VERSION_CODES.Q),
                "supportPictureInPicture" to supportPictureInPicture(),
            )
        )
    }

    private fun supportPictureInPicture(): Boolean {
        // minimum version for `PictureInPictureParams.Builder#setAutoEnterEnabled`
        val supportPipOnLeave = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
        return supportPipOnLeave && context.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
    }

    private fun getLocales(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        fun toMap(locale: Locale): FieldMap = hashMapOf(
            "language" to locale.language,
            "country" to locale.country,
            "script" to locale.script,
        )

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

    private fun setLocaleConfig(call: MethodCall, result: MethodChannel.Result) {
        val locales = call.argument<List<String>>("locales")
        if (locales.isNullOrEmpty()) {
            result.error("setLocaleConfig-args", "missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            @SuppressLint("WrongConstant")
            val lm = context.getSystemService(Context.LOCALE_SERVICE) as? LocaleManager
            lm?.overrideLocaleConfig = LocaleConfig(LocaleList.forLanguageTags(locales.joinToString(",")))
        }

        result.success(true)
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

    private fun isLocked(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as android.app.KeyguardManager
        val isLocked = keyguardManager.isKeyguardLocked
        result.success(isLocked)
    }

    private fun isSystemFilePickerEnabled(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val enabled = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).resolveActivity(context.packageManager) != null
        result.success(enabled)
    }

    private fun requestMediaManagePermission(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            result.error("requestMediaManagePermission-unsupported", "media management permission is not available before Android 12", null)
            return
        }

        val intent = Intent(Settings.ACTION_REQUEST_MANAGE_MEDIA, "package:${context.packageName}".toUri())
        context.startActivity(intent)
        result.success(true)
    }

    private fun getAvailableHeapSize(@Suppress("unused_parameter") methodCall: MethodCall, result: MethodChannel.Result) {
        result.success(MemoryUtils.getAvailableHeapSize())
    }

    private fun requestGarbageCollection(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        Runtime.getRuntime().gc()
        result.success(true)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/device"
    }
}