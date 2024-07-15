package deckers.thibault.aves.channel.calls

import android.content.*
import android.content.pm.ApplicationInfo
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.TransactionTooLargeException
import android.util.Log
import androidx.core.content.FileProvider
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.MainActivity.Companion.EXTRA_KEY_EXPLORER_PATH
import deckers.thibault.aves.MainActivity.Companion.EXTRA_KEY_FILTERS_ARRAY
import deckers.thibault.aves.MainActivity.Companion.EXTRA_KEY_FILTERS_STRING
import deckers.thibault.aves.MainActivity.Companion.EXTRA_KEY_PAGE
import deckers.thibault.aves.MainActivity.Companion.EXTRA_STRING_ARRAY_SEPARATOR
import deckers.thibault.aves.R
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.getApplicationInfoCompat
import deckers.thibault.aves.utils.queryIntentActivitiesCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.*
import kotlin.math.roundToInt

class AppAdapterHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPackages" -> ioScope.launch { safe(call, result, ::getPackages) }
            "getAppIcon" -> ioScope.launch { safeSuspend(call, result, ::getAppIcon) }
            "copyToClipboard" -> ioScope.launch { safe(call, result, ::copyToClipboard) }
            "open" -> safe(call, result, ::open)
            "openMap" -> safe(call, result, ::openMap)
            "setAs" -> safe(call, result, ::setAs)
            "share" -> safe(call, result, ::share)
            "pinShortcut" -> ioScope.launch { safe(call, result, ::pinShortcut) }
            else -> result.notImplemented()
        }
    }

    private fun getPackages(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val packages = HashMap<String, FieldMap>()

        fun addPackageDetails(intent: Intent) {
            // apps tend to use their name in English when creating directories
            // so we get their names in English as well as the current locale
            val englishConfig = Configuration().apply {
                setLocale(Locale.ENGLISH)
            }

            val pm = context.packageManager
            for (resolveInfo in pm.queryIntentActivitiesCompat(intent, 0)) {
                val appInfo = resolveInfo.activityInfo.applicationInfo
                val packageName = appInfo.packageName
                if (!packages.containsKey(packageName)) {
                    val currentLabel = pm.getApplicationLabel(appInfo).toString()
                    val englishLabel: String? = appInfo.labelRes.takeIf { it != 0 }?.let { labelRes ->
                        var englishLabel: String? = null
                        try {
                            val resources = pm.getResourcesForApplication(appInfo)
                            // `updateConfiguration` is deprecated but it seems to be the only way
                            // to query resources from another app with a specific locale.
                            // The following methods do not work:
                            // - `resources.getConfiguration().setLocale(...)`
                            // - getting a package manager from a custom context with `context.createConfigurationContext(config)`
                            @Suppress("deprecation")
                            resources.updateConfiguration(englishConfig, resources.displayMetrics)
                            englishLabel = resources.getString(labelRes)
                        } catch (e: Exception) {
                            Log.w(LOG_TAG, "failed to get app label in English for packageName=$packageName", e)
                        }
                        englishLabel
                    }
                    packages[packageName] = hashMapOf(
                        "packageName" to packageName,
                        "categoryLauncher" to intent.hasCategory(Intent.CATEGORY_LAUNCHER),
                        "isSystem" to (appInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0),
                        "currentLabel" to currentLabel,
                        "englishLabel" to englishLabel,
                    )
                }
            }
        }

        // identify launcher category packages, which typically include user apps
        // they should be fetched before the other packages, to be marked as launcher packages
        try {
            addPackageDetails(Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER))
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to list launcher packages", e)
        }

        try {
            // complete with all the other packages
            addPackageDetails(Intent(Intent.ACTION_MAIN))
        } catch (e: Exception) {
            // `PackageManager.queryIntentActivities()` may kill the package manager if the response is too large
            Log.w(LOG_TAG, "failed to list all packages", e)

            // fallback to the default category packages, which typically include system and OEM tools
            try {
                addPackageDetails(Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_DEFAULT))
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to list default packages", e)
            }
        }

        result.success(ArrayList(packages.values))
    }

    private suspend fun getAppIcon(call: MethodCall, result: MethodChannel.Result) {
        val packageName = call.argument<String>("packageName")
        val sizeDip = call.argument<Number>("sizeDip")?.toDouble()
        if (packageName == null || sizeDip == null) {
            result.error("getAppIcon-args", "missing arguments", null)
            return
        }

        // convert DIP to physical pixels here, instead of using `devicePixelRatio` in Flutter
        val density = context.resources.displayMetrics.density
        val size = (sizeDip * density).roundToInt()
        var data: ByteArray? = null
        try {
            val iconResourceId = context.packageManager.getApplicationInfoCompat(packageName, 0).icon
            if (iconResourceId != Resources.ID_NULL) {
                val uri = Uri.Builder()
                    .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                    .authority(packageName)
                    .path(iconResourceId.toString())
                    .build()

                val options = RequestOptions()
                    .format(DecodeFormat.PREFER_ARGB_8888)
                    .override(size, size)
                val target = Glide.with(context)
                    .asBitmap()
                    .apply(options)
                    .load(uri)
                    .submit(size, size)

                try {
                    val bitmap = withContext(Dispatchers.IO) { target.get() }
                    data = bitmap?.getBytes(canHaveAlpha = true, recycle = false)
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to decode app icon for packageName=$packageName", e)
                }
                Glide.with(context).clear(target)
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get app info for packageName=$packageName", e)
            return
        }
        if (data != null) {
            result.success(data)
        } else {
            result.error("getAppIcon-null", "failed to get icon for packageName=$packageName", null)
        }
    }

    private fun copyToClipboard(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val label = call.argument<String>("label")
        if (uri == null) {
            result.error("copyToClipboard-args", "missing arguments", null)
            return
        }

        // on older devices, `ClipboardManager` initialization must happen on the main thread
        // (e.g. Samsung S7 with Android 8.0 / API 26, but not on Tab A 10.1 with Android 8.1 / API 27)
        Handler(Looper.getMainLooper()).post {
            try {
                val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
                if (clipboard != null) {
                    val clip = ClipData.newUri(context.contentResolver, label, getShareableUri(context, uri))
                    clipboard.setPrimaryClip(clip)
                    result.success(true)
                } else {
                    result.success(false)
                }
            } catch (e: Exception) {
                result.error("copyToClipboard-exception", "failed to set clip", e.message)
            }
        }
    }

    private fun open(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val mimeType = call.argument<String>("mimeType")
        val forceChooser = call.argument<Boolean>("forceChooser")
        if (uri == null || forceChooser == null) {
            result.error("open-args", "missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_VIEW)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .setDataAndType(getShareableUri(context, uri), mimeType)
        val started = if (forceChooser) safeStartActivityChooser(title, intent) else safeStartActivity(intent)

        result.success(started)
    }

    private fun openMap(call: MethodCall, result: MethodChannel.Result) {
        val geoUri = call.argument<String>("geoUri")?.let { Uri.parse(it) }
        if (geoUri == null) {
            result.error("openMap-args", "missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_VIEW, geoUri)
        val started = safeStartActivity(intent)

        result.success(started)
    }

    private fun setAs(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val mimeType = call.argument<String>("mimeType")
        if (uri == null) {
            result.error("setAs-args", "missing arguments", null)
            return
        }

        val intent = Intent(Intent.ACTION_ATTACH_DATA)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .setDataAndType(getShareableUri(context, uri), mimeType)
        val started = safeStartActivityChooser(title, intent)

        result.success(started)
    }

    private fun share(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title")
        val urisByMimeType = call.argument<Map<String, List<String>>>("urisByMimeType")
        if (urisByMimeType == null) {
            result.error("share-args", "missing arguments", null)
            return
        }

        val uriList = ArrayList(urisByMimeType.values.flatten().mapNotNull { getShareableUri(context, Uri.parse(it)) })
        val mimeTypes = urisByMimeType.keys.toTypedArray()

        // simplify share intent for a single item, as some apps can handle one item but not more
        val intent = if (uriList.size == 1) {
            val uri = uriList.first()
            val mimeType = mimeTypes.first()

            Intent(Intent.ACTION_SEND)
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                .setType(mimeType)
                .putExtra(Intent.EXTRA_STREAM, uri)
        } else {
            var mimeType = "*/*"
            if (mimeTypes.size == 1) {
                // items have the same MIME type & subtype
                mimeType = mimeTypes.first()
            } else {
                // items have different subtypes
                val mimeTypeTypes = mimeTypes.map { it.split("/") }.distinct()
                if (mimeTypeTypes.size == 1) {
                    // items have the same MIME type
                    mimeType = "${mimeTypeTypes.first()}/*"
                }
            }

            Intent(Intent.ACTION_SEND_MULTIPLE)
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                .putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList)
                .setType(mimeType)
        }
        try {
            val started = safeStartActivityChooser(title, intent)
            result.success(started)
        } catch (e: Exception) {
            if (e is TransactionTooLargeException || e.cause is TransactionTooLargeException) {
                result.error("share-large", "transaction too large with ${uriList.size} URIs", e)
            } else {
                result.error("share-exception", "failed to share ${uriList.size} URIs", e)
            }
        }
    }

    private fun safeStartActivity(intent: Intent): Boolean {
        if (intent.resolveActivity(context.packageManager) == null) return false
        try {
            context.startActivity(intent)
            return true
        } catch (e: SecurityException) {
            if (intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION != 0) {
                // in some environments, providing the write flag yields a `SecurityException`:
                // "UID XXXX does not have permission to content://XXXX"
                // so we retry without it
                Log.i(LOG_TAG, "retry intent=$intent without FLAG_GRANT_WRITE_URI_PERMISSION")
                intent.flags = intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION.inv()
                return safeStartActivity(intent)
            } else {
                Log.w(LOG_TAG, "failed to start activity for intent=$intent", e)
            }
        }
        return false
    }

    private fun safeStartActivityChooser(title: String?, intent: Intent): Boolean {
        if (intent.resolveActivity(context.packageManager) == null) return false
        try {
            context.startActivity(Intent.createChooser(intent, title))
            return true
        } catch (e: SecurityException) {
            if (intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION != 0) {
                // in some environments, providing the write flag yields a `SecurityException`:
                // "UID XXXX does not have permission to content://XXXX"
                // so we retry without it
                Log.i(LOG_TAG, "retry intent=$intent without FLAG_GRANT_WRITE_URI_PERMISSION")
                intent.flags = intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION.inv()
                return safeStartActivityChooser(title, intent)
            } else {
                Log.w(LOG_TAG, "failed to start activity chooser for intent=$intent", e)
            }
        }
        return false
    }

    // shortcuts

    private fun pinShortcut(call: MethodCall, result: MethodChannel.Result) {
        val label = call.argument<String>("label")
        val iconBytes = call.argument<ByteArray>("iconBytes")
        val filters = call.argument<List<String>>("filters")
        val explorerPath = call.argument<String>("explorerPath")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (label == null) {
            result.error("pin-args", "missing arguments", null)
            return
        }

        if (!ShortcutManagerCompat.isRequestPinShortcutSupported(context)) {
            result.error("pin-unsupported", "failed because the launcher does not support pinning shortcuts", null)
            return
        }

        var icon: IconCompat? = null
        if (iconBytes?.isNotEmpty() == true) {
            var bitmap = BitmapFactory.decodeByteArray(iconBytes, 0, iconBytes.size)
            bitmap = BitmapUtils.centerSquareCrop(context, bitmap, 256)
            if (bitmap != null) {
                // adaptive, so the bitmap is used as background and covers the whole icon
                icon = IconCompat.createWithAdaptiveBitmap(bitmap)
            }
        }
        if (icon == null) {
            // shortcut adaptive icons are placed in `mipmap`, not `drawable`,
            // so that foreground is rendered at the intended scale
            val supportAdaptiveIcon = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

            icon = IconCompat.createWithResource(context, if (supportAdaptiveIcon) R.mipmap.ic_shortcut_collection else R.drawable.ic_shortcut_collection)
        }

        val intent = when {
            filters != null -> Intent(Intent.ACTION_MAIN, null, context, MainActivity::class.java)
                .putExtra(EXTRA_KEY_PAGE, "/collection")
                .putExtra(EXTRA_KEY_FILTERS_ARRAY, filters.toTypedArray())
                // on API 25, `String[]` or `ArrayList` extras are null when using the shortcut
                // so we use a joined `String` as fallback
                .putExtra(EXTRA_KEY_FILTERS_STRING, filters.joinToString(EXTRA_STRING_ARRAY_SEPARATOR))

            explorerPath != null -> Intent(Intent.ACTION_MAIN, null, context, MainActivity::class.java)
                .putExtra(EXTRA_KEY_PAGE, "/explorer")
                .putExtra(EXTRA_KEY_EXPLORER_PATH, explorerPath)

            uri != null -> Intent(Intent.ACTION_VIEW, uri, context, MainActivity::class.java)
            else -> {
                result.error("pin-intent", "failed to build intent", null)
                return
            }
        }

        // multiple shortcuts sharing the same ID cannot be created with different labels or icons
        // so we provide a unique ID for each one, and let the user manage duplicates (i.e. same filter set), if any
        val shortcut = ShortcutInfoCompat.Builder(context, UUID.randomUUID().toString())
            .setShortLabel(label)
            .setIcon(icon)
            .setIntent(intent)
            .build()
        ShortcutManagerCompat.requestPinShortcut(context, shortcut, null)

        result.success(true)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AppAdapterHandler>()
        const val CHANNEL = "deckers.thibault/aves/app"

        fun getShareableUri(context: Context, uri: Uri): Uri? {
            return when (uri.scheme?.lowercase(Locale.ROOT)) {
                ContentResolver.SCHEME_FILE -> {
                    uri.path?.let { path ->
                        val authority = "${context.applicationContext.packageName}.file_provider"
                        FileProvider.getUriForFile(context, authority, File(path))
                    }
                }

                else -> uri
            }
        }
    }
}
