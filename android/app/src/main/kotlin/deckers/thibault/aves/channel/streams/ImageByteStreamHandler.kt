package deckers.thibault.aves.channel.streams

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.net.toUri
import com.bumptech.glide.Glide
import deckers.thibault.aves.decoder.AvesAppGlideModule
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.applyExifOrientation
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.canDecodeWithFlutter
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.needRotationAfterGlide
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import java.io.InputStream

class ImageByteStreamHandler(private val context: Context, private val arguments: Any?) : EventChannel.StreamHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var eventSink: EventSink
    private lateinit var handler: Handler

    override fun onListen(args: Any, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())

        ioScope.launch { streamImage() }
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

        val decoded = arguments["decoded"] as Boolean
        val mimeType = arguments["mimeType"] as String?
        val uri = (arguments["uri"] as String?)?.toUri()
        val sizeBytes = (arguments["sizeBytes"] as Number?)?.toLong()
        val rotationDegrees = arguments["rotationDegrees"] as Int
        val isFlipped = arguments["isFlipped"] as Boolean
        val isAnimated = arguments["isAnimated"] as Boolean
        val pageId = arguments["pageId"] as Int?

        if (mimeType == null || uri == null) {
            error("streamImage-args", "missing arguments", null)
            endOfStream()
            return
        }

        if (canDecodeWithFlutter(mimeType, isAnimated) && !decoded) {
            // to be decoded by Flutter
            streamOriginalEncodedBytes(uri, mimeType, sizeBytes)
        } else if (isVideo(mimeType)) {
            streamVideoByGlide(
                uri = uri,
                mimeType = mimeType,
                sizeBytes = sizeBytes,
                decoded = decoded,
            )
        } else {
            streamImageByGlide(
                uri = uri,
                pageId = pageId,
                mimeType = mimeType,
                sizeBytes = sizeBytes,
                rotationDegrees = rotationDegrees,
                isFlipped = isFlipped,
                decoded = decoded,
            )
        }
        endOfStream()
    }

    private fun streamOriginalEncodedBytes(uri: Uri, mimeType: String, sizeBytes: Long?) {
        if (!MemoryUtils.canAllocate(sizeBytes)) {
            error("streamImage-image-read-large", "original image too large at $sizeBytes bytes, for mimeType=$mimeType uri=$uri", null)
            return
        }

        try {
            StorageUtils.openInputStream(context, uri)?.use { input -> streamBytes(input) }
        } catch (e: Exception) {
            error("streamImage-image-read-exception", "failed to get image for mimeType=$mimeType uri=$uri", e.message)
        }
    }

    private suspend fun streamImageByGlide(
        uri: Uri,
        pageId: Int?,
        mimeType: String,
        sizeBytes: Long?,
        rotationDegrees: Int,
        isFlipped: Boolean,
        decoded: Boolean,
    ) {
        val target = Glide.with(context)
            .asBitmap()
            .apply(AvesAppGlideModule.uncachedFullImageOptions)
            .load(AvesAppGlideModule.getModel(context, uri, mimeType, pageId, sizeBytes))
            .submit()
        try {
            var bitmap = withContext(Dispatchers.IO) { target.get() }
            if (needRotationAfterGlide(mimeType, pageId)) {
                bitmap = applyExifOrientation(context, bitmap, rotationDegrees, isFlipped)
            }
            if (bitmap != null) {
                // do not recycle bitmaps fetched from Glide as their lifecycle is unknown
                val recycle = false
                val bytes = if (decoded) {
                    BitmapUtils.getRawBytes(bitmap, recycle = recycle)
                } else {
                    BitmapUtils.getEncodedBytes(bitmap, canHaveAlpha = MimeTypes.canHaveAlpha(mimeType), recycle = recycle)
                }

                if (MemoryUtils.canAllocate(sizeBytes)) {
                    streamBytes(ByteArrayInputStream(bytes))
                } else {
                    error("streamImage-image-decode-large", "decoded image too large at $sizeBytes bytes, for mimeType=$mimeType uri=$uri", null)
                }
            } else {
                error("streamImage-image-decode-null", "failed to get image for mimeType=$mimeType uri=$uri", null)
            }
        } catch (e: Exception) {
            error("streamImage-image-decode-exception", "failed to get image for mimeType=$mimeType uri=$uri", toErrorDetails(e))
        } finally {
            Glide.with(context).clear(target)
        }
    }

    private suspend fun streamVideoByGlide(uri: Uri, mimeType: String, sizeBytes: Long?, decoded: Boolean) {
        val target = Glide.with(context)
            .asBitmap()
            .apply(AvesAppGlideModule.uncachedFullImageOptions)
            .load(AvesAppGlideModule.getModel(context, uri, mimeType, null, sizeBytes))
            .submit()
        try {
            val bitmap = withContext(Dispatchers.IO) { target.get() }
            if (bitmap != null) {
                // do not recycle bitmaps fetched from Glide as their lifecycle is unknown
                val recycle = false
                val bytes = if (decoded) {
                    BitmapUtils.getRawBytes(bitmap, recycle = recycle)
                } else {
                    BitmapUtils.getEncodedBytes(bitmap, canHaveAlpha = false, recycle = recycle)
                }

                if (MemoryUtils.canAllocate(sizeBytes)) {
                    streamBytes(ByteArrayInputStream(bytes))
                } else {
                    error("streamImage-video-large", "decoded image too large at $sizeBytes bytes, for mimeType=$mimeType uri=$uri", null)
                }
            } else {
                error("streamImage-video-null", "failed to get image for mimeType=$mimeType uri=$uri", null)
            }
        } catch (e: Exception) {
            error("streamImage-video-exception", "failed to get image for mimeType=$mimeType uri=$uri", e.message)
        } finally {
            Glide.with(context).clear(target)
        }
    }

    private fun toErrorDetails(e: Exception): String? {
        val errorDetails = e.message
        return if (errorDetails?.isNotEmpty() == true) {
            errorDetails.split(Regex("\n"), 2).first()
        } else {
            errorDetails
        }
    }

    private fun streamBytes(inputStream: InputStream) {
        val buffer = ByteArray(BUFFER_SIZE)
        var len: Int
        while (inputStream.read(buffer).also { len = it } != -1) {
            // cannot decode image on Flutter side when using `buffer` directly
            if (MemoryUtils.canAllocate(len)) {
                success(buffer.copyOf(len))
            } else {
                error("streamBytes-memory", "not enough memory to allocate $len bytes", null)
                return
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ImageByteStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_byte_stream"

        private const val BUFFER_SIZE = 2 shl 17 // 256kB
    }
}