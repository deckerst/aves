package deckers.thibault.aves.model.provider;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import deckers.thibault.aves.model.SourceImageEntry;

class ContentImageProvider extends ImageProvider {
    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        SourceImageEntry entry = new SourceImageEntry(uri, mimeType).fillPreCatalogMetadata(context);

        if (entry.getHasSize() || entry.isSvg()) {
            callback.onSuccess(entry.toMap());
        } else {
            callback.onFailure(new Exception("entry has no size"));
        }
    }
}
