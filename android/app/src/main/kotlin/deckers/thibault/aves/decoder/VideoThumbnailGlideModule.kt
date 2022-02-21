package deckers.thibault.aves.decoder

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
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
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.StorageUtils.openMetadataRetriever
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.io.ByteArrayInputStream
import java.io.InputStream

@GlideModule
class VideoThumbnailGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(VideoThumbnail::class.java, InputStream::class.java, VideoThumbnailLoader.Factory())
    }
}

class VideoThumbnail(val context: Context, val uri: Uri)

internal class VideoThumbnailLoader : ModelLoader<VideoThumbnail, InputStream> {
    override fun buildLoadData(model: VideoThumbnail, width: Int, height: Int, options: Options): ModelLoader.LoadData<InputStream> {
        return ModelLoader.LoadData(ObjectKey(model.uri), VideoThumbnailFetcher(model))
    }

    override fun handles(model: VideoThumbnail): Boolean = true

    internal class Factory : ModelLoaderFactory<VideoThumbnail, InputStream> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<VideoThumbnail, InputStream> = VideoThumbnailLoader()

        override fun teardown() {}
    }
}

internal class VideoThumbnailFetcher(private val model: VideoThumbnail) : DataFetcher<InputStream> {
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
                        val frame = if (timeMillis != null) {
                            retriever.getFrameAtTime(timeMillis * 1000)
                        } else {
                            retriever.frameAtTime
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

    // already cleaned up in loadData and ByteArrayInputStream will be GC'd
    override fun cleanup() {}

    // cannot cancel
    override fun cancel() {}

    override fun getDataClass(): Class<InputStream> = InputStream::class.java

    override fun getDataSource(): DataSource = DataSource.LOCAL
}