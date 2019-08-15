package deckers.thibault.aves.model.provider;

import android.content.ContentResolver;
import android.net.Uri;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

public class ImageProviderFactory {
    public static ImageProvider getProvider(@NonNull Uri uri) {
        String scheme = uri.getScheme();
        if (scheme != null) {
            switch (scheme) {
                case ContentResolver.SCHEME_CONTENT: // content://
                    String authority = uri.getAuthority();
                    if (authority != null) {
                        switch (authority) {
                            case MediaStore.AUTHORITY:
                                return new MediaStoreImageProvider();
//                            case Constants.DOWNLOADS_AUTHORITY:
//                                return new DownloadImageProvider();
                        }
                    }
                    return null;
//                case ContentResolver.SCHEME_FILE: // file://
//                    return new FileImageProvider();
            }
        }
        return null;
    }
}
