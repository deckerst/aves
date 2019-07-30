package deckers.thibault.aves.decoder;

import android.content.Context;

import androidx.annotation.NonNull;

import com.bumptech.glide.Glide;
import com.bumptech.glide.Registry;
import com.bumptech.glide.annotation.GlideModule;
import com.bumptech.glide.load.resource.bitmap.ExifInterfaceImageHeaderParser;
import com.bumptech.glide.module.LibraryGlideModule;

@GlideModule
public class NoExifInterfaceGlideModule extends LibraryGlideModule {
    @Override
    public void registerComponents(@NonNull Context context, @NonNull Glide glide, @NonNull Registry registry) {
        super.registerComponents(context, glide, registry);
        // prevent ExifInterface error logs
        // cf https://github.com/bumptech/glide/issues/3383
        glide.getRegistry().getImageHeaderParsers().removeIf(parser -> parser instanceof ExifInterfaceImageHeaderParser);
    }
}

