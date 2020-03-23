package deckers.thibault.aves.model.provider;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import deckers.thibault.aves.model.ImageEntry;

class ContentImageProvider extends ImageProvider {
    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        ImageEntry entry = new ImageEntry();
        entry.uri = uri;
        entry.mimeType = mimeType;
        entry.fillPreCatalogMetadata(context);

        if (entry.hasSize() || entry.isSvg()) {
            callback.onSuccess(entry.toMap());
        } else {
            callback.onFailure();
        }
    }
}
