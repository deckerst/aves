package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.decoder.VideoThumbnail
import deckers.thibault.aves.utils.BitmapUtils.applyExifOrientation
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isSupportedByFlutter
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterGlide
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.IOException
import java.io.InputStream

class ImageByteStreamHandler(private val activity: Activity, private val arguments: Any?) : EventChannel.StreamHandler {
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler

    override fun onListen(args: Any, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())

        GlobalScope.launch(Dispatchers.IO) { streamImage() }
    }

    override fun onCancel(o: Any) {}

    private fun success(bytes: ByteArray) {
        handler.post { eventSink.success(bytes) }
    }

    private fun error(errorCode: String, errorMessage: String, errorDetails: Any?) {
        handler.post { eventSink.error(errorCode, errorMessage, errorDetails) }
    }

    private fun endOfStream() {
        handler.post { eventSink.endOfStream() }
    }

    // Supported image formats:
    // - Flutter (as of v1.20): JPEG, PNG, GIF, Animated GIF, WebP, Animated WebP, BMP, and WBMP
    // - Android: https://developer.android.com/guide/topics/media/media-formats#image-formats
    // - Glide: https://github.com/bumptech/glide/blob/master/library/src/main/java/com/bumptech/glide/load/ImageHeaderParser.java
    private fun streamImage() {
        if (arguments !is Map<*, *>) {
            endOfStream()
            return
        }

        val mimeType = arguments["mimeType"] as String?
        val uri = (arguments["uri"] as String?)?.let { Uri.parse(it) }
        val rotationDegrees = arguments["rotationDegrees"] as Int
        val isFlipped = arguments["isFlipped"] as Boolean

        if (mimeType == null || uri == null) {
            error("streamImage-args", "failed because of missing arguments", null)
            endOfStream()
            return
        }

        if (isVideo(mimeType)) {
            streamVideoByGlide(uri)
        } else if (mimeType == MimeTypes.TIFF) {
            streamTiffImage(uri)
        } else if (!isSupportedByFlutter(mimeType, rotationDegrees, isFlipped)) {
            // decode exotic format on platform side, then encode it in portable format for Flutter
            streamImageByGlide(uri, mimeType, rotationDegrees, isFlipped)
        } else {
            // to be decoded by Flutter
            streamImageAsIs(uri)
        }
        endOfStream()
    }

    private fun streamImageAsIs(uri: Uri) {
        try {
            StorageUtils.openInputStream(activity, uri)?.use { input -> streamBytes(input) }
        } catch (e: IOException) {
            error("streamImage-image-read-exception", "failed to get image from uri=$uri", e.message)
        }
    }

    private fun streamImageByGlide(uri: Uri, mimeType: String, rotationDegrees: Int, isFlipped: Boolean) {
        val target = Glide.with(activity)
            .asBitmap()
            .apply(glideOptions)
            .load(uri)
            .submit()
        try {
            var bitmap = target.get()
            if (needRotationAfterGlide(mimeType)) {
                bitmap = applyExifOrientation(activity, bitmap, rotationDegrees, isFlipped)
            }
            if (bitmap != null) {
                success(bitmap.getBytes(MimeTypes.canHaveAlpha(mimeType), recycle = false))
            } else {
                error("streamImage-image-decode-null", "failed to get image from uri=$uri", null)
            }
        } catch (e: Exception) {
            error("streamImage-image-decode-exception", "failed to get image from uri=$uri", toErrorDetails(e))
        } finally {
            Glide.with(activity).clear(target)
        }
    }

    private fun streamVideoByGlide(uri: Uri) {
        val target = Glide.with(activity)
            .asBitmap()
            .apply(glideOptions)
            .load(VideoThumbnail(activity, uri))
            .submit()
        try {
            val bitmap = target.get()
            if (bitmap != null) {
                success(bitmap.getBytes(canHaveAlpha = false, recycle = false))
            } else {
                error("streamImage-video-null", "failed to get image from uri=$uri", null)
            }
        } catch (e: Exception) {
            error("streamImage-video-exception", "failed to get image from uri=$uri", e.message)
        } finally {
            Glide.with(activity).clear(target)
        }
    }

    private fun streamTiffImage(uri: Uri, page: Int = 0) {
        val resolver = activity.contentResolver
        try {
            var dirCount = 0
            resolver.openFileDescriptor(uri, "r")?.use { descriptor ->
                val options = TiffBitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                TiffBitmapFactory.decodeFileDescriptor(descriptor.fd, options)
                dirCount = options.outDirectoryCount
            }

            // TODO TLAD handle multipage TIFF
            if (dirCount > page) {
                resolver.openFileDescriptor(uri, "r")?.use { descriptor ->
                    val options = TiffBitmapFactory.Options().apply {
                        inJustDecodeBounds = false
                        inDirectoryNumber = page
                    }
                    val bitmap = TiffBitmapFactory.decodeFileDescriptor(descriptor.fd, options)
                    if (bitmap != null) {
                        success(bitmap.getBytes(canHaveAlpha = true, recycle = true))
                    } else {
                        error("streamImage-tiff-null", "failed to get tiff image (dir=$page) from uri=$uri", null)
                    }
                }
            }
        } catch (e: Exception) {
            error("streamImage-tiff-exception", "failed to get image from uri=$uri", toErrorDetails(e))
        }
    }

    private fun toErrorDetails(e: Exception): String? {
        val errorDetails = e.message
        return if (errorDetails?.isNotEmpty() == true) {
            errorDetails.split("\n".toRegex(), 2).first()
        } else {
            errorDetails
        }
    }

    private fun streamBytes(inputStream: InputStream) {
        val buffer = ByteArray(bufferSize)
        var len: Int
        while (inputStream.read(buffer).also { len = it } != -1) {
            // cannot decode image on Flutter side when using `buffer` directly
            success(buffer.copyOf(len))
        }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/imagebytestream"

        const val bufferSize = 2 shl 17 // 256kB

        // request a fresh image with the highest quality format
        val glideOptions = RequestOptions()
            .format(DecodeFormat.PREFER_ARGB_8888)
            .diskCacheStrategy(DiskCacheStrategy.NONE)
            .skipMemoryCache(true)
    }
}