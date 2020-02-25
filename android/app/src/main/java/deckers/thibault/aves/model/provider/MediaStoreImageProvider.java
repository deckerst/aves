package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.content.ContentUris;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import java.util.stream.Stream;

import deckers.thibault.aves.model.ImageEntry;
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
        fetch(activity, entrySink, MediaStore.Images.Media.EXTERNAL_CONTENT_URI, IMAGE_PROJECTION);
        fetch(activity, entrySink, MediaStore.Video.Media.EXTERNAL_CONTENT_URI, VIDEO_PROJECTION);
    }

    private void fetch(final Activity activity, EventChannel.EventSink entrySink, final Uri contentUri, String[] projection) {
        String orderBy = MediaStore.MediaColumns.DATE_TAKEN + " DESC";

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
                    Uri itemUri = ContentUris.withAppendedId(contentUri, contentId);
                    ImageEntry imageEntry = new ImageEntry(
                            itemUri,
                            cursor.getString(pathColumn),
                            contentId,
                            cursor.getString(mimeTypeColumn),
                            cursor.getInt(widthColumn),
                            cursor.getInt(heightColumn),
                            cursor.getInt(orientationColumn),
                            cursor.getLong(sizeColumn),
                            cursor.getString(titleColumn),
                            cursor.getLong(dateModifiedColumn),
                            cursor.getLong(dateTakenColumn),
                            cursor.getString(bucketDisplayNameColumn),
                            durationColumn != -1 ? cursor.getLong(durationColumn) : 0
                    );
                    // TODO TLAD sanitize mimeType
                    // problem: some images were added as image/jpeg, but they're actually image/png
                    // possible solution:
                    // 1) check that MediaStore mimeType matches expected mimeType from file path extension
                    // 2) extract actual mimeType with metadata-extractor
                    // 3) update MediaStore
                    if (imageEntry.getWidth() > 0) {
                        // TODO TLAD avoid creating ImageEntry to convert it right after
                        entrySink.success(ImageEntry.toMap(imageEntry));
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
}