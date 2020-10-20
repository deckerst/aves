package deckers.thibault.aves.decoder

import android.content.Context
import android.graphics.Bitmap
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
import deckers.thibault.aves.utils.StorageUtils.openMetadataRetriever
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.InputStream

@GlideModule
class VideoThumbnailGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(VideoThumbnail::class.java, InputStream::class.java, VideoThumbnailLoader.Factory())
    }
}

class VideoThumbnail(val context: Context, val uri: Uri)

internal class VideoThumbnailLoader : ModelLoader<VideoThumbnail, InputStream> {
    override fun buildLoadData(model: VideoThumbnail, width: Int, height: Int, options: Options): ModelLoader.LoadData<InputStream>? {
        return ModelLoader.LoadData(ObjectKey(model.uri), VideoThumbnailFetcher(model))
    }

    override fun handles(videoThumbnail: VideoThumbnail): Boolean = true

    internal class Factory : ModelLoaderFactory<VideoThumbnail, InputStream> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<VideoThumbnail, InputStream> = VideoThumbnailLoader()

        override fun teardown() {}
    }
}

internal class VideoThumbnailFetcher(private val model: VideoThumbnail) : DataFetcher<InputStream> {
    override fun loadData(priority: Priority, callback: DataCallback<in InputStream>) {
        val retriever = openMetadataRetriever(model.context, model.uri)
        if (retriever != null) {
            try {
                var picture = retriever.embeddedPicture
                if (picture == null) {
                    // not ideal: bitmap -> byte[] -> bitmap
                    // but simple fallback and we cache result
                    val bos = ByteArrayOutputStream()
                    val bitmap = retriever.frameAtTime
                    bitmap?.compress(Bitmap.CompressFormat.PNG, 0, bos)
                    picture = bos.toByteArray()
                }
                callback.onDataReady(ByteArrayInputStream(picture))
            } catch (e: Exception) {
                callback.onLoadFailed(e)
            } finally {
                // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                retriever.release()
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