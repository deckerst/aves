package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapRegionDecoder
import android.graphics.Rect
import android.net.Uri
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.decoder.MultiPageImage
import deckers.thibault.aves.utils.BitmapRegionDecoderCompat
import deckers.thibault.aves.utils.BitmapUtils.ARGB_8888_BYTE_SIZE
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.MathUtils
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodChannel
import kotlin.math.max
import kotlin.math.roundToInt

// As of Android 14 (API 34), `BitmapRegionDecoder` documentation states
// that "only the JPEG, PNG, WebP and HEIF formats are supported"
// but in practice it successfully decodes some others.
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
        if (pageId != null && MultiPageImage.isSupported(mimeType)) {
            val id = Pair(uri, pageId)
            fetch(
                uri = pageTempUris.getOrPut(id) { createJpegForPage(uri, mimeType, pageId) },
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

        var currentDecoderRef = lastDecoderRef
        if (currentDecoderRef != null && currentDecoderRef.uri != uri) {
            currentDecoderRef = null
        }

        try {
            if (currentDecoderRef == null) {
                val newDecoder = StorageUtils.openInputStream(context, uri)?.use { input ->
                    BitmapRegionDecoderCompat.newInstance(input)
                }
                if (newDecoder == null) {
                    result.error("fetch-read-null", "failed to open file for mimeType=$mimeType uri=$uri regionRect=$regionRect", null)
                    return
                }
                currentDecoderRef = LastDecoderRef(uri, newDecoder)
            }
            val decoder = currentDecoderRef.decoder
            lastDecoderRef = currentDecoderRef

            // with raw images, the known image size may not match the decoded image size
            // so we scale the requested region accordingly
            var effectiveRect = regionRect
            var effectiveSampleSize = sampleSize

            if (imageWidth != decoder.width || imageHeight != decoder.height) {
                val xf = decoder.width.toDouble() / imageWidth
                val yf = decoder.height.toDouble() / imageHeight
                effectiveRect = Rect(
                    (regionRect.left * xf).roundToInt(),
                    (regionRect.top * yf).roundToInt(),
                    (regionRect.right * xf).roundToInt(),
                    (regionRect.bottom * yf).roundToInt(),
                )
                val factor = MathUtils.highestPowerOf2((1 / max(xf, yf)).roundToInt())
                if (factor > 1) {
                    effectiveSampleSize = max(1, effectiveSampleSize / factor)
                }
            }

            // use `Long` as rect size could be unexpectedly large and go beyond `Int` max
            val targetBitmapSizeBytes: Long = ARGB_8888_BYTE_SIZE.toLong() * effectiveRect.width() * effectiveRect.height() / effectiveSampleSize
            if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
                // decoding a region that large would yield an OOM when creating the bitmap
                result.error("fetch-large-region", "Region too large for uri=$uri regionRect=$regionRect", null)
                return
            }

            val options = BitmapFactory.Options().apply {
                inSampleSize = effectiveSampleSize
            }
            val bitmap = decoder.decodeRegion(effectiveRect, options)
            if (bitmap != null) {
                result.success(bitmap.getBytes(MimeTypes.canHaveAlpha(mimeType), recycle = true))
            } else {
                result.error("fetch-null", "failed to decode region for uri=$uri regionRect=$regionRect", null)
            }
        } catch (e: Exception) {
            result.error("fetch-read-exception", "failed to initialize region decoder for uri=$uri regionRect=$regionRect", e.message)
        }
    }

    private fun createJpegForPage(sourceUri: Uri, mimeType: String, pageId: Int): Uri {
        val target = Glide.with(context)
            .asBitmap()
            .apply(multiTrackGlideOptions)
            .load(MultiPageImage(context, sourceUri, mimeType, pageId))
            .submit()
        try {
            val bitmap = target.get()
            val tempFile = StorageUtils.createTempFile(context).apply {
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
