package deckers.thibault.aves.model.provider;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.FileUtils;
import deckers.thibault.aves.utils.Utils;

class FileImageProvider extends ImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(FileImageProvider.class);

    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        ImageEntry entry = new ImageEntry();
        entry.uri = uri;
        entry.mimeType = mimeType;

        String path = FileUtils.getPathFromUri(context, uri);
        if (path != null) {
            try {
                File file = new File(path);
                if (file.exists()) {
                    entry.path = path;
                    entry.title = file.getName();
                    entry.sizeBytes = file.length();
                    entry.dateModifiedSecs = file.lastModified() / 1000;
                }
            } catch (SecurityException e) {
                Log.w(LOG_TAG, "failed to get path from file at uri=" + uri);
                callback.onFailure();
            }
        }
        entry.fillPreCatalogMetadata(context);

        if (entry.hasSize()) {
            callback.onSuccess(entry.toMap());
        } else {
            callback.onFailure();
        }
    }
}