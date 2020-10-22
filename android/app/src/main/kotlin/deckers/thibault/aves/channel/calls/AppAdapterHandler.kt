package deckers.thibault.aves.channel.calls

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Bitmap
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.utils.LogUtils.createTag
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.*
import kotlin.collections.ArrayList
import kotlin.math.roundToInt

class AppAdapterHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAppIcon" -> GlobalScope.launch { getAppIcon(call, Coresult(result)) }
            "getAppNames" -> GlobalScope.launch { getAppNames(Coresult(result)) }
            "getEnv" -> result.success(System.getenv())
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

    private fun getAppNames(result: MethodChannel.Result) {
        val nameMap = HashMap<String, String>()
        val intent = Intent(Intent.ACTION_MAIN, null)
            .addCategory(Intent.CATEGORY_LAUNCHER)
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)

        // apps tend to use their name in English when creating folders
        // so we get their names in English as well as the current locale
        val englishConfig = Configuration().apply { setLocale(Locale.ENGLISH) }

        val pm = context.packageManager
        for (resolveInfo in pm.queryIntentActivities(intent, 0)) {
            val ai = resolveInfo.activityInfo.applicationInfo
            val isSystemPackage = ai.flags and ApplicationInfo.FLAG_SYSTEM != 0
            if (!isSystemPackage) {
                val packageName = ai.packageName

                val currentLabel = pm.getApplicationLabel(ai).toString()
                nameMap[currentLabel] = packageName

                val labelRes = ai.labelRes
                if (labelRes != 0) {
                    try {
                        val resources = pm.getResourcesForApplication(ai)
                        // `updateConfiguration` is deprecated but it seems to be the only way
                        // to query resources from another app with a specific locale.
                        // The following methods do not work:
                        // - `resources.getConfiguration().setLocale(...)`
                        // - getting a package manager from a custom context with `context.createConfigurationContext(config)`
                        @Suppress("DEPRECATION")
                        resources.updateConfiguration(englishConfig, resources.displayMetrics)
                        val englishLabel = resources.getString(labelRes)
                        nameMap[englishLabel] = packageName
                    } catch (e: PackageManager.NameNotFoundException) {
                        Log.w(LOG_TAG, "failed to get app label in English for packageName=$packageName", e)
                    }
                }
            }
        }
        result.success(nameMap)
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
                .centerCrop()
                .override(size, size)
            val target = Glide.with(context)
                .asBitmap()
                .apply(options)
                .load(uri)
                .submit(size, size)

            try {
                val bitmap = target.get()
                if (bitmap != null) {
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 0, stream)
                    data = stream.toByteArray()
                }
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
            .setDataAndType(uri, mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun open(title: String?, uri: Uri?, mimeType: String?): Boolean {
        uri ?: return false

        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, mimeType)
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
            .setDataAndType(uri, mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun shareSingle(title: String?, uri: Uri, mimeType: String): Boolean {
        val intent = Intent(Intent.ACTION_SEND)
            .setType(mimeType)
        when (uri.scheme?.toLowerCase(Locale.ROOT)) {
            ContentResolver.SCHEME_FILE -> {
                val path = uri.path ?: return false
                val applicationId = context.applicationContext.packageName
                val apkUri = FileProvider.getUriForFile(context, "$applicationId.fileprovider", File(path))
                intent.putExtra(Intent.EXTRA_STREAM, apkUri)
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            else -> intent.putExtra(Intent.EXTRA_STREAM, uri)
        }
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
            .putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList)
            .setType(mimeType)
        return safeStartActivityChooser(title, intent)
    }

    private fun safeStartActivity(intent: Intent): Boolean {
        val canResolve = intent.resolveActivity(context.packageManager) != null
        if (canResolve) {
            context.startActivity(intent)
        }
        return canResolve
    }

    private fun safeStartActivityChooser(title: String?, intent: Intent): Boolean {
        val canResolve = intent.resolveActivity(context.packageManager) != null
        if (canResolve) {
            context.startActivity(Intent.createChooser(intent, title))
        }
        return canResolve
    }

    companion object {
        private val LOG_TAG = createTag(AppAdapterHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/app"
    }
}