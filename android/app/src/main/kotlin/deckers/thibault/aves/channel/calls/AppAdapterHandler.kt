package deckers.thibault.aves.channel.calls

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.util.*
import kotlin.collections.ArrayList
import kotlin.math.roundToInt

class AppAdapterHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPackages" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getPackages) }
            "getAppIcon" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getAppIcon) }
            "edit" -> {
                val title = call.argument<String>("title")
                val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
                val mimeType = call.argument<String>("mimeType")
                result.success(edit(title, uri, mimeType))
            }
            "open" -> {
                val title = call.argument<String>("title")
                val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
                val mimeType = call.argument<String>("mimeType")
                result.success(open(title, uri, mimeType))
            }
            "openMap" -> {
                val geoUri = call.argument<String>("geoUri")?.let { Uri.parse(it) }
                result.success(openMap(geoUri))
            }
            "setAs" -> {
                val title = call.argument<String>("title")
                val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
                val mimeType = call.argument<String>("mimeType")
                result.success(setAs(title, uri, mimeType))
            }
            "share" -> {
                val title = call.argument<String>("title")
                val urisByMimeType = call.argument<Map<String, List<String>>>("urisByMimeType")!!
                result.success(shareMultiple(title, urisByMimeType))
            }
            else -> result.notImplemented()
        }
    }

    private fun getPackages(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        val packages = HashMap<String, FieldMap>()

        fun addPackageDetails(intent: Intent) {
            // apps tend to use their name in English when creating folders
            // so we get their names in English as well as the current locale
            val englishConfig = Configuration().apply { setLocale(Locale.ENGLISH) }

            val pm = context.packageManager
            for (resolveInfo in pm.queryIntentActivities(intent, 0)) {
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
                            @Suppress("DEPRECATION")
                            resources.updateConfiguration(englishConfig, resources.displayMetrics)
                            englishLabel = resources.getString(labelRes)
                        } catch (e: PackageManager.NameNotFoundException) {
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

        addPackageDetails(Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER))
        addPackageDetails(Intent(Intent.ACTION_MAIN))
        result.success(ArrayList(packages.values))
    }

    private fun getAppIcon(call: MethodCall, result: MethodChannel.Result) {
        val packageName = call.argument<String>("packageName")
        val sizeDip = call.argument<Double>("sizeDip")
        if (packageName == null || sizeDip == null) {
            result.error("getAppIcon-args", "failed because of missing arguments", null)
            return
        }

        // convert DIP to physical pixels here, instead of using `devicePixelRatio` in Flutter
        val density = context.resources.displayMetrics.density
        val size = (sizeDip * density).roundToInt()
        var data: ByteArray? = null
        try {
            val iconResourceId = context.packageManager.getApplicationInfo(packageName, 0).icon
            val uri = Uri.Builder()
                .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                .authority(packageName)
                .path(iconResourceId.toString())
                .build()

            val options = RequestOptions()
                .format(DecodeFormat.PREFER_RGB_565)
                .override(size, size)
            val target = Glide.with(context)
                .asBitmap()
                .apply(options)
                .load(uri)
                .submit(size, size)

            try {
                data = target.get()?.getBytes(canHaveAlpha = true, recycle = false)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to decode app icon for packageName=$packageName", e)
            }
            Glide.with(context).clear(target)
        } catch (e: PackageManager.NameNotFoundException) {
            Log.w(LOG_TAG, "failed to get app info for packageName=$packageName", e)
            return
        }
        if (data != null) {
            result.success(data)
        } else {
            result.error("getAppIcon-null", "failed to get icon for packageName=$packageName", null)
        }
    }

    private fun edit(title: String?, uri: Uri?, mimeType: String?): Boolean {
        uri ?: return false

        val intent = Intent(Intent.ACTION_EDIT)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            .setDataAndType(getShareableUri(uri), mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun open(title: String?, uri: Uri?, mimeType: String?): Boolean {
        uri ?: return false

        val intent = Intent(Intent.ACTION_VIEW)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .setDataAndType(getShareableUri(uri), mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun openMap(geoUri: Uri?): Boolean {
        geoUri ?: return false

        val intent = Intent(Intent.ACTION_VIEW, geoUri)
        return safeStartActivity(intent)
    }

    private fun setAs(title: String?, uri: Uri?, mimeType: String?): Boolean {
        uri ?: return false

        val intent = Intent(Intent.ACTION_ATTACH_DATA)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .setDataAndType(getShareableUri(uri), mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun shareSingle(title: String?, uri: Uri, mimeType: String): Boolean {
        val intent = Intent(Intent.ACTION_SEND)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .setType(mimeType)
            .putExtra(Intent.EXTRA_STREAM, getShareableUri(uri))
        return safeStartActivityChooser(title, intent)
    }

    private fun shareMultiple(title: String?, urisByMimeType: Map<String, List<String>>?): Boolean {
        urisByMimeType ?: return false

        val uriList = ArrayList(urisByMimeType.values.flatten().mapNotNull { Uri.parse(it) })
        val mimeTypes = urisByMimeType.keys.toTypedArray()

        // simplify share intent for a single item, as some apps can handle one item but not more
        if (uriList.size == 1) {
            return shareSingle(title, uriList.first(), mimeTypes.first())
        }

        var mimeType = "*/*"
        if (mimeTypes.size == 1) {
            // items have the same mime type & subtype
            mimeType = mimeTypes.first()
        } else {
            // items have different subtypes
            val mimeTypeTypes = mimeTypes.map { it.split("/") }.distinct()
            if (mimeTypeTypes.size == 1) {
                // items have the same mime type
                mimeType = "${mimeTypeTypes.first()}/*"
            }
        }

        val intent = Intent(Intent.ACTION_SEND_MULTIPLE)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList)
            .setType(mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun safeStartActivity(intent: Intent): Boolean {
        if (intent.resolveActivity(context.packageManager) == null) return false
        try {
            context.startActivity(intent)
            return true
        } catch (e: SecurityException) {
            Log.w(LOG_TAG, "failed to start activity for intent=$intent", e)
        }
        return false
    }

    private fun safeStartActivityChooser(title: String?, intent: Intent): Boolean {
        if (intent.resolveActivity(context.packageManager) == null) return false
        try {
            context.startActivity(Intent.createChooser(intent, title))
            return true
        } catch (e: SecurityException) {
            Log.w(LOG_TAG, "failed to start activity chooser for intent=$intent", e)
        }
        return false
    }

    private fun getShareableUri(uri: Uri): Uri? {
        return when (uri.scheme?.toLowerCase(Locale.ROOT)) {
            ContentResolver.SCHEME_FILE -> {
                uri.path?.let { path ->
                    val applicationId = context.applicationContext.packageName
                    FileProvider.getUriForFile(context, "$applicationId.fileprovider", File(path))
                }
            }
            else -> uri
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag(AppAdapterHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/app"
    }
}