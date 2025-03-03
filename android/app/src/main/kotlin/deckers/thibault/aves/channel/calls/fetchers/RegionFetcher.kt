package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapRegionDecoder
import android.graphics.ColorSpace
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.util.Log
import com.bumptech.glide.Glide
import deckers.thibault.aves.decoder.AvesAppGlideModule
import deckers.thibault.aves.decoder.MultiPageImage
import deckers.thibault.aves.utils.BitmapRegionDecoderCompat
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getRawBytes
import deckers.thibault.aves.utils.LogUtils
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

    private val exportUris = HashMap<Pair<Uri, Int?>, Uri>()

    // return decoded bytes in ARGB_8888, with trailer bytes:
    // - width (int32)
    // - height (int32)
    fun fetch(
        uri: Uri,
        mimeType: String,
        pageId: Int?,
        sampleSize: Int,
        regionRect: Rect,
        imageWidth: Int,
        imageHeight: Int,
        requestKey: Pair<Uri, Int?> = Pair(uri, pageId),
        result: MethodChannel.Result,
    ) {
        if (pageId != null && MultiPageImage.isSupported(mimeType)) {
            // use JPEG export for requested page
            fetch(
                uri = exportUris.getOrPut(requestKey) { createTemporaryJpegExport(uri, mimeType, pageId) },
                mimeType = MimeTypes.JPEG,
                pageId = null,
                sampleSize = sampleSize,
                regionRect = regionRect,
                imageWidth = imageWidth,
                imageHeight = imageHeight,
                requestKey = requestKey,
                result = result,
            )
            return
        }

        var currentDecoderRef = lastDecoderRef
        if (currentDecoderRef != null && currentDecoderRef.requestKey != requestKey) {
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
                currentDecoderRef = LastDecoderRef(requestKey, newDecoder)
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

            val options = BitmapFactory.Options().apply {
                inSampleSize = effectiveSampleSize
                // Specifying preferred config and color space avoids the need for conversion afterwards,
                // but may prevent decoding (e.g. from RGBA_1010102 to ARGB_8888 on some devices).
                inPreferredConfig = PREFERRED_CONFIG
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    inPreferredColorSpace = ColorSpace.get(ColorSpace.Named.SRGB)
                }
            }

            val pixelCount = effectiveRect.width() * effectiveRect.height() / effectiveSampleSize
            val targetBitmapSizeBytes = BitmapUtils.getExpectedImageSize(pixelCount.toLong(), options.inPreferredConfig)
            if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
                // decoding a region that large would yield an OOM when creating the bitmap
                result.error("fetch-large-region", "Region too large for uri=$uri regionRect=$regionRect", null)
                return
            }

            var bitmap = decoder.decodeRegion(effectiveRect, options)
            if (bitmap == null) {
                // retry without specifying config or color space,
                // falling back to custom byte conversion afterwards
                options.inPreferredConfig = null
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && options.inPreferredColorSpace != null) {
                    options.inPreferredColorSpace = null
                }
                bitmap = decoder.decodeRegion(effectiveRect, options)
            }

            val bytes = bitmap?.getRawBytes(recycle = true)
            if (bytes != null) {
                result.success(bytes)
            } else {
                result.error("fetch-null", "failed to decode region for uri=$uri regionRect=$regionRect", null)
            }
        } catch (e: Exception) {
            if (mimeType != MimeTypes.JPEG) {
                // retry with JPEG export on failure,
                // as some formats are not fully supported by `BitmapRegionDecoder`
                fetch(
                    uri = exportUris.getOrPut(requestKey) { createTemporaryJpegExport(uri, mimeType, pageId) },
                    mimeType = MimeTypes.JPEG,
                    pageId = null,
                    sampleSize = sampleSize,
                    regionRect = regionRect,
                    imageWidth = imageWidth,
                    imageHeight = imageHeight,
                    requestKey = requestKey,
                    result = result,
                )
                return
            }

            result.error("fetch-read-exception", "failed to initialize region decoder for uri=$uri regionRect=$regionRect", e.message)
        }
    }

    private fun createTemporaryJpegExport(uri: Uri, mimeType: String, pageId: Int?): Uri {
        Log.d(LOG_TAG, "create JPEG export for uri=$uri mimeType=$mimeType pageId=$pageId")
        val target = Glide.with(context)
            .asBitmap()
            .apply(AvesAppGlideModule.uncachedFullImageOptions)
            .load(AvesAppGlideModule.getModel(context, uri, mimeType, pageId))
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
        val requestKey: Pair<Uri, Int?>,
        val decoder: BitmapRegionDecoder,
    )

    companion object {
        private val LOG_TAG = LogUtils.createTag<RegionFetcher>()
        private val PREFERRED_CONFIG = Bitmap.Config.ARGB_8888
    }
}
