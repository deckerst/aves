package deckers.thibault.aves.model.provider;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import deckers.thibault.aves.model.SourceImageEntry;

class ContentImageProvider extends ImageProvider {
    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @Nullable final String mimeType, @NonNull final ImageOpCallback callback) {
        if (mimeType == null) {
            callback.onFailure(new Exception("MIME type is null for uri=" + uri));
            return;
        }

        Map<String, Object> map = new HashMap<>();
        map.put("uri", uri.toString());
        map.put("sourceMimeType", mimeType);

        String[] projection = {
                MediaStore.MediaColumns.SIZE,
                MediaStore.MediaColumns.DISPLAY_NAME,
        };
        try {
            Cursor cursor = context.getContentResolver().query(uri, projection, null, null, null);
            if (cursor != null) {
                if (cursor.moveToNext()) {
                    map.put("sizeBytes", cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)));
                    map.put("title", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)));
                }
                cursor.close();
            }
        } catch (Exception e) {
            callback.onFailure(e);
            return;
        }

        SourceImageEntry entry = new SourceImageEntry(map).fillPreCatalogMetadata(context);
        if (entry.isSized() || entry.isSvg()) {
            callback.onSuccess(entry.toMap());
        } else {
            callback.onFailure(new Exception("entry has no size"));
        }
    }
}
