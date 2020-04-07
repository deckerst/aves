package deckers.thibault.aves.model.provider;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Stream;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.MimeTypes;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.StorageUtils;
import deckers.thibault.aves.utils.Utils;

public class MediaStoreImageProvider extends ImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(MediaStoreImageProvider.class);

    private static final String[] BASE_PROJECTION = {
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.TITLE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.DATE_MODIFIED,
    };

    @SuppressLint("InlinedApi")
    private static final String[] IMAGE_PROJECTION = Stream.of(BASE_PROJECTION, new String[]{
            // uses MediaStore.Images.Media instead of MediaStore.MediaColumns for APIs < Q
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Images.Media.ORIENTATION,
    }).flatMap(Stream::of).toArray(String[]::new);

    @SuppressLint("InlinedApi")
    private static final String[] VIDEO_PROJECTION = Stream.of(BASE_PROJECTION, new String[]{
            // uses MediaStore.Video.Media instead of MediaStore.MediaColumns for APIs < Q
            MediaStore.Video.Media.DATE_TAKEN,
            MediaStore.Video.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Video.Media.DURATION,
    }, (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) ?
            new String[]{
                    MediaStore.Video.Media.ORIENTATION,
            } : new String[0]).flatMap(Stream::of).toArray(String[]::new);

    public void fetchAll(Activity activity, NewEntryHandler newEntryHandler) {
        fetchFrom(activity, newEntryHandler, MediaStore.Images.Media.EXTERNAL_CONTENT_URI, IMAGE_PROJECTION);
        fetchFrom(activity, newEntryHandler, MediaStore.Video.Media.EXTERNAL_CONTENT_URI, VIDEO_PROJECTION);
    }

    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        long id = ContentUris.parseId(uri);
        int entryCount = 0;
        NewEntryHandler onSuccess = (entry) -> {
            entry.put("uri", uri.toString());
            callback.onSuccess(entry);
        };
        if (mimeType.startsWith(MimeTypes.IMAGE)) {
            Uri contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id);
            entryCount = fetchFrom(context, onSuccess, contentUri, IMAGE_PROJECTION);
        } else if (mimeType.startsWith(MimeTypes.VIDEO)) {
            Uri contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id);
            entryCount = fetchFrom(context, onSuccess, contentUri, VIDEO_PROJECTION);
        }
        if (entryCount == 0) {
            callback.onFailure();
        }
    }

    @SuppressLint("InlinedApi")
    private int fetchFrom(final Context context, NewEntryHandler newEntryHandler, final Uri contentUri, String[] projection) {
        String orderBy = MediaStore.MediaColumns.DATE_TAKEN + " DESC";
        int entryCount = 0;

        final boolean needDuration = projection == VIDEO_PROJECTION;

        try {
            Cursor cursor = context.getContentResolver().query(contentUri, projection, null, null, orderBy);
            if (cursor != null) {
                // image & video
                int idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID);
                int pathColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA);
                int mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE);
                int sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE);
                int titleColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE);
                int widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH);
                int heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT);
                int dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED);
                int dateTakenColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_TAKEN);
                int bucketDisplayNameColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.BUCKET_DISPLAY_NAME);

                // image & video for API >= Q, only for images for API < Q
                int orientationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.ORIENTATION);

                // video only
                int durationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.DURATION);

                while (cursor.moveToNext()) {
                    final long contentId = cursor.getLong(idColumn);
                    // this is fine if `contentUri` does not already contain the ID
                    final Uri itemUri = ContentUris.withAppendedId(contentUri, contentId);
                    final String path = cursor.getString(pathColumn);
                    final String mimeType = cursor.getString(mimeTypeColumn);
                    int width = cursor.getInt(widthColumn);
                    int height = cursor.getInt(heightColumn);
                    long durationMillis = durationColumn != -1 ? cursor.getLong(durationColumn) : 0;

                    Map<String, Object> entryMap = new HashMap<String, Object>() {{
                        put("uri", itemUri.toString());
                        put("path", path);
                        put("mimeType", mimeType);
                        put("orientationDegrees", orientationColumn != -1 ? cursor.getInt(orientationColumn) : 0);
                        put("sizeBytes", cursor.getLong(sizeColumn));
                        put("title", cursor.getString(titleColumn));
                        put("dateModifiedSecs", cursor.getLong(dateModifiedColumn));
                        put("sourceDateTakenMillis", cursor.getLong(dateTakenColumn));
                        put("bucketDisplayName", cursor.getString(bucketDisplayNameColumn));
                        // only for map export
                        put("contentId", contentId);
                    }};
                    entryMap.put("width", width);
                    entryMap.put("height", height);
                    entryMap.put("durationMillis", durationMillis);

                    if (((width <= 0 || height <= 0) && needSize(mimeType)) || (durationMillis == 0 && needDuration)) {
                        // some images are incorrectly registered in the Media Store,
                        // they are valid but miss some attributes, such as width, height, orientation
                        ImageEntry entry = new ImageEntry(entryMap).fillPreCatalogMetadata(context);
                        entryMap = entry.toMap();
                        width = entry.width != null ? entry.width : 0;
                        height = entry.height != null ? entry.height : 0;
                    }

                    if ((width <= 0 || height <= 0) && needSize(mimeType)) {
                        // this is probably not a real image, like "/storage/emulated/0", so we skip it
                        Log.w(LOG_TAG, "failed to get size for uri=" + itemUri + ", path=" + path + ", mimeType=" + mimeType);
                    } else {
                        newEntryHandler.handleEntry(entryMap);
                        entryCount++;
                    }
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to get entries", e);
        }
        return entryCount;
    }

    private boolean needSize(String mimeType) {
        return !MimeTypes.SVG.equals(mimeType);
    }

    @Override
    public void delete(final Activity activity, final String path, final Uri uri, final ImageOpCallback callback) {
        // check write access permission to SD card
        // Before KitKat, we do whatever we want on the SD card.
        // From KitKat, we need access permission from the Document Provider, at the file level.
        // From Lollipop, we can request the permission at the SD card root level.
        if (Env.isOnSdCard(activity, path)) {
            Uri sdCardTreeUri = PermissionManager.getSdCardTreeUri(activity);
            if (sdCardTreeUri == null) {
                Runnable runnable = () -> delete(activity, path, uri, callback);
                PermissionManager.showSdCardAccessDialog(activity, runnable);
                return;
            }

            // if the file is on SD card, calling the content resolver delete() removes the entry from the Media Store
            // but it doesn't delete the file, even if the app has the permission
            StorageUtils.deleteFromSdCard(activity, sdCardTreeUri, Env.getStorageVolumes(activity), path);
            Log.d(LOG_TAG, "deleted from SD card at path=" + uri);
            callback.onSuccess(null);
            return;
        }

        if (activity.getContentResolver().delete(uri, null, null) > 0) {
            Log.d(LOG_TAG, "deleted from content resolver uri=" + uri);
            callback.onSuccess(null);
            return;
        }

        callback.onFailure();
    }

    public interface NewEntryHandler {
        void handleEntry(Map<String, Object> entry);
    }
}