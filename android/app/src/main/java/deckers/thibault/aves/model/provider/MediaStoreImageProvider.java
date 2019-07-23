package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.content.ContentUris;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.Utils;

public class MediaStoreImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(MediaStoreImageProvider.class);

    private Uri FILES_URI = MediaStore.Files.getContentUri("external");

    private static final String[] PROJECTION = {
            // image & video
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.TITLE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.Images.Media.ORIENTATION,
            MediaStore.MediaColumns.DATE_MODIFIED,
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
            // video only
            MediaStore.Video.Media.DURATION,
    };

    private static final String SELECTION = MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
            + " OR " + MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO;


    public List<ImageEntry> fetchAll(Activity activity) {
        return fetch(activity, FILES_URI);
    }

    private List<ImageEntry> fetch(final Activity activity, final Uri queryUri) {
        ArrayList<ImageEntry> entries = new ArrayList<>();

        // URI should refer to the "files" table, not to the "images" or "videos" one,
        // as our projection includes a mix of columns from both
        Uri filesUri = queryUri;
        if (!FILES_URI.equals(queryUri)) {
            String id = queryUri.getLastPathSegment();
            filesUri = Uri.withAppendedPath(FILES_URI, id);
        }

        String orderBy = MediaStore.Images.ImageColumns.DATE_TAKEN + " DESC";

        try {
            Cursor cursor = activity.getContentResolver().query(filesUri, PROJECTION, SELECTION, null, orderBy);
            if (cursor != null) {
                int idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID);
                int pathColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA);
                int mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE);
                int sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE);
                int titleColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE);
                int widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH);
                int heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT);
                int orientationColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.ORIENTATION);
                int dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED);
                int dateTakenColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_TAKEN);
                int bucketDisplayNameColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
                int durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION);

                while (cursor.moveToNext()) {
                    long contentId = cursor.getLong(idColumn);
                    Uri itemUri = ContentUris.withAppendedId(FILES_URI, contentId);
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
                            cursor.getLong(durationColumn)
                    );
                    if (imageEntry.getWidth() > 0) {
                        entries.add(imageEntry);
//                        } else {
//                            // some images are incorrectly registered in the MediaStore,
//                            // they are valid but miss some attributes, such as width, height, orientation
//                            try {
//                                imageEntry.fixMissingWidthHeightOrientation(activity);
//                                entries.add(imageEntry);
//                            } catch (IOException e) {
//                                // this is probably not a real image, like "/storage/emulated/0", so we skip it
//                                Log.w(LOG_TAG, "failed to compute dimensions of imageEntry=" + imageEntry);
//                            }
                    }
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.d(LOG_TAG, "failed to get entries", e);
        }
        return entries;
    }
}
