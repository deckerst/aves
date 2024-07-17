package deckers.thibault.aves.decoder

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
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
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.StorageUtils.openMetadataRetriever
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.io.ByteArrayInputStream
import java.io.InputStream
import kotlin.math.ceil
import kotlin.math.roundToInt

@GlideModule
class VideoThumbnailGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(VideoThumbnail::class.java, InputStream::class.java, VideoThumbnailLoader.Factory())
    }
}

class VideoThumbnail(val context: Context, val uri: Uri)

internal class VideoThumbnailLoader : ModelLoader<VideoThumbnail, InputStream> {
    override fun buildLoadData(model: VideoThumbnail, width: Int, height: Int, options: Options): ModelLoader.LoadData<InputStream> {
        return ModelLoader.LoadData(ObjectKey(model.uri), VideoThumbnailFetcher(model, width, height))
    }

    override fun handles(model: VideoThumbnail): Boolean = true

    internal class Factory : ModelLoaderFactory<VideoThumbnail, InputStream> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<VideoThumbnail, InputStream> = VideoThumbnailLoader()

        override fun teardown() {}
    }
}

internal class VideoThumbnailFetcher(private val model: VideoThumbnail, val width: Int, val height: Int) : DataFetcher<InputStream> {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun loadData(priority: Priority, callback: DataCallback<in InputStream>) {
        ioScope.launch {
            val retriever = openMetadataRetriever(model.context, model.uri)
            if (retriever == null) {
                callback.onLoadFailed(Exception("failed to initialize MediaMetadataRetriever for uri=${model.uri}"))
            } else {
                try {
                    var bytes = retriever.embeddedPicture
                    if (bytes == null) {
                        // there is no consistent strategy across devices to match
                        // the thumbnails returned by the content resolver / Media Store
                        // so we derive one in an arbitrary way
                        var timeMillis: Long? = null
                        val durationMillis = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull()
                        if (durationMillis != null) {
                            timeMillis = if (durationMillis < 15000) 0 else 15000
                        }
                        val timeMicros = if (timeMillis != null) timeMillis * 1000 else -1
                        val option = MediaMetadataRetriever.OPTION_CLOSEST_SYNC

                        var videoWidth = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toFloatOrNull()
                        var videoHeight = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toFloatOrNull()
                        if (videoWidth == null || videoHeight == null) {
                            throw Exception("failed to get video dimensions")
                        }

                        var dstWidth = 0
                        var dstHeight = 0
                        if (width > 0 && height > 0) {
                            val rotationDegrees = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull()
                            if (rotationDegrees != null) {
                                val isRotated = rotationDegrees % 180 == 90
                                if (isRotated) {
                                    val temp = videoWidth
                                    videoWidth = videoHeight
                                    videoHeight = temp
                                }

                                // cover fit
                                val videoAspectRatio = videoWidth / videoHeight
                                if (videoWidth > width || videoHeight > height) {
                                    if (width / height.toFloat() > videoAspectRatio) {
                                        dstHeight = ceil(videoHeight * width / videoWidth).toInt()
                                        dstWidth = (dstHeight * videoAspectRatio).roundToInt()
                                    } else {
                                        dstWidth = ceil(videoWidth * height / videoHeight).toInt()
                                        dstHeight = (dstWidth / videoAspectRatio).roundToInt()
                                    }
                                }
                            }
                        }

                        // the returned frame is already rotated according to the video metadata
                        val frame = if (dstWidth > 0 && dstHeight > 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                            val targetBitmapSizeBytes: Long = FORMAT_BYTE_SIZE.toLong() * dstWidth * dstHeight
                            if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
                                throw Exception("not enough memory to allocate $targetBitmapSizeBytes bytes for the scaled frame at $dstWidth x $dstHeight")
                            }
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                retriever.getScaledFrameAtTime(timeMicros, option, dstWidth, dstHeight, getBitmapParams())
                            } else {
                                retriever.getScaledFrameAtTime(timeMicros, option, dstWidth, dstHeight)
                            }
                        } else {
                            val targetBitmapSizeBytes: Long = (FORMAT_BYTE_SIZE.toLong() * videoWidth * videoHeight).toLong()
                            if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
                                throw Exception("not enough memory to allocate $targetBitmapSizeBytes bytes for the full frame at $videoWidth x $videoHeight")
                            }
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                retriever.getFrameAtTime(timeMicros, option, getBitmapParams())
                            } else {
                                retriever.getFrameAtTime(timeMicros, option)
                            }
                        }
                        bytes = frame?.getBytes(canHaveAlpha = false, recycle = false)
                    }

                    if (bytes != null) {
                        callback.onDataReady(ByteArrayInputStream(bytes))
                    } else {
                        callback.onLoadFailed(Exception("failed to get embedded picture or any frame"))
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

    @RequiresApi(Build.VERSION_CODES.P)
    private fun getBitmapParams() = MediaMetadataRetriever.BitmapParams().apply {
        preferredConfig = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // improved precision with the same memory cost as `ARGB_8888` (4 bytes per pixel)
            // for wide-gamut and HDR content which does not require alpha blending
            Bitmap.Config.RGBA_1010102
        } else {
            Bitmap.Config.ARGB_8888
        }
    }

    // already cleaned up in loadData and ByteArrayInputStream will be GC'd
    override fun cleanup() {}

    // cannot cancel
    override fun cancel() {}

    override fun getDataClass(): Class<InputStream> = InputStream::class.java

    override fun getDataSource(): DataSource = DataSource.LOCAL

    companion object {
        // same for either `ARGB_8888` or `RGBA_1010102`
        private const val FORMAT_BYTE_SIZE = BitmapUtils.ARGB_8888_BYTE_SIZE
    }
}