package deckers.thibault.aves.model.provider;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import com.commonsware.cwac.document.DocumentFileCompat;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.SettableFuture;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
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
            // TODO TLAD use `DISPLAY_NAME` instead/along `TITLE`?
            MediaStore.MediaColumns.TITLE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.DATE_MODIFIED,
    };

    @SuppressLint("InlinedApi")
    private static final String[] IMAGE_PROJECTION = Stream.of(BASE_PROJECTION, new String[]{
            // uses MediaStore.Images.Media instead of MediaStore.MediaColumns for APIs < Q
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.ORIENTATION,
    }).flatMap(Stream::of).toArray(String[]::new);

    @SuppressLint("InlinedApi")
    private static final String[] VIDEO_PROJECTION = Stream.of(BASE_PROJECTION, new String[]{
            // uses MediaStore.Video.Media instead of MediaStore.MediaColumns for APIs < Q
            MediaStore.Video.Media.DATE_TAKEN,
            MediaStore.Video.Media.DURATION,
    }, (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) ?
            new String[]{
                    MediaStore.Video.Media.ORIENTATION,
            } : new String[0]).flatMap(Stream::of).toArray(String[]::new);

    public void fetchAll(Context context, Map<Integer, Integer> knownEntries, NewEntryHandler newEntryHandler) {
        NewEntryChecker isModified = (contentId, dateModifiedSecs) -> {
            final Integer knownDate = knownEntries.get(contentId);
            return knownDate == null || knownDate < dateModifiedSecs;
        };
        fetchFrom(context, isModified, newEntryHandler, MediaStore.Images.Media.EXTERNAL_CONTENT_URI, IMAGE_PROJECTION);
        fetchFrom(context, isModified, newEntryHandler, MediaStore.Video.Media.EXTERNAL_CONTENT_URI, VIDEO_PROJECTION);
    }

    @Override
    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        long id = ContentUris.parseId(uri);
        int entryCount = 0;
        NewEntryHandler onSuccess = (entry) -> {
            entry.put("uri", uri.toString());
            callback.onSuccess(entry);
        };
        NewEntryChecker alwaysValid = (contentId, dateModifiedSecs) -> true;
        if (mimeType.startsWith(MimeTypes.IMAGE)) {
            Uri contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id);
            entryCount = fetchFrom(context, alwaysValid, onSuccess, contentUri, IMAGE_PROJECTION);
        } else if (mimeType.startsWith(MimeTypes.VIDEO)) {
            Uri contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id);
            entryCount = fetchFrom(context, alwaysValid, onSuccess, contentUri, VIDEO_PROJECTION);
        }
        if (entryCount == 0) {
            callback.onFailure(new Exception("failed to fetch entry at uri=" + uri));
        }
    }

    public List<Integer> getObsoleteContentIds(Context context, List<Integer> knownContentIds) {
        final ArrayList<Integer> current = new ArrayList<>();
        current.addAll(getContentIdList(context, MediaStore.Images.Media.EXTERNAL_CONTENT_URI));
        current.addAll(getContentIdList(context, MediaStore.Video.Media.EXTERNAL_CONTENT_URI));
        return knownContentIds.stream().filter(id -> !current.contains(id)).collect(Collectors.toList());
    }

    private List<Integer> getContentIdList(Context context, Uri contentUri) {
        final ArrayList<Integer> foundContentIds = new ArrayList<>();
        try {
            Cursor cursor = context.getContentResolver().query(contentUri, new String[]{MediaStore.MediaColumns._ID}, null, null, null);
            if (cursor != null) {
                int idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID);
                while (cursor.moveToNext()) {
                    foundContentIds.add(cursor.getInt(idColumn));
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to get content IDs for contentUri=" + contentUri, e);
        }
        return foundContentIds;
    }

    @SuppressLint("InlinedApi")
    private int fetchFrom(final Context context, NewEntryChecker newEntryChecker, NewEntryHandler newEntryHandler, final Uri contentUri, String[] projection) {
        int newEntryCount = 0;
        final boolean needDuration = projection == VIDEO_PROJECTION;
        final String orderBy = MediaStore.MediaColumns.DATE_MODIFIED + " DESC";

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

                // image & video for API >= Q, only for images for API < Q
                int orientationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.ORIENTATION);

                // video only
                int durationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.DURATION);

                while (cursor.moveToNext()) {
                    final int contentId = cursor.getInt(idColumn);
                    final int dateModifiedSecs = cursor.getInt(dateModifiedColumn);
                    if (newEntryChecker.where(contentId, dateModifiedSecs)) {
                        // this is fine if `contentUri` does not already contain the ID
                        final Uri itemUri = ContentUris.withAppendedId(contentUri, contentId);
                        final String path = cursor.getString(pathColumn);
                        final String mimeType = cursor.getString(mimeTypeColumn);
                        int width = cursor.getInt(widthColumn);
                        int height = cursor.getInt(heightColumn);
                        final long durationMillis = durationColumn != -1 ? cursor.getLong(durationColumn) : 0;

                        Map<String, Object> entryMap = new HashMap<String, Object>() {{
                            put("uri", itemUri.toString());
                            put("path", path);
                            put("mimeType", mimeType);
                            put("orientationDegrees", orientationColumn != -1 ? cursor.getInt(orientationColumn) : 0);
                            put("sizeBytes", cursor.getLong(sizeColumn));
                            put("title", cursor.getString(titleColumn));
                            put("dateModifiedSecs", dateModifiedSecs);
                            put("sourceDateTakenMillis", cursor.getLong(dateTakenColumn));
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
                            if (newEntryCount % 30 == 0) {
                                Thread.sleep(10);
                            }
                            newEntryCount++;
                        }
                    }
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to get entries", e);
        }
        return newEntryCount;
    }

    private boolean needSize(String mimeType) {
        return !MimeTypes.SVG.equals(mimeType);
    }

    @Override
    public ListenableFuture<Object> delete(final Activity activity, final String path, final Uri mediaUri) {
        SettableFuture<Object> future = SettableFuture.create();

        if (Env.requireAccessPermission(path)) {
            Uri sdCardTreeUri = PermissionManager.getSdCardTreeUri(activity);
            if (sdCardTreeUri == null) {
                Runnable runnable = () -> {
                    try {
                        future.set(delete(activity, path, mediaUri).get());
                    } catch (Exception e) {
                        future.setException(e);
                    }
                };
                new Handler(Looper.getMainLooper()).post(() -> PermissionManager.showSdCardAccessDialog(activity, runnable));
                return future;
            }

            // if the file is on SD card, calling the content resolver delete() removes the entry from the Media Store
            // but it doesn't delete the file, even if the app has the permission
            try {
                DocumentFileCompat df = StorageUtils.getDocumentFile(activity, path, mediaUri);
                if (df != null && df.delete()) {
                    future.set(null);
                    future.setException(new Exception("failed to delete file with df=" + df));
                }
            } catch (FileNotFoundException e) {
                future.setException(e);
            }
            return future;
        }

        try {
            if (activity.getContentResolver().delete(mediaUri, null, null) > 0) {
                future.set(null);
            } else {
                future.setException(new Exception("failed to delete row from content provider"));
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to delete entry", e);
            future.setException(e);
        }

        return future;
    }

    @Override
    public void moveMultiple(final Activity activity, Boolean copy, String destinationDir, List<ImageEntry> entries, ImageOpCallback callback) {
        String volumeName = "external";
        StorageManager sm = activity.getSystemService(StorageManager.class);
        if (sm != null) {
            StorageVolume volume = sm.getStorageVolume(new File(destinationDir));
            if (volume != null && !volume.isPrimary()) {
                String uuid = volume.getUuid();
                if (uuid != null) {
                    // the UUID returned may be uppercase
                    // but it should be lowercase to work with the MediaStore
                    volumeName = uuid.toLowerCase();
                }
            }
        }

        if (!StorageUtils.createDirectoryIfAbsent(activity, destinationDir)) {
            callback.onFailure(new Exception("failed to create directory at path=" + destinationDir));
            return;
        }

        for (ImageEntry entry : entries) {
            Uri sourceUri = entry.uri;
            String sourcePath = entry.path;
            String mimeType = entry.mimeType;

            Map<String, Object> result = new HashMap<String, Object>() {{
                put("uri", sourceUri.toString());
            }};
            try {
                Map<String, Object> newFields = moveSingle(activity, volumeName, sourcePath, sourceUri, destinationDir, mimeType, copy).get();
                result.put("success", true);
                result.put("newFields", newFields);
            } catch (ExecutionException | InterruptedException e) {
                Log.w(LOG_TAG, "failed to move to destinationDir=" + destinationDir + " entry with sourcePath=" + sourcePath, e);
                result.put("success", false);
            }
            callback.onSuccess(result);
        }
    }

    private ListenableFuture<Map<String, Object>> moveSingle(final Activity activity, final String volumeName, final String sourcePath, final Uri sourceUri, String destinationDir, String mimeType, boolean copy) {
        SettableFuture<Map<String, Object>> future = SettableFuture.create();

        try {
            // from API 29, changing MediaColumns.RELATIVE_PATH can move files on disk (same storage device)
            // from API 26, retrieve document URI from mediastore URI with `MediaStore.getDocumentUri(...)`
            // DocumentFile.getUri() is same as original uri: "content://media/external/images/media/58457"
            // DocumentFile.getParentFile() is null without picking a tree first
            // DocumentsContract.copyDocument() and moveDocument() need parent doc uri

            String destinationPath = destinationDir + File.separator + new File(sourcePath).getName();

            ContentValues contentValues = new ContentValues();
            contentValues.put(MediaStore.MediaColumns.DATA, destinationPath);
            contentValues.put(MediaStore.MediaColumns.MIME_TYPE, mimeType);
//            contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, "");
//            contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, "");
            Uri tableUrl = mimeType.startsWith(MimeTypes.VIDEO) ? MediaStore.Video.Media.getContentUri(volumeName) : MediaStore.Images.Media.getContentUri(volumeName);
            Uri destinationUri = activity.getContentResolver().insert(tableUrl, contentValues);
            if (destinationUri == null) {
                future.setException(new Exception("failed to insert row to content resolver"));
            } else {
                DocumentFileCompat source = DocumentFileCompat.fromFile(new File(sourcePath));
                DocumentFileCompat destination = DocumentFileCompat.fromSingleUri(activity, destinationUri);
                source.copyTo(destination);

                if (!copy) {
                    // delete original entry
                    try {
                        delete(activity, sourcePath, sourceUri).get();
                    } catch (ExecutionException | InterruptedException e) {
                        Log.w(LOG_TAG, "failed to delete entry with path=" + sourcePath, e);
                    }
                }

                Map<String, Object> newFields = new HashMap<>();
                newFields.put("uri", destinationUri.toString());
                newFields.put("contentId", ContentUris.parseId(destinationUri));
                newFields.put("path", destinationPath);
                future.set(newFields);
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to " + (copy ? "copy" : "move") + " entry", e);
            future.setException(e);
        }

        return future;
    }

    public interface NewEntryHandler {
        void handleEntry(Map<String, Object> entry);
    }

    public interface NewEntryChecker {
        boolean where(int contentId, int dateModifiedSecs);
    }
}