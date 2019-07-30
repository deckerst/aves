package deckers.thibault.aves.decoder;

import android.content.Context;
import android.net.Uri;

public class VideoThumbnail {
    private Context mContext;
    private Uri mUri;

    public VideoThumbnail(Context context, Uri uri) {
        mContext = context;
        mUri = uri;
    }

    public Context getContext() {
        return mContext;
    }

    Uri getUri() {
        return mUri;
    }
}