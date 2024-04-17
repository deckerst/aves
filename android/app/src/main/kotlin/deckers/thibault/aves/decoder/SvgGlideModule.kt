package deckers.thibault.aves.decoder

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import com.bumptech.glide.Glide
import com.bumptech.glide.Priority
import com.bumptech.glide.Registry
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.Options
import com.bumptech.glide.load.data.DataFetcher
import com.bumptech.glide.load.model.ModelLoader
import com.bumptech.glide.load.model.ModelLoaderFactory
import com.bumptech.glide.load.model.MultiModelLoaderFactory
import com.bumptech.glide.module.LibraryGlideModule
import com.bumptech.glide.signature.ObjectKey
import com.caverock.androidsvg.SVG
import com.caverock.androidsvg.SVGParseException
import deckers.thibault.aves.metadata.SVGParserBufferedInputStream
import deckers.thibault.aves.metadata.SvgHelper.normalizeSize
import deckers.thibault.aves.utils.StorageUtils
import kotlin.math.ceil

@GlideModule
class SvgGlideModule : LibraryGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        registry.append(SvgImage::class.java, Bitmap::class.java, SvgLoader.Factory())
    }
}

class SvgImage(val context: Context, val uri: Uri)

internal class SvgLoader : ModelLoader<SvgImage, Bitmap> {
    override fun buildLoadData(model: SvgImage, width: Int, height: Int, options: Options): ModelLoader.LoadData<Bitmap> {
        return ModelLoader.LoadData(ObjectKey(model.uri), SvgFetcher(model, width, height))
    }

    override fun handles(model: SvgImage): Boolean = true

    internal class Factory : ModelLoaderFactory<SvgImage, Bitmap> {
        override fun build(multiFactory: MultiModelLoaderFactory): ModelLoader<SvgImage, Bitmap> = SvgLoader()

        override fun teardown() {}
    }
}

internal class SvgFetcher(val model: SvgImage, val width: Int, val height: Int) : DataFetcher<Bitmap> {
    override fun loadData(priority: Priority, callback: DataFetcher.DataCallback<in Bitmap>) {
        val context = model.context
        val uri = model.uri

        val bitmap: Bitmap? = StorageUtils.openInputStream(context, uri)?.use { input ->
            try {
                SVG.getFromInputStream(SVGParserBufferedInputStream(input))?.let { svg ->
                    svg.normalizeSize()
                    val viewBox = svg.documentViewBox
                    val svgWidth = viewBox.width()
                    val svgHeight = viewBox.height()

                    val bitmapWidth: Int
                    val bitmapHeight: Int
                    if (width / height > svgWidth / svgHeight) {
                        bitmapWidth = ceil(svgWidth * height / svgHeight).toInt()
                        bitmapHeight = height
                    } else {
                        bitmapWidth = width
                        bitmapHeight = ceil(svgHeight * width / svgWidth).toInt()
                    }
                    val bitmap = Bitmap.createBitmap(bitmapWidth, bitmapHeight, Bitmap.Config.ARGB_8888)

                    val canvas = Canvas(bitmap)
                    svg.renderToCanvas(canvas)
                    bitmap
                }
            } catch (ex: SVGParseException) {
                callback.onLoadFailed(ex)
                return
            }
        }

        if (bitmap == null) {
            callback.onLoadFailed(Exception("failed to load SVG for uri=$uri"))
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
