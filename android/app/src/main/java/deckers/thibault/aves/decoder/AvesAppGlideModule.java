package deckers.thibault.aves.decoder;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.bumptech.glide.Glide;
import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.Registry;
import com.bumptech.glide.annotation.GlideModule;
import com.bumptech.glide.load.resource.bitmap.ExifInterfaceImageHeaderParser;
import com.bumptech.glide.module.AppGlideModule;

@GlideModule
public class AvesAppGlideModule extends AppGlideModule {
    @Override
    public void applyOptions(@NonNull Context context, @NonNull GlideBuilder builder) {
        // hide noisy warning (e.g. for images that can't be decoded)
        builder.setLogLevel(Log.ERROR);
    }

    @Override
    public void registerComponents(@NonNull Context context, @NonNull Glide glide, @NonNull Registry registry) {
        // prevent ExifInterface error logs
        // cf https://github.com/bumptech/glide/issues/3383
        glide.getRegistry().getImageHeaderParsers().removeIf(parser -> parser instanceof ExifInterfaceImageHeaderParser);
    }

    @Override
    public boolean isManifestParsingEnabled() {
        return false;
    }
}
