package deckers.thibault.aves.decoding

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import androidx.annotation.RequiresApi
import androidx.core.graphics.scale
import androidx.core.net.toUri
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.signature.ObjectKey
import deckers.thibault.aves.channel.streams.ByteSink
import deckers.thibault.aves.glide.AvesAppGlideModule
import deckers.thibault.aves.glide.MultiPageImage
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.applyExifOrientation
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.SVG
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterContentResolverThumbnail
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterGlide
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.UriUtils.tryParseId
import java.io.ByteArrayInputStream
import kotlin.math.min
import kotlin.math.roundToInt

class ThumbnailFetcher internal constructor(
    private val context: Context,
    uri: String,
    private val pageId: Int?,
    private val decoded: Boolean,
    private val mimeType: String,
    private val dateModifiedMillis: Long,
    private val rotationDegrees: Int,
    private val isFlipped: Boolean,
    width: Int?,
    height: Int?,
    private val defaultSize: Int,
    private val quality: Int,
    private val result: ByteSink,
) {
    private val uri: Uri = uri.toUri()
    private val width: Int = if (width?.takeIf { it > 0 } != null) width else defaultSize
    private val height: Int = if (height?.takeIf { it > 0 } != null) height else defaultSize
    private val svgFetch = mimeType == SVG
    private val tiffFetch = mimeType == MimeTypes.TIFF
    private val multiPageFetch = pageId != null && MultiPageImage.isSupported(mimeType)
    private val customFetch = svgFetch || tiffFetch || multiPageFetch

    suspend fun fetch() {
        var bitmap: Bitmap? = null
        var exception: Exception? = null

        try {
            if (!customFetch && (width == defaultSize || height == defaultSize) && !isFlipped) {
                // Fetch low quality thumbnails when size is not specified.
                // As of Android 11, the Media Store content resolver may return a thumbnail
                // that is automatically rotated according to EXIF orientation, but not flipped,
                // so we skip this step for flipped entries.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    bitmap = getByResolver()
                } else if (StorageUtils.isMediaStoreContentUri(uri)) {
                    bitmap = getByMediaStore()
                }
            }
        } catch (e: Exception) {
            exception = e
        }

        // fallback if the native methods failed or for higher quality thumbnails
        if (bitmap == null) {
            try {
                bitmap = getByGlide()
            } catch (e: Exception) {
                exception = e
            }
        }

        if (bitmap != null) {
            if (bitmap.width > width && bitmap.height > height) {
                val scalingFactor: Double = min(bitmap.width.toDouble() / width, bitmap.height.toDouble() / height)
                val dstWidth = (bitmap.width / scalingFactor).roundToInt()
                val dstHeight = (bitmap.height / scalingFactor).roundToInt()
                Log.d(
                    LOG_TAG, "rescale thumbnail for mimeType=$mimeType uri=$uri width=$width height=$height" +
                            ", with bitmap byteCount=${bitmap.byteCount} size=${bitmap.width}x${bitmap.height}" +
                            ", to target=${dstWidth}x${dstHeight}"
                )
                bitmap = bitmap.scale(dstWidth, dstHeight)
            }

            if (bitmap.byteCount > BITMAP_SIZE_DANGER_THRESHOLD) {
                result.error(
                    "getThumbnail-large", "thumbnail bitmap dangerously large" +
                            " for mimeType=$mimeType uri=$uri pageId=$pageId width=$width height=$height" +
                            ", with bitmap byteCount=${bitmap.byteCount} size=${bitmap.width}x${bitmap.height} config=${bitmap.config?.name}", null
                )
                return
            }
        }

        // do not recycle bitmaps fetched from `ContentResolver` or Glide as their lifecycle is unknown
        val bytes = BitmapUtils.getBytes(bitmap, recycle = false, decoded = decoded, mimeType)
        if (bytes == null) {
            var errorDetails: String? = exception?.message
            if (errorDetails?.isNotEmpty() == true) {
                errorDetails = errorDetails.split(Regex("\n"), 2).first()
            }
            result.error("getThumbnail-null", "failed to get thumbnail for mimeType=$mimeType uri=$uri", errorDetails)
        } else {
            result.streamBytes(ByteArrayInputStream(bytes))
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    private fun getByResolver(): Bitmap? {
        val resolver = context.contentResolver
        var bitmap: Bitmap? = resolver.loadThumbnail(uri, Size(width, height), null)
        if (needRotationAfterContentResolverThumbnail(mimeType)) {
            bitmap = applyExifOrientation(context, bitmap, rotationDegrees, isFlipped)
        }
        return bitmap
    }

    private fun getByMediaStore(): Bitmap? {
        val contentId = uri.tryParseId() ?: return null
        val resolver = context.contentResolver
        return if (isVideo(mimeType)) {
            @Suppress("deprecation")
            MediaStore.Video.Thumbnails.getThumbnail(resolver, contentId, MediaStore.Video.Thumbnails.MINI_KIND, null)
        } else {
            @Suppress("deprecation")
            var bitmap = MediaStore.Images.Thumbnails.getThumbnail(resolver, contentId, MediaStore.Images.Thumbnails.MINI_KIND, null)
            // from Android 10 (API 29), returned thumbnail is already rotated according to EXIF orientation
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q && bitmap != null) {
                bitmap = applyExifOrientation(context, bitmap, rotationDegrees, isFlipped)
            }
            bitmap
        }
    }

    private fun getByGlide(): Bitmap? {
        // add signature to ignore cache for images which got modified but kept the same URI
        var options = RequestOptions()
            .format(if (quality == 100) DecodeFormat.PREFER_ARGB_8888 else DecodeFormat.PREFER_RGB_565)
            .signature(ObjectKey("$dateModifiedMillis-$rotationDegrees-$isFlipped-$width-$pageId"))
            .override(width, height)
        if (isVideo(mimeType)) {
            options = options.diskCacheStrategy(DiskCacheStrategy.RESOURCE)
        }

        val target = Glide.with(context)
            .asBitmap()
            .apply(options)
            .load(AvesAppGlideModule.getModel(context, uri, mimeType, pageId))
            .submit(width, height)

        return try {
            var bitmap = target.get()
            if (needRotationAfterGlide(mimeType, pageId)) {
                bitmap = applyExifOrientation(context, bitmap, rotationDegrees, isFlipped)
            }
            bitmap
        } finally {
            Glide.with(context).clear(target)
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ThumbnailFetcher>()
        private const val BITMAP_SIZE_DANGER_THRESHOLD = 20 * (1 shl 20) // MB
    }
}