package deckers.thibault.aves.glide

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.util.Log
import android.util.Size
import androidx.annotation.RequiresApi
import com.bumptech.glide.Glide
import com.bumptech.glide.Priority
import com.bumptech.glide.Registry
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.Options
import com.bumptech.glide.load.data.DataFetcher
import com.bumptech.glide.load.data.DataFetcher.DataCallback
import com.bumptech.glide.load.model.ModelLoader
import com.bumptech.glide.load.model.ModelLoaderFactory
import com.bumptech.glide.load.model.MultiModelLoaderFactory
import com.bumptech.glide.module.LibraryGlideModule
import com.bumptech.glide.signature.ObjectKey
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeFloat
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeLong
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.StorageUtils.openMetadataRetriever
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.io.ByteArrayInputStream
import kotlin.math.min
import kotlin.math.roundToInt

@GlideModule
class VideoThumbnailGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(VideoThumbnail::class.java, Bitmap::class.java, VideoThumbnailLoader.Factory())
    }
}

class VideoThumbnail(val context: Context, val uri: Uri)

internal class VideoThumbnailLoader : ModelLoader<VideoThumbnail, Bitmap> {
    override fun buildLoadData(model: VideoThumbnail, width: Int, height: Int, options: Options): ModelLoader.LoadData<Bitmap> {
        return ModelLoader.LoadData(ObjectKey(model.uri), VideoThumbnailFetcher(model, width, height))
    }

    override fun handles(model: VideoThumbnail): Boolean = true

    internal class Factory : ModelLoaderFactory<VideoThumbnail, Bitmap> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<VideoThumbnail, Bitmap> = VideoThumbnailLoader()

        override fun teardown() {}
    }
}

internal class VideoThumbnailFetcher(private val model: VideoThumbnail, val width: Int, val height: Int) : DataFetcher<Bitmap> {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun loadData(priority: Priority, callback: DataCallback<in Bitmap>) {
        ioScope.launch {
            val retriever = openMetadataRetriever(model.context, model.uri)
            if (retriever == null) {
                callback.onLoadFailed(Exception("failed to initialize MediaMetadataRetriever for uri=${model.uri}"))
            } else {
                try {
                    val bitmap = getEmbeddedPicture(retriever) ?: getFrame(retriever)
                    if (bitmap == null) {
                        callback.onLoadFailed(Exception("failed to get embedded picture or any frame for uri=${model.uri}"))
                    } else {
                        callback.onDataReady(bitmap)
                    }
                } catch (e: Exception) {
                    callback.onLoadFailed(e)
                } finally {
                    // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                    retriever.release()
                }
            }
        }
    }

    // ignore all `MediaMetadataRetriever` exceptions as we will fall back to more reliable methods
    private fun getEmbeddedPicture(retriever: MediaMetadataRetriever): Bitmap? {
        try {
            retriever.embeddedPicture?.let { bytes ->
                return BitmapFactory.decodeStream(ByteArrayInputStream(bytes))
            }
        } catch (_: Exception) {
            // ignore
        }
        return null
    }

    private fun getFrame(retriever: MediaMetadataRetriever): Bitmap? {
        val videoSize = getVideoSize(retriever)
        val targetSize = getTargetSize(videoSize)

        var durationMillis: Long? = null
        retriever.getSafeLong(MediaMetadataRetriever.METADATA_KEY_DURATION) { durationMillis = it }
        val timeMicros = getBestThumbnailTimeMicros(durationMillis)

        // fall back from preferred frame, to first frame, to any frame
        var bitmap = getFrameAtTime(retriever, videoSize, targetSize, timeMicros)
        if (bitmap == null && timeMicros > TIME_FRAME_FIRST) {
            bitmap = getFrameAtTime(retriever, videoSize, targetSize, TIME_FRAME_FIRST)
        }
        if (bitmap == null) {
            bitmap = getFrameAtTime(retriever, videoSize, targetSize, TIME_FRAME_ANY)
        }
        return bitmap
    }

    private fun getVideoSize(retriever: MediaMetadataRetriever): Size {
        var videoWidth: Float? = null
        var videoHeight: Float? = null
        retriever.getSafeFloat(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH) { videoWidth = it }
        retriever.getSafeFloat(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT) { videoHeight = it }
        if (videoWidth == null || videoHeight == null) {
            throw Exception("failed to get video dimensions")
        }

        var rotationDegrees = 0
        retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { rotationDegrees = it }

        val isRotated = rotationDegrees % 180 == 90
        if (isRotated) {
            videoWidth = videoHeight.also { videoHeight = videoWidth }
        }

        return Size(videoWidth!!.toInt(), videoHeight!!.toInt())
    }

