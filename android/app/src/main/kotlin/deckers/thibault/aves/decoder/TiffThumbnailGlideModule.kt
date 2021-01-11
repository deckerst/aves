package deckers.thibault.aves.decoder

import android.content.Context
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
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.InputStream

@GlideModule
class TiffThumbnailGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(TiffThumbnail::class.java, InputStream::class.java, TiffThumbnailLoader.Factory())
    }
}

class TiffThumbnail(val context: Context, val uri: Uri, val page: Int)

internal class TiffThumbnailLoader : ModelLoader<TiffThumbnail, InputStream> {
    override fun buildLoadData(model: TiffThumbnail, width: Int, height: Int, options: Options): ModelLoader.LoadData<InputStream> {
        return ModelLoader.LoadData(ObjectKey(model.uri), TiffThumbnailFetcher(model, width, height))
    }

    override fun handles(tiffThumbnail: TiffThumbnail): Boolean = true

    internal class Factory : ModelLoaderFactory<TiffThumbnail, InputStream> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<TiffThumbnail, InputStream> = TiffThumbnailLoader()

        override fun teardown() {}
    }
}

internal class TiffThumbnailFetcher(val model: TiffThumbnail, val width: Int, val height: Int) : DataFetcher<InputStream> {
    override fun loadData(priority: Priority, callback: DataCallback<in InputStream>) {
        val context = model.context
        val uri = model.uri
        val page = model.page

        // determine sample size
        var fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
        if (fd == null) {
            callback.onLoadFailed(Exception("null file descriptor"))
            return
        }
        var sampleSize = 1
        var options = TiffBitmapFactory.Options().apply {
            inJustDecodeBounds = true
            inDirectoryNumber = page
        }
        TiffBitmapFactory.decodeFileDescriptor(fd, options)
        val imageWidth = options.outWidth
        val imageHeight = options.outHeight
        if (imageHeight > height || imageWidth > width) {
            while (imageHeight / (sampleSize * 2) > height && imageWidth / (sampleSize * 2) > width) {
                sampleSize *= 2
            }
        }

        // decode
        fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
        if (fd == null) {
            callback.onLoadFailed(Exception("null file descriptor"))
            return
        }
        options = TiffBitmapFactory.Options().apply {
            inJustDecodeBounds = false
            inDirectoryNumber = page
            inSampleSize = sampleSize
        }
        val bitmap = TiffBitmapFactory.decodeFileDescriptor(fd, options)
        if (bitmap == null) {
            callback.onLoadFailed(Exception("null bitmap"))
        } else {
            callback.onDataReady(bitmap.getBytes().inputStream())
        }
    }

    // already cleaned up in loadData and ByteArrayInputStream will be GC'd
    override fun cleanup() {}

    // cannot cancel
    override fun cancel() {}

    override fun getDataClass(): Class<InputStream> = InputStream::class.java

    override fun getDataSource(): DataSource = DataSource.LOCAL
}