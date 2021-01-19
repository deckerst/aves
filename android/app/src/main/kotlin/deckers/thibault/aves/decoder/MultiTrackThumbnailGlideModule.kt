package deckers.thibault.aves.decoder

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.os.Build
import android.util.Log
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
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import java.io.InputStream


@GlideModule
class MultiTrackThumbnailGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(MultiTrackThumbnail::class.java, InputStream::class.java, MultiTrackThumbnailLoader.Factory())
    }
}

class MultiTrackThumbnail(val context: Context, val uri: Uri, val trackIndex: Int)

internal class MultiTrackThumbnailLoader : ModelLoader<MultiTrackThumbnail, InputStream> {
    override fun buildLoadData(model: MultiTrackThumbnail, width: Int, height: Int, options: Options): ModelLoader.LoadData<InputStream> {
        return ModelLoader.LoadData(ObjectKey(model.uri), MultiTrackThumbnailFetcher(model, width, height))
    }

    override fun handles(MultiTrackThumbnail: MultiTrackThumbnail): Boolean = true

    internal class Factory : ModelLoaderFactory<MultiTrackThumbnail, InputStream> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<MultiTrackThumbnail, InputStream> = MultiTrackThumbnailLoader()

        override fun teardown() {}
    }
}

internal class MultiTrackThumbnailFetcher(val model: MultiTrackThumbnail, val width: Int, val height: Int) : DataFetcher<InputStream> {
    override fun loadData(priority: Priority, callback: DataCallback<in InputStream>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            callback.onLoadFailed(Exception("unsupported Android version"))
            return
        }

        val context = model.context
        val uri = model.uri
        val trackIndex = model.trackIndex

        val imageIndex = trackIndexToImageIndex(context, uri, trackIndex)
        if (imageIndex == null) {
            callback.onLoadFailed(Exception("no image index"))
            return
        }

        val bitmap: Bitmap?

        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return
        try {
            bitmap = retriever.getImageAtIndex(imageIndex)
        } catch (e: Exception) {
            callback.onLoadFailed(e)
            return
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }

        if (bitmap == null) {
            callback.onLoadFailed(Exception("null bitmap"))
        } else {
            callback.onDataReady(bitmap.getBytes()?.inputStream())
        }
    }

    private fun trackIndexToImageIndex(context: Context, uri: Uri, trackIndex: Int): Int? {
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(context, uri, null)
            val trackCount = extractor.trackCount
            if (trackIndex < trackCount) {
                var imageIndex = 0
                for (i in 0 until trackIndex) {
                    val mimeType = extractor.getTrackFormat(i).getString(MediaFormat.KEY_MIME)
                    if (MimeTypes.isImage(mimeType)) imageIndex++
                }
                return imageIndex
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get image index for uri=$uri, trackIndex=$trackIndex", e)
        } finally {
            extractor.release()
        }
        return null
    }

    // already cleaned up in loadData and ByteArrayInputStream will be GC'd
    override fun cleanup() {}

    // cannot cancel
    override fun cancel() {}

    override fun getDataClass(): Class<InputStream> = InputStream::class.java

    override fun getDataSource(): DataSource = DataSource.LOCAL

    companion object {
        private val LOG_TAG = LogUtils.createTag(MultiTrackThumbnailFetcher::class.java)
    }
}