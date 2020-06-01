package deckers.thibault.aves.model.provider;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import java.io.File;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.FileUtils;

class FileImageProvider extends ImageProvider {
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
                callback.onFailure(e);
            }
        }
        entry.fillPreCatalogMetadata(context);

        if (entry.hasSize() || entry.isSvg()) {
            callback.onSuccess(entry.toMap());
        } else {
            callback.onFailure(new Exception("entry has no size"));
        }
    }
}