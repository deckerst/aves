package deckers.thibault.aves.model.provider;

import android.annotation.SuppressLint;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

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

import deckers.thibault.aves.model.AvesImageEntry;
import deckers.thibault.aves.model.SourceImageEntry;
import deckers.thibault.aves.utils.MimeTypes;
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
                            put("sourceMimeType", mimeType);
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
                            SourceImageEntry entry = new SourceImageEntry(entryMap).fillPreCatalogMetadata(context);
                            entryMap = entry.toMap();
                        }

                        newEntryHandler.handleEntry(entryMap);
                        if (newEntryCount % 30 == 0) {
                            Thread.sleep(10);
                        }
                        newEntryCount++;
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
    public ListenableFuture<Object> delete(final Context context, final String path, final Uri mediaUri) {
        SettableFuture<Object> future = SettableFuture.create();

        if (StorageUtils.requireAccessPermission(path)) {
            // if the file is on SD card, calling the content resolver delete() removes the entry from the Media Store
            // but it doesn't delete the file, even if the app has the permission
            try {
                DocumentFileCompat df = StorageUtils.getDocumentFile(context, path, mediaUri);
                if (df != null && df.delete()) {
                    future.set(null);
                } else {
                    future.setException(new Exception("failed to delete file with df=" + df));
                }
            } catch (FileNotFoundException e) {
                future.setException(e);
            }
            return future;
        }

        try {
            if (context.getContentResolver().delete(mediaUri, null, null) > 0) {
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

    private String getVolumeNameForMediaStore(@NonNull Context context, @NonNull String anyPath) {
        String volumeName = "external";
        StorageManager sm = context.getSystemService(StorageManager.class);
        if (sm != null) {
            StorageVolume volume = sm.getStorageVolume(new File(anyPath));
            if (volume != null && !volume.isPrimary()) {
                String uuid = volume.getUuid();
                if (uuid != null) {
                    // the UUID returned may be uppercase
                    // but it should be lowercase to work with the MediaStore
                    volumeName = uuid.toLowerCase();
                }
            }
        }
        return volumeName;
    }

    @Override
    public void moveMultiple(final Context context, final Boolean copy, final String destinationDir, final List<AvesImageEntry> entries, @NonNull final ImageOpCallback callback) {
        DocumentFileCompat destinationDirDocFile = StorageUtils.createDirectoryIfAbsent(context, destinationDir);
        if (destinationDirDocFile == null) {
            callback.onFailure(new Exception("failed to create directory at path=" + destinationDir));
            return;
        }

        MediaStoreMoveDestination destination = new MediaStoreMoveDestination(context, destinationDir);
        if (destination.volumePath == null) {
            callback.onFailure(new Exception("failed to set up destination volume path for path=" + destinationDir));
            return;
        }

        for (AvesImageEntry entry : entries) {
            Uri sourceUri = entry.uri;
            String sourcePath = entry.path;
            String mimeType = entry.mimeType;

            Map<String, Object> result = new HashMap<String, Object>() {{
                put("uri", sourceUri.toString());
            }};

            // on API 30 we cannot get access granted directly to a volume root from its document tree,
            // but it is still less constraining to use tree document files than to rely on the Media Store
            try {
                ListenableFuture<Map<String, Object>> newFieldsFuture;
//                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q) {
//                    newFieldsFuture = moveSingleByMediaStoreInsert(context, sourcePath, sourceUri, destination, mimeType, copy);
//                } else {
                newFieldsFuture = moveSingleByTreeDocAndScan(context, sourcePath, sourceUri, destinationDir, destinationDirDocFile, mimeType, copy);
//                }
                Map<String, Object> newFields = newFieldsFuture.get();
                result.put("success", true);
                result.put("newFields", newFields);
            } catch (ExecutionException | InterruptedException e) {
                Log.w(LOG_TAG, "failed to move to destinationDir=" + destinationDir + " entry with sourcePath=" + sourcePath, e);
                result.put("success", false);
            }
            callback.onSuccess(result);
        }
    }

    // We can create an item via `ContentResolver.insert()` with a path, and retrieve its content URI, but:
    // - the Media Store isolates content by storage volume (e.g. `MediaStore.Images.Media.getContentUri(volumeName)`)
    // - the volume name should be lower case, not exactly as the `StorageVolume` UUID
    // - inserting on a removable volume works on API 29, but not on API 25 nor 26 (on which API/devices does it work?)
    // - there is no documentation regarding support for usage with removable storage
    // - the Media Store only allows inserting in specific primary directories ("DCIM", "Pictures") when using scoped storage
    @RequiresApi(api = Build.VERSION_CODES.Q)
    private ListenableFuture<Map<String, Object>> moveSingleByMediaStoreInsert(final Context context, final String sourcePath, final Uri sourceUri,
                                                                               final MediaStoreMoveDestination destination, final String mimeType, final boolean copy) {
        SettableFuture<Map<String, Object>> future = SettableFuture.create();

        try {
            String displayName = new File(sourcePath).getName();
            String destinationFilePath = destination.fullPath + displayName;

            ContentValues contentValues = new ContentValues();
            contentValues.put(MediaStore.MediaColumns.DATA, destinationFilePath);
            contentValues.put(MediaStore.MediaColumns.MIME_TYPE, mimeType);
            // from API 29, changing MediaColumns.RELATIVE_PATH can move files on disk (same storage device)
            contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, destination.relativePath);
            contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, displayName);
            String volumeName = destination.volumeNameForMediaStore;
            Uri tableUrl = mimeType.startsWith(MimeTypes.VIDEO) ?
                    MediaStore.Video.Media.getContentUri(volumeName) :
                    MediaStore.Images.Media.getContentUri(volumeName);
            Uri destinationUri = context.getContentResolver().insert(tableUrl, contentValues);
            if (destinationUri == null) {
                future.setException(new Exception("failed to insert row to content resolver"));
            } else {
                DocumentFileCompat sourceFile = DocumentFileCompat.fromSingleUri(context, sourceUri);
                DocumentFileCompat destinationFile = DocumentFileCompat.fromSingleUri(context, destinationUri);
                sourceFile.copyTo(destinationFile);

                boolean deletedSource = false;
                if (!copy) {
                    // delete original entry
                    try {
                        delete(context, sourcePath, sourceUri).get();
                        deletedSource = true;
                    } catch (ExecutionException | InterruptedException e) {
                        Log.w(LOG_TAG, "failed to delete entry with path=" + sourcePath, e);
                    }
                }

                Map<String, Object> newFields = new HashMap<>();
                newFields.put("uri", destinationUri.toString());
                newFields.put("contentId", ContentUris.parseId(destinationUri));
                newFields.put("path", destinationFilePath);
                newFields.put("deletedSource", deletedSource);
                future.set(newFields);
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "failed to " + (copy ? "copy" : "move") + " entry", e);
            future.setException(e);
        }

        return future;
    }

    // We can create an item via `DocumentFile.createFile()`, but:
    // - we need to scan the file to get the Media Store content URI
    // - the underlying document provider controls the new file name
    private ListenableFuture<Map<String, Object>> moveSingleByTreeDocAndScan(final Context context, final String sourcePath, final Uri sourceUri, final String destinationDir, final DocumentFileCompat destinationDirDocFile, final String mimeType, boolean copy) {
        SettableFuture<Map<String, Object>> future = SettableFuture.create();

        try {
            String sourceFileName = new File(sourcePath).getName();
            String desiredNameWithoutExtension = sourceFileName.replaceFirst("[.][^.]+$", "");

            // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
            // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
            // through a document URI, not a tree URI
            // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
            DocumentFileCompat destinationTreeFile = destinationDirDocFile.createFile(mimeType, desiredNameWithoutExtension);
            DocumentFileCompat destinationDocFile = DocumentFileCompat.fromSingleUri(context, destinationTreeFile.getUri());

            // `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
            // `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
            // when used with entry URI as `sourceDocumentUri`, and destinationDirDocFile URI as `targetParentDocumentUri`
            DocumentFileCompat source = DocumentFileCompat.fromSingleUri(context, sourceUri);
            source.copyTo(destinationDocFile);

            // the source file name and the created document file name can be different when:
            // - a file with the same name already exists, so the name gets a suffix like ` (1)`
            // - the original extension does not match the extension appended used by the underlying provider
            String fileName = destinationDocFile.getName();
            String destinationFullPath = destinationDir + fileName;

            boolean deletedSource = false;
            if (!copy) {
                // delete original entry
                try {
                    delete(context, sourcePath, sourceUri).get();
                    deletedSource = true;
                } catch (ExecutionException | InterruptedException e) {
                    Log.w(LOG_TAG, "failed to delete entry with path=" + sourcePath, e);
                }
            }

            boolean finalDeletedSource = deletedSource;
            scanNewPath(context, destinationFullPath, mimeType, new ImageProvider.ImageOpCallback() {
                @Override
                public void onSuccess(Map<String, Object> newFields) {
                    newFields.put("deletedSource", finalDeletedSource);
                    future.set(newFields);
                }

                @Override
                public void onFailure(Throwable throwable) {
                    future.setException(throwable);
                }
            });
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

    class MediaStoreMoveDestination {
        final String volumeNameForMediaStore;
        final String volumePath;
        final String relativePath;
        final String fullPath;

        MediaStoreMoveDestination(@NonNull Context context, @NonNull String destinationDir) {
            fullPath = destinationDir;
            volumeNameForMediaStore = getVolumeNameForMediaStore(context, destinationDir);
            volumePath = StorageUtils.getVolumePath(context, destinationDir).orElse(null);
            relativePath = volumePath != null ? destinationDir.replaceFirst(volumePath, "") : null;
        }
    }
}