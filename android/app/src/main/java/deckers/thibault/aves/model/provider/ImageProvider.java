package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.content.ContentUris;
import android.database.Cursor;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.StorageUtils;
import deckers.thibault.aves.utils.Utils;

public abstract class ImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(ImageProvider.class);

    public void rename(final Activity activity, final String oldPath, final Uri oldUri, final String mimeType, final String newFilename, final RenameCallback callback) {
        if (oldPath == null) {
            Log.w(LOG_TAG, "entry does not have a path, uri=" + oldUri);
            callback.onFailure();
            return;
        }

        Map<String, Object> newFields = new HashMap<>();
        File oldFile = new File(oldPath);
        File newFile = new File(oldFile.getParent(), newFilename);
        if (oldFile.equals(newFile)) {
            Log.w(LOG_TAG, "new name and old name are the same, path=" + oldPath);
            callback.onSuccess(newFields);
            return;
        }

        // Before KitKat, we do whatever we want on the SD card.
        // From KitKat, we need access permission from the Document Provider, at the file level.
        // From Lollipop, we can request the permission at the SD card root level.
        boolean renamed;
        if (!Env.isOnSdCard(activity, oldPath)) {
            // rename with File
            renamed = oldFile.renameTo(newFile);
        } else {
            // rename with DocumentFile
            Uri sdCardTreeUri = PermissionManager.getSdCardTreeUri(activity);
            if (sdCardTreeUri == null) {
                Runnable runnable = () -> rename(activity, oldPath, oldUri, mimeType, newFilename, callback);
                PermissionManager.showSdCardAccessDialog(activity, runnable);
                return;
            }
            renamed = StorageUtils.renameOnSdCard(activity, sdCardTreeUri, Env.getStorageVolumes(activity), oldPath, newFilename);
        }

        if (!renamed) {
            Log.w(LOG_TAG, "failed to rename entry at path=" + oldPath);
            callback.onFailure();
            return;
        }

        MediaScannerConnection.scanFile(activity, new String[]{oldPath}, new String[]{mimeType}, null);
        MediaScannerConnection.scanFile(activity, new String[]{newFile.getPath()}, new String[]{mimeType}, (newPath, uri) -> {
            Log.d(LOG_TAG, "onScanCompleted with newPath=" + newPath + ", uri=" + uri);
            if (uri != null) {
                // we retrieve updated fields as the renamed file became a new entry in the Media Store
                String[] projection = {MediaStore.MediaColumns._ID, MediaStore.MediaColumns.DATA, MediaStore.MediaColumns.TITLE};
                try {
                    Cursor cursor = activity.getContentResolver().query(uri, projection, null, null, null);
                    if (cursor != null) {
                        if (cursor.moveToNext()) {
                            long contentId = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID));
                            Uri itemUri = ContentUris.withAppendedId(MediaStoreImageProvider.FILES_URI, contentId);
                            newFields.put("uri", itemUri.toString());
                            newFields.put("contentId", contentId);
                            newFields.put("path", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)));
                            newFields.put("title", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE)));
                        }
                        cursor.close();
                    }
                } catch (Exception e) {
                    Log.w(LOG_TAG, "failed to update MediaStore after renaming entry at path=" + oldPath, e);
                    callback.onFailure();
                    return;
                }
            }
            callback.onSuccess(newFields);
        });
    }

    public interface RenameCallback {
        void onSuccess(Map<String, Object> newFields);

        void onFailure();
    }
}
