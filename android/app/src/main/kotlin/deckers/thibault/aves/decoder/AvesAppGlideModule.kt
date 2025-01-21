package deckers.thibault.aves.decoder

import android.content.Context
import android.net.Uri
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.GlideBuilder
import com.bumptech.glide.Registry
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.ImageHeaderParser
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.resource.bitmap.ExifInterfaceImageHeaderParser
import com.bumptech.glide.module.AppGlideModule
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.compatRemoveIf

@GlideModule
class AvesAppGlideModule : AppGlideModule() {
    override fun applyOptions(context: Context, builder: GlideBuilder) {
        // hide noisy warning (e.g. for images that can't be decoded)
        builder.setLogLevel(Log.ERROR)
    }

    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        // prevent ExifInterface error logs
        // cf https://github.com/bumptech/glide/issues/3383
        registry.imageHeaderParsers.compatRemoveIf { parser: ImageHeaderParser? -> parser is ExifInterfaceImageHeaderParser }
    }

    override fun isManifestParsingEnabled(): Boolean = false

    companion object {
        // request a fresh image with the highest quality format
        val uncachedFullImageOptions = RequestOptions()
            .format(DecodeFormat.PREFER_ARGB_8888)
            .diskCacheStrategy(DiskCacheStrategy.NONE)
            .skipMemoryCache(true)

        fun getModel(context: Context, uri: Uri, mimeType: String, pageId: Int?, sizeBytes: Long? = null): Any {
            return if (pageId != null && MultiPageImage.isSupported(mimeType)) {
                MultiPageImage(context, uri, mimeType, pageId)
            } else if (mimeType == MimeTypes.TIFF) {
                TiffImage(context, uri, pageId)
            } else if (mimeType == MimeTypes.SVG) {
                SvgImage(context, uri)
            } else if (isVideo(mimeType)) {
                VideoThumbnail(context, uri)
            } else {
                StorageUtils.getGlideSafeUri(context, uri, mimeType, sizeBytes)
            }
        }
    }
}