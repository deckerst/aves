package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Size
import androidx.annotation.RequiresApi
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.signature.ObjectKey
import deckers.thibault.aves.decoder.MultiTrackImage
import deckers.thibault.aves.decoder.SvgImage
import deckers.thibault.aves.decoder.TiffImage
import deckers.thibault.aves.decoder.VideoThumbnail
import deckers.thibault.aves.utils.BitmapUtils.applyExifOrientation
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.SVG
import deckers.thibault.aves.utils.MimeTypes.isHeic
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterContentResolverThumbnail
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterGlide
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.UriUtils.tryParseId
import io.flutter.plugin.common.MethodChannel

class ThumbnailFetcher internal constructor(
    private val context: Context,
    uri: String,
    private val mimeType: String,
    private val dateModifiedSecs: Long,
    private val rotationDegrees: Int,
    private val isFlipped: Boolean,
    width: Int?,
    height: Int?,
    private val pageId: Int?,
    private val defaultSize: Int,
    private val result: MethodChannel.Result,
) {
    private val uri: Uri = Uri.parse(uri)
    private val width: Int = if (width?.takeIf { it > 0 } != null) width else defaultSize
    private val height: Int = if (height?.takeIf { it > 0 } != null) height else defaultSize
    private val svgFetch = mimeType == SVG
    private val tiffFetch = mimeType == MimeTypes.TIFF
    private val multiTrackFetch = isHeic(mimeType) && pageId != null
    private val customFetch = svgFetch || tiffFetch || multiTrackFetch

    suspend fun fetch() {
        var bitmap: Bitmap? = null
        var exception: Exception? = null

        try {
            if (!customFetch && (width == defaultSize || height == defaultSize) && !isFlipped) {
                // Fetch low quality thumbnails when size is not specified.
                // As of Android R, the Media Store content resolver may return a thumbnail
                // that is automatically rotated according to EXIF orientation, but not flipped,
                // so we skip this step for flipped entries.
                bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) getByResolver() else getByMediaStore()
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
            result.success(bitmap.getBytes(MimeTypes.canHaveAlpha(mimeType), recycle = false))
        } else {
            var errorDetails: String? = exception?.message
            if (errorDetails?.isNotEmpty() == true) {
                errorDetails = errorDetails.split(Regex("\n"), 2).first()
            }
            result.error("getThumbnail-null", "failed to get thumbnail for mimeType=$mimeType uri=$uri", errorDetails)
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
            // from Android Q, returned thumbnail is already rotated according to EXIF orientation
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q && bitmap != null) {
                bitmap = applyExifOrientation(context, bitmap, rotationDegrees, isFlipped)
            }
            bitmap
        }
    }

    private fun getByGlide(): Bitmap? {
        // add signature to ignore cache for images which got modified but kept the same URI
        var options = RequestOptions()
            .format(DecodeFormat.PREFER_RGB_565)
            .signature(ObjectKey("$dateModifiedSecs-$rotationDegrees-$isFlipped-$width-$pageId"))
            .override(width, height)

        val target = if (isVideo(mimeType)) {
            options = options.diskCacheStrategy(DiskCacheStrategy.RESOURCE)
            Glide.with(context)
                .asBitmap()
                .apply(options)
                .load(VideoThumbnail(context, uri))
                .submit(width, height)
        } else {
            val model: Any = when {
                svgFetch -> SvgImage(context, uri)
                tiffFetch -> TiffImage(context, uri, pageId)
                multiTrackFetch -> MultiTrackImage(context, uri, pageId)
                else -> StorageUtils.getGlideSafeUri(uri, mimeType)
            }
            Glide.with(context)
                .asBitmap()
                .apply(options)
                .load(model)
                .submit(width, height)
        }

        return try {
            var bitmap = target.get()
            if (needRotationAfterGlide(mimeType)) {
                bitmap = applyExifOrientation(context, bitmap, rotationDegrees, isFlipped)
            }
            bitmap
        } finally {
            Glide.with(context).clear(target)
        }
    }
}