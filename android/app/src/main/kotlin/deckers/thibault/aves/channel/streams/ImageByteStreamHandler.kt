package deckers.thibault.aves.channel.streams

import android.app.Activity
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.decoder.MultiTrackImage
import deckers.thibault.aves.decoder.TiffImage
import deckers.thibault.aves.decoder.VideoThumbnail
import deckers.thibault.aves.utils.BitmapUtils.applyExifOrientation
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isHeic
import deckers.thibault.aves.utils.MimeTypes.isSupportedByFlutter
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterGlide
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
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

    private fun success(bytes: ByteArray?) {
        handler.post {
            try {
                eventSink.success(bytes)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    private fun error(errorCode: String, errorMessage: String, errorDetails: Any?) {
        handler.post {
            try {
                eventSink.error(errorCode, errorMessage, errorDetails)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    private fun endOfStream() {
        handler.post {
            try {
                eventSink.endOfStream()
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    // Supported image formats:
    // - Flutter (as of v1.20): JPEG, PNG, GIF, Animated GIF, WebP, Animated WebP, BMP, and WBMP
    // - Android: https://developer.android.com/guide/topics/media/media-formats#image-formats
    // - Glide: https://github.com/bumptech/glide/blob/master/library/src/main/java/com/bumptech/glide/load/ImageHeaderParser.java
    private suspend fun streamImage() {
        if (arguments !is Map<*, *>) {
            endOfStream()
            return
        }

        val mimeType = arguments["mimeType"] as String?
        val uri = (arguments["uri"] as String?)?.let { Uri.parse(it) }
        val rotationDegrees = arguments["rotationDegrees"] as Int
        val isFlipped = arguments["isFlipped"] as Boolean
        val pageId = arguments["pageId"] as Int?

        if (mimeType == null || uri == null) {
            error("streamImage-args", "failed because of missing arguments", null)
            endOfStream()
            return
        }

        if (isVideo(mimeType)) {
            streamVideoByGlide(uri)
        } else if (!isSupportedByFlutter(mimeType, rotationDegrees, isFlipped)) {
            // decode exotic format on platform side, then encode it in portable format for Flutter
            streamImageByGlide(uri, pageId, mimeType, rotationDegrees, isFlipped)
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

    private suspend fun streamImageByGlide(uri: Uri, pageId: Int?, mimeType: String, rotationDegrees: Int, isFlipped: Boolean) {
        val model: Any = if (isHeic(mimeType) && pageId != null) {
            MultiTrackImage(activity, uri, pageId)
        } else if (mimeType == MimeTypes.TIFF) {
            TiffImage(activity, uri, pageId)
        } else {
            uri
        }

        val target = Glide.with(activity)
            .asBitmap()
            .apply(glideOptions)
            .load(model)
            .submit()
        try {
            @Suppress("BlockingMethodInNonBlockingContext")
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

    private suspend fun streamVideoByGlide(uri: Uri) {
        val target = Glide.with(activity)
            .asBitmap()
            .apply(glideOptions)
            .load(VideoThumbnail(activity, uri))
            .submit()
        try {
            @Suppress("BlockingMethodInNonBlockingContext")
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

    private fun toErrorDetails(e: Exception): String? {
        val errorDetails = e.message
        return if (errorDetails?.isNotEmpty() == true) {
            errorDetails.split("\n".toRegex(), 2).first()
        } else {
            errorDetails
        }
    }

    private fun streamBytes(inputStream: InputStream) {
        val buffer = ByteArray(BUFFER_SIZE)
        var len: Int
        while (inputStream.read(buffer).also { len = it } != -1) {
            // cannot decode image on Flutter side when using `buffer` directly
            success(buffer.copyOf(len))
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ImageByteStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/imagebytestream"

        const val BUFFER_SIZE = 2 shl 17 // 256kB

        // request a fresh image with the highest quality format
        val glideOptions = RequestOptions()
            .format(DecodeFormat.PREFER_ARGB_8888)
            .diskCacheStrategy(DiskCacheStrategy.NONE)
            .skipMemoryCache(true)
    }
}