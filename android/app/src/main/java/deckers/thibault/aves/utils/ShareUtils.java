package deckers.thibault.aves.utils;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

public class ShareUtils {
    public static void share(Activity activity, String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_STREAM, uri);
        intent.setType(mimeType);
        activity.startActivity(Intent.createChooser(intent, title));
    }
}