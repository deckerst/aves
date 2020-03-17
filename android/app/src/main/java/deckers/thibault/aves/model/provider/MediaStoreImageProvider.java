package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.content.ContentUris;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Stream;

import deckers.thibault.aves.utils.Constants;
import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.StorageUtils;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.EventChannel;

public class MediaStoreImageProvider extends ImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(MediaStoreImageProvider.class);

    private static final String[] IMAGE_PROJECTION = {
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.TITLE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.ORIENTATION,
            MediaStore.MediaColumns.DATE_MODIFIED,
            MediaStore.MediaColumns.DATE_TAKEN,
            MediaStore.MediaColumns.BUCKET_DISPLAY_NAME,
    };

    private static final String[] VIDEO_PROJECTION = Stream.of(IMAGE_PROJECTION, new String[]{
            MediaStore.MediaColumns.DURATION
    }).flatMap(Stream::of).toArray(String[]::new);

    public void fetchAll(Activity activity, EventChannel.EventSink entrySink) {
        NewEntryHandler success = entrySink::success;
        fetchFrom(activity, success, MediaStore.Images.Media.EXTERNAL_CONTENT_URI, IMAGE_PROJECTION);
        fetchFrom(activity, success, MediaStore.Video.Media.EXTERNAL_CONTENT_URI, VIDEO_PROJECTION);
    }

    @Override
    public void fetchSingle(final Activity activity, final Uri uri, final String mimeType, final ImageOpCallback callback) {
        long id = ContentUris.parseId(uri);
        int entryCount = 0;
        NewEntryHandler onSuccess = (entry) -> {
            entry.put("uri", uri.toString());
            callback.onSuccess(entry);
        };
        if (mimeType.startsWith(Constants.MIME_IMAGE)) {
            Uri contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id);
            entryCount = fetchFrom(activity, onSuccess, contentUri, IMAGE_PROJECTION);
        } else if (mimeType.startsWith(Constants.MIME_VIDEO)) {
            Uri contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id);
            entryCount = fetchFrom(activity, onSuccess, contentUri, VIDEO_PROJECTION);
        }
        if (entryCount == 0) {
            callback.onFailure();
        }
    }

    private int fetchFrom(final Activity activity, NewEntryHandler newEntryHandler, final Uri contentUri, String[] projection) {
        String orderBy = MediaStore.MediaColumns.DATE_TAKEN + " DESC";
        int entryCount = 0;

        try {
            Cursor cursor = activity.getContentResolver().query(contentUri, projection, null, null, orderBy);
            if (cursor != null) {
                // image & video
                int idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID);
                int pathColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA);
                int mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE);
                int sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE);
                int titleColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE);
                int widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH);
                int heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT);
                int orientationColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.ORIENTATION);
                int dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED);
                int dateTakenColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_TAKEN);
                int bucketDisplayNameColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.BUCKET_DISPLAY_NAME);
                // video only
                int durationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.DURATION);

                while (cursor.moveToNext()) {
                    long contentId = cursor.getLong(idColumn);
                    // this is fine if `contentUri` does not already contain the ID
                    Uri itemUri = ContentUris.withAppendedId(contentUri, contentId);
                    int width = cursor.getInt(widthColumn);
                    // TODO TLAD sanitize mimeType
                    // problem: some images were added as image/jpeg, but they're actually image/png
                    // possible solution:
                    // 1) check that MediaStore mimeType matches expected mimeType from file path extension
                    // 2) extract actual mimeType with metadata-extractor
                    // 3) update MediaStore
                    if (width > 0) {
                        newEntryHandler.handleEntry(
                                new HashMap<String, Object>() {{
                                    put("uri", itemUri.toString());
                                    put("path", cursor.getString(pathColumn));
                                    put("contentId", contentId);
                                    put("mimeType", cursor.getString(mimeTypeColumn));
                                    put("width", width);
                                    put("height", cursor.getInt(heightColumn));
                                    put("orientationDegrees", cursor.getInt(orientationColumn));
                                    put("sizeBytes", cursor.getLong(sizeColumn));
                                    put("title", cursor.getString(titleColumn));
                                    put("dateModifiedSecs", cursor.getLong(dateModifiedColumn));
                                    put("sourceDateTakenMillis", cursor.getLong(dateTakenColumn));
                                    put("bucketDisplayName", cursor.getString(bucketDisplayNameColumn));
                                    put("durationMillis", durationColumn != -1 ? cursor.getLong(durationColumn) : 0);
                                }});
                        entryCount++;
//                    } else {
//                        // some images are incorrectly registered in the MediaStore,
//                        // they are valid but miss some attributes, such as width, height, orientation
//                        try {
//                            imageEntry.fixMissingWidthHeightOrientation(activity);
//                            entrySink.success(imageEntry);
//                        } catch (IOException e) {
//                            // this is probably not a real image, like "/storage/emulated/0", so we skip it
//                            Log.w(LOG_TAG, "failed to compute dimensions of imageEntry=" + imageEntry);
//                        }
                    }
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to get entries", e);
        }
        return entryCount;
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

            // if the file is on SD card, calling the content resolver delete() removes the entry from the MediaStore
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

    private interface NewEntryHandler {
        void handleEntry(Map<String, Object> entry);
    }
}