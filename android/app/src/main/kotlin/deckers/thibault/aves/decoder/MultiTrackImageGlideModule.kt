package deckers.thibault.aves.decoder

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
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
import deckers.thibault.aves.metadata.MultiTrackMedia


@GlideModule
class MultiTrackImageGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(MultiTrackImage::class.java, Bitmap::class.java, MultiTrackThumbnailLoader.Factory())
    }
}

class MultiTrackImage(val context: Context, val uri: Uri, val trackIndex: Int?)

internal class MultiTrackThumbnailLoader : ModelLoader<MultiTrackImage, Bitmap> {
    override fun buildLoadData(model: MultiTrackImage, width: Int, height: Int, options: Options): ModelLoader.LoadData<Bitmap> {
        return ModelLoader.LoadData(ObjectKey(model.uri), MultiTrackImageFetcher(model, width, height))
    }

    override fun handles(model: MultiTrackImage): Boolean = true

    internal class Factory : ModelLoaderFactory<MultiTrackImage, Bitmap> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<MultiTrackImage, Bitmap> = MultiTrackThumbnailLoader()

        override fun teardown() {}
    }
}

internal class MultiTrackImageFetcher(val model: MultiTrackImage, val width: Int, val height: Int) : DataFetcher<Bitmap> {
    override fun loadData(priority: Priority, callback: DataCallback<in Bitmap>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            callback.onLoadFailed(Exception("unsupported Android version"))
            return
        }

        val context = model.context
        val uri = model.uri
        val trackIndex = model.trackIndex

        val bitmap = MultiTrackMedia.getImage(context, uri, trackIndex)
        if (bitmap == null) {
            callback.onLoadFailed(Exception("null bitmap"))
        } else {
            callback.onDataReady(bitmap)
        }
    }

    override fun cleanup() {}

    // cannot cancel
    override fun cancel() {}

    override fun getDataClass(): Class<Bitmap> = Bitmap::class.java

    override fun getDataSource(): DataSource = DataSource.LOCAL
}