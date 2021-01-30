package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.graphics.Rect
import android.net.Uri
import android.util.Size
import com.bumptech.glide.Glide
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.channel.calls.Coresult.Companion.safesus
import deckers.thibault.aves.channel.calls.fetchers.RegionFetcher
import deckers.thibault.aves.channel.calls.fetchers.ThumbnailFetcher
import deckers.thibault.aves.channel.calls.fetchers.TiffRegionFetcher
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.provider.ImageProvider.ImageOpCallback
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import deckers.thibault.aves.utils.MimeTypes
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

class ImageFileHandler(private val activity: Activity) : MethodCallHandler {
    private val density = activity.resources.displayMetrics.density

    private val regionFetcher = RegionFetcher(activity)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getObsoleteEntries" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getObsoleteEntries) }
            "getEntry" -> GlobalScope.launch(Dispatchers.IO) { safesus(call, result, ::getEntry) }
            "getThumbnail" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getThumbnail) }
            "getRegion" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getRegion) }
            "clearSizedThumbnailDiskCache" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::clearSizedThumbnailDiskCache) }
            "rename" -> GlobalScope.launch(Dispatchers.IO) { safesus(call, result, ::rename) }
            "rotate" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::rotate) }
            "flip" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::flip) }
            else -> result.notImplemented()
        }
    }

    private fun getObsoleteEntries(call: MethodCall, result: MethodChannel.Result) {
        val known = call.argument<List<Int>>("knownContentIds")
        if (known == null) {
            result.error("getObsoleteEntries-args", "failed because of missing arguments", null)
            return
        }
        result.success(MediaStoreImageProvider().getObsoleteContentIds(activity, known))
    }

    private fun getThumbnail(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")
        val mimeType = call.argument<String>("mimeType")
        val dateModifiedSecs = call.argument<Number>("dateModifiedSecs")?.toLong()
        val rotationDegrees = call.argument<Int>("rotationDegrees")
        val isFlipped = call.argument<Boolean>("isFlipped")
        val widthDip = call.argument<Double>("widthDip")
        val heightDip = call.argument<Double>("heightDip")
        val pageId = call.argument<Int>("pageId")
        val defaultSizeDip = call.argument<Double>("defaultSizeDip")

        if (uri == null || mimeType == null || dateModifiedSecs == null || rotationDegrees == null || isFlipped == null || widthDip == null || heightDip == null || defaultSizeDip == null) {
            result.error("getThumbnail-args", "failed because of missing arguments", null)
            return
        }

        // convert DIP to physical pixels here, instead of using `devicePixelRatio` in Flutter
        ThumbnailFetcher(
            activity,
            uri,
            mimeType,
            dateModifiedSecs,
            rotationDegrees,
            isFlipped,
            width = (widthDip * density).roundToInt(),
            height = (heightDip * density).roundToInt(),
            pageId = pageId,
            defaultSize = (defaultSizeDip * density).roundToInt(),
            result,
        ).fetch()
    }

    private fun getRegion(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val mimeType = call.argument<String>("mimeType")
        val pageId = call.argument<Int>("pageId")
        val sampleSize = call.argument<Int>("sampleSize")
        val x = call.argument<Int>("regionX")
        val y = call.argument<Int>("regionY")
        val width = call.argument<Int>("regionWidth")
        val height = call.argument<Int>("regionHeight")
        val imageWidth = call.argument<Int>("imageWidth")
        val imageHeight = call.argument<Int>("imageHeight")

        if (uri == null || mimeType == null || sampleSize == null || x == null || y == null || width == null || height == null || imageWidth == null || imageHeight == null) {
            result.error("getRegion-args", "failed because of missing arguments", null)
            return
        }

        val regionRect = Rect(x, y, x + width, y + height)
        when (mimeType) {
            MimeTypes.TIFF -> TiffRegionFetcher(activity).fetch(
                uri = uri,
                page = pageId ?: 0,
                sampleSize = sampleSize,
                regionRect = regionRect,
                result = result,
            )
            else -> regionFetcher.fetch(
                uri = uri,
                mimeType = mimeType,
                pageId = pageId,
                sampleSize = sampleSize,
                regionRect = regionRect,
                imageSize = Size(imageWidth, imageHeight),
                result = result,
            )
        }
    }

    private suspend fun getEntry(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType") // MIME type is optional
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (uri == null) {
            result.error("getEntry-args", "failed because of missing arguments", null)
            return
        }

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("getEntry-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.fetchSingle(activity, uri, mimeType, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("getEntry-failure", "failed to get entry for uri=$uri", throwable.message)
        })
    }

    private fun clearSizedThumbnailDiskCache(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        Glide.get(activity).clearDiskCache()
        result.success(null)
    }

    private suspend fun rename(call: MethodCall, result: MethodChannel.Result) {
        val entryMap = call.argument<FieldMap>("entry")
        val newName = call.argument<String>("newName")
        if (entryMap == null || newName == null) {
            result.error("rename-args", "failed because of missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("rename-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("rename-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.rename(activity, path, uri, mimeType, newName, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("rename-failure", "failed to rename", throwable.message)
        })
    }

    private fun rotate(call: MethodCall, result: MethodChannel.Result) {
        val clockwise = call.argument<Boolean>("clockwise")
        if (clockwise == null) {
            result.error("rotate-args", "failed because of missing arguments", null)
            return
        }

        val op = if (clockwise) ExifOrientationOp.ROTATE_CW else ExifOrientationOp.ROTATE_CCW
        changeOrientation(call, result, op)
    }

    private fun flip(call: MethodCall, result: MethodChannel.Result) {
        changeOrientation(call, result, ExifOrientationOp.FLIP)
    }

    private fun changeOrientation(call: MethodCall, result: MethodChannel.Result, op: ExifOrientationOp) {
        val entryMap = call.argument<FieldMap>("entry")
        if (entryMap == null) {
            result.error("changeOrientation-args", "failed because of missing arguments", null)
            return
        }

        val uri = (entryMap["uri"] as String?)?.let { Uri.parse(it) }
        val path = entryMap["path"] as String?
        val mimeType = entryMap["mimeType"] as String?
        if (uri == null || path == null || mimeType == null) {
            result.error("changeOrientation-args", "failed because entry fields are missing", null)
            return
        }

        val provider = getProvider(uri)
        if (provider == null) {
            result.error("changeOrientation-provider", "failed to find provider for uri=$uri", null)
            return
        }

        provider.changeOrientation(activity, path, uri, mimeType, op, object : ImageOpCallback {
            override fun onSuccess(fields: FieldMap) = result.success(fields)
            override fun onFailure(throwable: Throwable) = result.error("changeOrientation-failure", "failed to change orientation", throwable.message)
        })
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/image"
    }
}