    private fun getTargetSize(videoSize: Size): Size {
        val videoWidth = videoSize.width
        val videoHeight = videoSize.height

        var dstWidth = 0
        var dstHeight = 0
        if (width > 0 && height > 0) {
            // cover fit
            val targetAspectRatio = width / height.toFloat()
            val videoAspectRatio = videoWidth / videoHeight.toFloat()
            if (targetAspectRatio > videoAspectRatio) {
                dstHeight = (width / videoAspectRatio).roundToInt()
                dstWidth = (dstHeight * videoAspectRatio).roundToInt()
            } else {
                dstWidth = (height * videoAspectRatio).roundToInt()
                dstHeight = (dstWidth / videoAspectRatio).roundToInt()
            }
        }
        if (dstWidth == 0 || dstWidth > videoWidth || dstHeight == 0 || dstHeight > videoHeight) {
            return videoSize
        }
        return Size(dstWidth, dstHeight)
    }

    // there is no consistent strategy across devices to match
    // the thumbnails returned by the content resolver / Media Store
    // so we derive one in an arbitrary way
    //
    // use same strategy on flutter and platform sides
    private fun getBestThumbnailTimeMicros(durationMillis: Long?): Long {
        if (durationMillis == null || durationMillis < SHORT_DURATION_MILLIS) {
            return TIME_FRAME_FIRST
        }

        val timeMillis = min(durationMillis / 2, SHORT_DURATION_MILLIS)
        return timeMillis * 1000
    }

    // ignore all `MediaMetadataRetriever` exceptions as we will fall back to more reliable methods
    //
    // return frame already rotated according to the video metadata
    private fun getFrameAtTime(retriever: MediaMetadataRetriever, videoSize: Size, targetSize: Size, timeMicros: Long): Bitmap? {
        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) {
                checkPixelAllocation(videoSize)
                return retriever.getFrameAtTime(timeMicros, FRAME_OPTION)
            }

            checkPixelAllocation(targetSize)
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                return retriever.getScaledFrameAtTime(timeMicros, FRAME_OPTION, targetSize.width, targetSize.height)
            }

            return retriever.getScaledFrameAtTime(timeMicros, FRAME_OPTION, targetSize.width, targetSize.height, getBitmapParams())
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get frame with videoSize=$videoSize, targetSize=$targetSize, timeMicros=$timeMicros", e)
        }
        return null
    }

    private fun checkPixelAllocation(frameSize: Size) {
        val pixelCount: Long = frameSize.width * frameSize.height.toLong()
        val targetBitmapSizeBytes = BitmapUtils.getExpectedImageSize(pixelCount, getPreferredConfig())
        if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
            throw Exception("not enough memory to allocate $targetBitmapSizeBytes bytes for the frame sized at $frameSize")
        }
    }

    @RequiresApi(Build.VERSION_CODES.P)
    private fun getBitmapParams(): MediaMetadataRetriever.BitmapParams {
        val params = MediaMetadataRetriever.BitmapParams()
        // `RGBA_1010102` has improved precision with the same memory cost as `ARGB_8888` (4 bytes per pixel)
        // but specifying as preferred makes the native call block and fail on Android 17 (API 37)
        params.preferredConfig = getPreferredConfig()
        return params
    }

    private fun getPreferredConfig(): Bitmap.Config {
        // `RGBA_1010102` has improved precision with the same memory cost as `ARGB_8888` (4 bytes per pixel)
        // but specifying it as preferred makes `getScaledFrameAtTime` block and fail on Android 17 (API 37)
        return Bitmap.Config.ARGB_8888
    }

    // already cleaned up in loadData and ByteArrayInputStream will be GC'd
    override fun cleanup() {}

    // cannot cancel
    override fun cancel() {}

    override fun getDataClass(): Class<Bitmap> = Bitmap::class.java

    override fun getDataSource(): DataSource = DataSource.LOCAL

    companion object {
        private val LOG_TAG = LogUtils.createTag<VideoThumbnailFetcher>()
        const val SHORT_DURATION_MILLIS: Long = 15000
        const val TIME_FRAME_ANY: Long = -1
        const val TIME_FRAME_FIRST: Long = 0
        const val FRAME_OPTION = MediaMetadataRetriever.OPTION_CLOSEST_SYNC
    }
}