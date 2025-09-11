package deckers.thibault.aves.glide

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
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.metadata.MultiTrackMedia
import deckers.thibault.aves.utils.MimeTypes

@GlideModule
class MultiPageImageGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(MultiPageImage::class.java, Bitmap::class.java, MultiPageThumbnailLoader.Factory())
    }
}

class MultiPageImage(val context: Context, val uri: Uri, val mimeType: String, val pageId: Int?) {
    override fun toString(): String = "MultiPageImage#${hashCode()}{uri=$uri, mimeType=$mimeType, pageId=$pageId}"

    companion object {
        fun isSupported(mimeType: String) = MimeTypes.isHeic(mimeType) || mimeType == MimeTypes.JPEG
    }
}

internal class MultiPageThumbnailLoader : ModelLoader<MultiPageImage, Bitmap> {
    override fun buildLoadData(model: MultiPageImage, width: Int, height: Int, options: Options): ModelLoader.LoadData<Bitmap> {
        return ModelLoader.LoadData(ObjectKey(model.uri), MultiPageImageFetcher(model, width, height))
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
        val uri = model.uri
        val mimeType = model.mimeType

        var bitmap: Bitmap? = null
        if (MimeTypes.isHeic(mimeType)) {
            val trackIndex = model.pageId
            bitmap = MultiTrackMedia.getImage(context, uri, trackIndex)
        } else if (mimeType == MimeTypes.JPEG) {
            val pageIndex = model.pageId ?: 0
            bitmap = MultiPage.getJpegMpfBitmap(context, uri, pageIndex)
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