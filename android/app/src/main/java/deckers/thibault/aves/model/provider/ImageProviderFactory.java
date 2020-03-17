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
                    // a URI's authority is [userinfo@]host[:port]
                    // but we only want the host when comparing to MediaStore's "authority"
                    String host = uri.getHost();
                    if (host != null) {
                        switch (host) {
                            case MediaStore.AUTHORITY:
                                return new MediaStoreImageProvider();
//                            case Constants.DOWNLOADS_AUTHORITY:
//                                return new DownloadImageProvider();
                            default:
                                return new UnknownContentImageProvider();
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
