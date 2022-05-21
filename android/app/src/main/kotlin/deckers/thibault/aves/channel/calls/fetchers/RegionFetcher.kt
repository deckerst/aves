package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapRegionDecoder
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.decoder.MultiTrackImage
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.math.roundToInt

class RegionFetcher internal constructor(
    private val context: Context,
) {
    private var lastDecoderRef: LastDecoderRef? = null

    private val pageTempUris = HashMap<Pair<Uri, Int>, Uri>()

    private val multiTrackGlideOptions = RequestOptions()
        .format(DecodeFormat.PREFER_ARGB_8888)
        .diskCacheStrategy(DiskCacheStrategy.NONE)
        .skipMemoryCache(true)

    suspend fun fetch(
        uri: Uri,
        mimeType: String,
        pageId: Int?,
        sampleSize: Int,
        regionRect: Rect,
        imageWidth: Int,
        imageHeight: Int,
        result: MethodChannel.Result,
    ) {
        if (MimeTypes.isHeic(mimeType) && pageId != null) {
            val id = Pair(uri, pageId)
            fetch(
                uri = pageTempUris.getOrPut(id) { createJpegForPage(uri, pageId) },
                mimeType = MimeTypes.JPEG,
                pageId = null,
                sampleSize = sampleSize,
                regionRect = regionRect,
                imageWidth = imageWidth,
                imageHeight = imageHeight,
                result = result,
            )
            return
        }

        val options = BitmapFactory.Options().apply {
            inSampleSize = sampleSize
        }

        var currentDecoderRef = lastDecoderRef
        if (currentDecoderRef != null && currentDecoderRef.uri != uri) {
            currentDecoderRef = null
        }

        try {
            if (currentDecoderRef == null) {
                val newDecoder = StorageUtils.openInputStream(context, uri)?.use { input ->
                    @Suppress("BlockingMethodInNonBlockingContext")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        BitmapRegionDecoder.newInstance(input)
                    } else {
                        @Suppress("deprecation")
                        BitmapRegionDecoder.newInstance(input, false)
                    }
                }
                if (newDecoder == null) {
                    result.error("getRegion-read-null", "failed to open file for mimeType=$mimeType uri=$uri regionRect=$regionRect", null)
                    return
                }
                currentDecoderRef = LastDecoderRef(uri, newDecoder)
            }
            val decoder = currentDecoderRef.decoder
            lastDecoderRef = currentDecoderRef

            // with raw images, the known image size may not match the decoded image size
            // so we scale the requested region accordingly
            val effectiveRect = if (imageWidth != decoder.width || imageHeight != decoder.height) {
                val xf = decoder.width.toDouble() / imageWidth
                val yf = decoder.height.toDouble() / imageHeight
                Rect(
                    (regionRect.left * xf).roundToInt(),
                    (regionRect.top * yf).roundToInt(),
                    (regionRect.right * xf).roundToInt(),
                    (regionRect.bottom * yf).roundToInt(),
                )
            } else {
                regionRect
            }

            val bitmap = decoder.decodeRegion(effectiveRect, options)
            if (bitmap != null) {
                result.success(bitmap.getBytes(MimeTypes.canHaveAlpha(mimeType), recycle = true))
            } else {
                result.error("getRegion-null", "failed to decode region for uri=$uri regionRect=$regionRect", null)
            }
        } catch (e: Exception) {
            result.error("getRegion-read-exception", "failed to initialize region decoder for uri=$uri regionRect=$regionRect", e.message)
        }
    }

    private fun createJpegForPage(sourceUri: Uri, pageId: Int): Uri {
        val target = Glide.with(context)
            .asBitmap()
            .apply(multiTrackGlideOptions)
            .load(MultiTrackImage(context, sourceUri, pageId))
            .submit()
        try {
            val bitmap = target.get()
            val tempFile = File.createTempFile("aves", null, context.cacheDir).apply {
                deleteOnExit()
                outputStream().use { output ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, output)
                }
            }
            return Uri.fromFile(tempFile)
        } finally {
            Glide.with(context).clear(target)
        }
    }

    private data class LastDecoderRef(
        val uri: Uri,
        val decoder: BitmapRegionDecoder,
    )
}
