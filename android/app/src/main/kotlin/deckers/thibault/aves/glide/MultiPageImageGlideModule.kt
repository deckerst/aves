package deckers.thibault.aves.glide

import android.content.Context
import android.graphics.Bitmap
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
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.metadata.MultiTrackMedia
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isIsoBMFFImage

@GlideModule
class MultiPageImageGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(MultiPageImage::class.java, Bitmap::class.java, MultiPageThumbnailLoader.Factory())
    }
}

class MultiPageImage(val context: Context, val contentAddress: ContentAddress) {
    override fun toString(): String = "MultiPageImage#${hashCode()}{$contentAddress}"

    companion object {
        fun isSupported(mimeType: String) = isIsoBMFFImage(mimeType) || mimeType == MimeTypes.JPEG
    }
}

internal class MultiPageThumbnailLoader : ModelLoader<MultiPageImage, Bitmap> {
    override fun buildLoadData(model: MultiPageImage, width: Int, height: Int, options: Options): ModelLoader.LoadData<Bitmap> {
        val uri = model.contentAddress.uri
        return ModelLoader.LoadData(ObjectKey(uri), MultiPageImageFetcher(model, width, height))
    }

    override fun handles(model: MultiPageImage): Boolean = true

    internal class Factory : ModelLoaderFactory<MultiPageImage, Bitmap> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<MultiPageImage, Bitmap> = MultiPageThumbnailLoader()

        override fun teardown() {}
    }
}

internal class MultiPageImageFetcher(val model: MultiPageImage, val width: Int, val height: Int) : DataFetcher<Bitmap> {
    override fun loadData(priority: Priority, callback: DataCallback<in Bitmap>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            callback.onLoadFailed(Exception("unsupported Android version"))
            return
        }

        val context = model.context
        val contentAddress = model.contentAddress
        val mimeType = contentAddress.mimeType

        var bitmap: Bitmap? = null
        if (isIsoBMFFImage(mimeType)) {
            bitmap = MultiTrackMedia.getImage(context, contentAddress)
        } else if (mimeType == MimeTypes.JPEG) {
            bitmap = MultiPage.getJpegMpfBitmap(context, contentAddress)
        }

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