package deckers.thibault.aves.decoder

import android.content.Context
import android.net.Uri
import android.text.format.Formatter
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.GlideBuilder
import com.bumptech.glide.Registry
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.ImageHeaderParser
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPoolAdapter
import com.bumptech.glide.load.engine.bitmap_recycle.LruArrayPool
import com.bumptech.glide.load.engine.bitmap_recycle.LruBitmapPool
import com.bumptech.glide.load.engine.cache.DiskCache
import com.bumptech.glide.load.engine.cache.InternalCacheDiskCacheFactory
import com.bumptech.glide.load.engine.cache.LruResourceCache
import com.bumptech.glide.load.engine.cache.MemorySizeCalculator
import com.bumptech.glide.load.resource.bitmap.ExifInterfaceImageHeaderParser
import com.bumptech.glide.module.AppGlideModule
import com.bumptech.glide.request.RequestOptions
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.compatRemoveIf

@GlideModule
class AvesAppGlideModule : AppGlideModule() {
    override fun applyOptions(context: Context, builder: GlideBuilder) {
        // hide noisy warning (e.g. for images that can't be decoded)
        builder.setLogLevel(Log.ERROR)

        // sizing
        val memorySizeCalculator = MemorySizeCalculator.Builder(context).build()
        builder.setMemorySizeCalculator(memorySizeCalculator)
        val size: Int = memorySizeCalculator.bitmapPoolSize
        if (size > 0) {
            builder.setBitmapPool(LruBitmapPool(size.toLong()))
        } else {
            builder.setBitmapPool(BitmapPoolAdapter())
        }
        builder.setArrayPool(LruArrayPool(memorySizeCalculator.arrayPoolSizeInBytes))
        builder.setMemoryCache(LruResourceCache(memorySizeCalculator.memoryCacheSize.toLong()))

        val diskCacheSize = DiskCache.Factory.DEFAULT_DISK_CACHE_SIZE
        val internalCacheDiskCacheFactory = InternalCacheDiskCacheFactory(context, DiskCache.Factory.DEFAULT_DISK_CACHE_DIR, diskCacheSize.toLong())
        builder.setDiskCache(internalCacheDiskCacheFactory)

        fun toMb(bytes: Int) = Formatter.formatFileSize(context, bytes.toLong())
        Log.d(
            LOG_TAG, "Glide disk cache size=${toMb(diskCacheSize)}" +
                    ", memory cache size=${toMb(memorySizeCalculator.memoryCacheSize)}" +
                    ", bitmap pool size=${toMb(memorySizeCalculator.bitmapPoolSize)}" +
                    ", array pool size=${toMb(memorySizeCalculator.arrayPoolSizeInBytes)}"
        )
    }

    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        // prevent ExifInterface error logs
        // cf https://github.com/bumptech/glide/issues/3383
        registry.imageHeaderParsers.compatRemoveIf { parser: ImageHeaderParser? -> parser is ExifInterfaceImageHeaderParser }
    }

    override fun isManifestParsingEnabled(): Boolean = false

    companion object {
        private val LOG_TAG = LogUtils.createTag<AvesAppGlideModule>()

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