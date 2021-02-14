package deckers.thibault.aves.decoder

import android.content.Context
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.GlideBuilder
import com.bumptech.glide.Registry
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.load.ImageHeaderParser
import com.bumptech.glide.load.resource.bitmap.ExifInterfaceImageHeaderParser
import com.bumptech.glide.module.AppGlideModule
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
        glide.registry.imageHeaderParsers.compatRemoveIf { parser: ImageHeaderParser? -> parser is ExifInterfaceImageHeaderParser }
    }

    override fun isManifestParsingEnabled(): Boolean = false
}