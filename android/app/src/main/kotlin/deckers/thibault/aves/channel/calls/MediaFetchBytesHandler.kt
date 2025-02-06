package deckers.thibault.aves.channel.calls

import android.content.Context
import android.graphics.Rect
import androidx.core.net.toUri
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.channel.calls.fetchers.RegionFetcher
import deckers.thibault.aves.channel.calls.fetchers.SvgRegionFetcher
import deckers.thibault.aves.channel.calls.fetchers.ThumbnailFetcher
import deckers.thibault.aves.channel.calls.fetchers.TiffRegionFetcher
import deckers.thibault.aves.utils.MimeTypes
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.util.Date
import kotlin.math.roundToInt

class MediaFetchBytesHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val density = context.resources.displayMetrics.density

    private val regionFetcher = RegionFetcher(context)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getThumbnail" -> ioScope.launch { safeSuspend(call, result, ::getThumbnail) }
            "getRegion" -> ioScope.launch { safeSuspend(call, result, ::getRegion) }
            else -> result.notImplemented()
        }
    }

    private suspend fun getThumbnail(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")
        val mimeType = call.argument<String>("mimeType")
        val dateModifiedSecs = call.argument<Number>("dateModifiedSecs")?.toLong()
        val rotationDegrees = call.argument<Int>("rotationDegrees")
        val isFlipped = call.argument<Boolean>("isFlipped")
        val widthDip = call.argument<Number>("widthDip")?.toDouble()
        val heightDip = call.argument<Number>("heightDip")?.toDouble()
        val pageId = call.argument<Int>("pageId")
        val defaultSizeDip = call.argument<Number>("defaultSizeDip")?.toDouble()
        val quality = call.argument<Int>("quality")

        if (uri == null || mimeType == null || rotationDegrees == null || isFlipped == null || widthDip == null || heightDip == null || defaultSizeDip == null || quality == null) {
            result.error("getThumbnail-args", "missing arguments", null)
            return
        }

        // convert DIP to physical pixels here, instead of using `devicePixelRatio` in Flutter
        ThumbnailFetcher(
            context = context,
            uri = uri,
            mimeType = mimeType,
            dateModifiedSecs = dateModifiedSecs ?: (Date().time / 1000),
            rotationDegrees = rotationDegrees,
            isFlipped = isFlipped,
            width = (widthDip * density).roundToInt(),
            height = (heightDip * density).roundToInt(),
            pageId = pageId,
            defaultSize = (defaultSizeDip * density).roundToInt(),
            quality = quality,
            result = result,
        ).fetch()
    }

    private suspend fun getRegion(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.toUri()
        val mimeType = call.argument<String>("mimeType")
        val pageId = call.argument<Int>("pageId")
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val sampleSize = call.argument<Int>("sampleSize")
        val x = call.argument<Int>("regionX")
        val y = call.argument<Int>("regionY")
        val width = call.argument<Int>("regionWidth")
        val height = call.argument<Int>("regionHeight")
        val imageWidth = call.argument<Int>("imageWidth")
        val imageHeight = call.argument<Int>("imageHeight")

        if (uri == null || mimeType == null || sampleSize == null || x == null || y == null || width == null || height == null || imageWidth == null || imageHeight == null) {
            result.error("getRegion-args", "missing arguments", null)
            return
        }

        val regionRect = Rect(x, y, x + width, y + height)
        when (mimeType) {
            MimeTypes.SVG -> SvgRegionFetcher(context).fetch(
                uri = uri,
                sizeBytes = sizeBytes,
                scale = sampleSize,
                regionRect = regionRect,
                imageWidth = imageWidth,
                imageHeight = imageHeight,
                result = result,
            )
            MimeTypes.TIFF -> TiffRegionFetcher(context).fetch(
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
                imageWidth = imageWidth,
                imageHeight = imageHeight,
                result = result,
            )
        }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/media_fetch_bytes"
    }
}