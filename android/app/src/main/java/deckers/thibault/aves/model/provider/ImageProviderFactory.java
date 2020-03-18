package deckers.thibault.aves.model.provider;

import android.content.ContentResolver;
import android.net.Uri;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

public class ImageProviderFactory {
    public static ImageProvider getProvider(@NonNull Uri uri) {
        String scheme = uri.getScheme();

        if (ContentResolver.SCHEME_CONTENT.equalsIgnoreCase(scheme)) {
            // a URI's authority is [userinfo@]host[:port]
            // but we only want the host when comparing to Media Store's "authority"
            if (MediaStore.AUTHORITY.equalsIgnoreCase(uri.getHost())) {
                return new MediaStoreImageProvider();
            }
            return new ContentImageProvider();
        }

        if (ContentResolver.SCHEME_FILE.equalsIgnoreCase(scheme)) {
            return new FileImageProvider();
        }

        return null;
    }
}
