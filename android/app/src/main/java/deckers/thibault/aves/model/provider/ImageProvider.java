package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;
import java.io.FileDescriptor;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import deckers.thibault.aves.utils.Constants;
import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.MetadataHelper;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.StorageUtils;
import deckers.thibault.aves.utils.Utils;

public abstract class ImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(ImageProvider.class);

    public void delete(final Activity activity, final String path, final Uri uri, final ImageOpCallback callback) {
        callback.onFailure();
    }

    public void rename(final Activity activity, final String oldPath, final Uri oldUri, final String mimeType, final String newFilename, final ImageOpCallback callback) {
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
        if (Env.isOnSdCard(activity, oldPath)) {
            // rename with DocumentFile
            Uri sdCardTreeUri = PermissionManager.getSdCardTreeUri(activity);
            if (sdCardTreeUri == null) {
                Runnable runnable = () -> rename(activity, oldPath, oldUri, mimeType, newFilename, callback);
                PermissionManager.showSdCardAccessDialog(activity, runnable);
                return;
            }
            renamed = StorageUtils.renameOnSdCard(activity, sdCardTreeUri, Env.getStorageVolumes(activity), oldPath, newFilename);
        } else {
            // rename with File
            renamed = oldFile.renameTo(newFile);
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

    public void rotate(final Activity activity, final String path, final Uri uri, final String mimeType, final boolean clockwise, final ImageOpCallback callback) {
        switch (mimeType) {
            case Constants.MIME_JPEG:
                rotateJpeg(activity, path, uri, mimeType, clockwise, callback);
                break;
            case Constants.MIME_PNG:
                rotatePng(activity, path, uri, mimeType, clockwise, callback);
                break;
            default:
                callback.onFailure();
        }
    }

    private void rotateJpeg(final Activity activity, final String path, final Uri uri, final String mimeType, boolean clockwise, final ImageOpCallback callback) {
        String editablePath = path;
        boolean onSdCard = Env.isOnSdCard(activity, path);
        if (onSdCard) {
            if (PermissionManager.getSdCardTreeUri(activity) == null) {
                Runnable runnable = () -> rotate(activity, path, uri, mimeType, clockwise, callback);
                PermissionManager.showSdCardAccessDialog(activity, runnable);
                return;
            }
            // copy original file to a temporary file for editing
            editablePath = StorageUtils.copyFileToTemp(path);
        }

        if (editablePath == null) {
            callback.onFailure();
            return;
        }

        boolean rotated = false;
        int newOrientationCode = 0;
        try {
            ExifInterface exif = new ExifInterface(editablePath);
            switch (exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    newOrientationCode = clockwise ? ExifInterface.ORIENTATION_ROTATE_180 : ExifInterface.ORIENTATION_NORMAL;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    newOrientationCode = clockwise ? ExifInterface.ORIENTATION_ROTATE_270 : ExifInterface.ORIENTATION_ROTATE_90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    newOrientationCode = clockwise ? ExifInterface.ORIENTATION_NORMAL : ExifInterface.ORIENTATION_ROTATE_180;
                    break;
                default:
                    newOrientationCode = clockwise ? ExifInterface.ORIENTATION_ROTATE_90 : ExifInterface.ORIENTATION_ROTATE_270;
                    break;
            }
            exif.setAttribute(ExifInterface.TAG_ORIENTATION, Integer.toString(newOrientationCode));
            exif.saveAttributes();

            // if the image is on the SD card, copy the edited temporary file to the original DocumentFile
            rotated = !onSdCard || StorageUtils.writeToDocumentFile(activity, editablePath, uri);
        } catch (IOException e) {
            Log.w(LOG_TAG, "failed to edit EXIF to rotate image at path=" + path, e);
        }
        if (!rotated) {
            callback.onFailure();
            return;
        }

        // update fields in media store
        ContentValues values = new ContentValues();
        int orientationDegrees = MetadataHelper.getOrientationDegreesForExifCode(newOrientationCode);
        values.put(MediaStore.Images.Media.ORIENTATION, orientationDegrees);
        if (activity.getContentResolver().update(uri, values, null, null) > 0) {
            MediaScannerConnection.scanFile(activity, new String[]{path}, new String[]{mimeType}, (p, u) -> {
                Map<String, Object> newFields = new HashMap<>();
                newFields.put("orientationDegrees", orientationDegrees);
                callback.onSuccess(newFields);
            });
        }
    }

    private void rotatePng(final Activity activity, final String path, final Uri uri, final String mimeType, boolean clockwise, final ImageOpCallback callback) {
        if (path == null) {
            callback.onFailure();
            return;
        }

        boolean onSdCard = Env.isOnSdCard(activity, path);
        if (onSdCard && PermissionManager.getSdCardTreeUri(activity) == null) {
            Runnable runnable = () -> rotate(activity, path, uri, mimeType, clockwise, callback);
            PermissionManager.showSdCardAccessDialog(activity, runnable);
            return;
        }

        Bitmap originalImage = BitmapFactory.decodeFile(path);
        Matrix matrix = new Matrix();
        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();
        matrix.setRotate(clockwise ? 90 : -90, originalWidth >> 1, originalHeight >> 1);
        Bitmap rotatedImage = Bitmap.createBitmap(originalImage, 0, 0, originalWidth, originalHeight, matrix, true);

        boolean rotated = false;
        if (onSdCard) {
            FileDescriptor fd = null;
            try {
                ParcelFileDescriptor pfd = activity.getContentResolver().openFileDescriptor(uri, "rw");
                if (pfd != null) fd = pfd.getFileDescriptor();
            } catch (FileNotFoundException e) {
                Log.w(LOG_TAG, "failed to get file descriptor for document at uri=" + path, e);
            }
            if (fd != null) {
                try (FileOutputStream fos = new FileOutputStream(fd)) {
                    rotatedImage.compress(Bitmap.CompressFormat.PNG, 100, fos);
                    rotated = true;
                } catch (IOException e) {
                    Log.w(LOG_TAG, "failed to save rotated image to document at uri=" + path, e);
                }
            }
        } else {
            try (FileOutputStream fos = new FileOutputStream(path)) {
                rotatedImage.compress(Bitmap.CompressFormat.PNG, 100, fos);
                rotated = true;
            } catch (IOException e) {
                Log.w(LOG_TAG, "failed to save rotated image to path=" + path, e);
            }
        }
        if (!rotated) {
            callback.onFailure();
            return;
        }

        // update fields in media store
        @SuppressWarnings("SuspiciousNameCombination") int rotatedWidth = originalHeight;
        @SuppressWarnings("SuspiciousNameCombination") int rotatedHeight = originalWidth;
        ContentValues values = new ContentValues();
        values.put(MediaStore.MediaColumns.WIDTH, rotatedWidth);
        values.put(MediaStore.MediaColumns.HEIGHT, rotatedHeight);
        if (activity.getContentResolver().update(uri, values, null, null) > 0) {
            MediaScannerConnection.scanFile(activity, new String[]{path}, new String[]{mimeType}, (p, u) -> {
                Map<String, Object> newFields = new HashMap<>();
                newFields.put("width", rotatedWidth);
                newFields.put("height", rotatedHeight);
                callback.onSuccess(newFields);
            });
        }
    }

    public interface ImageOpCallback {
        void onSuccess(Map<String, Object> newFields);

        void onFailure();
    }
}
