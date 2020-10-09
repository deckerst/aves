package deckers.thibault.aves.model.provider;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import java.io.File;

import deckers.thibault.aves.model.SourceImageEntry;
import deckers.thibault.aves.utils.FileUtils;

class FileImageProvider extends ImageProvider {
    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        SourceImageEntry entry = new SourceImageEntry(uri, mimeType);

        String path = FileUtils.getPathFromUri(context, uri);
        if (path != null) {
            try {
                File file = new File(path);
                if (file.exists()) {
                    entry.initFromFile(path, file.getName(), file.length(), file.lastModified() / 1000);
                }
            } catch (SecurityException e) {
                callback.onFailure(e);
            }
        }
        entry.fillPreCatalogMetadata(context);

        if (entry.getHasSize() || entry.isSvg()) {
            callback.onSuccess(entry.toMap());
        } else {
            callback.onFailure(new Exception("entry has no size"));
        }
    }
}