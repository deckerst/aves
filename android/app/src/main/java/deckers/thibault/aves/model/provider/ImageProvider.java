package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.exifinterface.media.ExifInterface;

import com.commonsware.cwac.document.DocumentFileCompat;
import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Metadata;
import com.drew.metadata.file.FileTypeDirectory;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.MetadataHelper;
import deckers.thibault.aves.utils.MimeTypes;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.StorageUtils;
import deckers.thibault.aves.utils.Utils;

// *** about file access to write/rename/delete
// * primary volume
// until 28/Pie, use `File`
// on 29/Q, use `File` after setting `requestLegacyExternalStorage` flag in the manifest
// from 30/R, use `DocumentFile` (not `File`) after requesting permission to the volume root???
// * non primary volumes
// on 19/KitKat, use `DocumentFile` (not `File`) after getting permission for each file
// from 21/Lollipop, use `DocumentFile` (not `File`) after getting permission to the volume root

public abstract class ImageProvider {
    private static final String LOG_TAG = Utils.createLogTag(ImageProvider.class);

    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @NonNull final String mimeType, @NonNull final ImageOpCallback callback) {
        callback.onFailure(new UnsupportedOperationException());
    }

    public ListenableFuture<Object> delete(final Activity activity, final String path, final Uri uri) {
        return Futures.immediateFailedFuture(new UnsupportedOperationException());
    }

    public void moveMultiple(final Activity activity, Boolean copy, String destinationDir, List<ImageEntry> entries, @NonNull ImageOpCallback callback) {
        callback.onFailure(new UnsupportedOperationException());
    }

    public void rename(final Activity activity, final String oldPath, final Uri oldMediaUri, final String mimeType, final String newFilename, final ImageOpCallback callback) {
        if (oldPath == null) {
            callback.onFailure(new IllegalArgumentException("entry does not have a path, uri=" + oldMediaUri));
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

        if (Env.requireAccessPermission(oldPath)) {
            Uri sdCardTreeUri = PermissionManager.getSdCardTreeUri(activity);
            if (sdCardTreeUri == null) {
                Runnable runnable = () -> rename(activity, oldPath, oldMediaUri, mimeType, newFilename, callback);
                new Handler(Looper.getMainLooper()).post(() -> PermissionManager.showSdCardAccessDialog(activity, runnable));
                return;
            }
        }

        DocumentFileCompat df = StorageUtils.getDocumentFile(activity, oldPath, oldMediaUri);
        try {
            boolean renamed = df != null && df.renameTo(newFilename);
            if (!renamed) {
                callback.onFailure(new Exception("failed to rename entry at path=" + oldPath));
                return;
            }
        } catch (FileNotFoundException e) {
            callback.onFailure(e);
            return;
        }

        MediaScannerConnection.scanFile(activity, new String[]{oldPath}, new String[]{mimeType}, null);
        MediaScannerConnection.scanFile(activity, new String[]{newFile.getPath()}, new String[]{mimeType}, (newPath, newUri) -> {
            Log.d(LOG_TAG, "onScanCompleted with newPath=" + newPath + ", newUri=" + newUri);
            if (newUri != null) {
                // we retrieve updated fields as the renamed file became a new entry in the Media Store
                String[] projection = {MediaStore.MediaColumns._ID, MediaStore.MediaColumns.DATA, MediaStore.MediaColumns.TITLE};
                try {
                    Cursor cursor = activity.getContentResolver().query(newUri, projection, null, null, null);
                    if (cursor != null) {
                        if (cursor.moveToNext()) {
                            long contentId = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID));
                            newFields.put("uri", newUri.toString());
                            newFields.put("contentId", contentId);
                            newFields.put("path", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)));
                            newFields.put("title", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE)));
                        }
                        cursor.close();
                    }
                } catch (Exception e) {
                    callback.onFailure(e);
                    return;
                }
            }
            callback.onSuccess(newFields);
        });
    }

    // file extension is unreliable
    // `context.getContentResolver().getType()` sometimes return incorrect value
    // `MediaMetadataRetriever.setDataSource()` sometimes fail with `status = 0x80000000`
    // so we check with `metadata-extractor`
    @Nullable
    private String getMimeType(@NonNull final Context context, @NonNull final Uri uri) {
        try (InputStream is = context.getContentResolver().openInputStream(uri)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            FileTypeDirectory fileTypeDir = metadata.getFirstDirectoryOfType(FileTypeDirectory.class);
            if (fileTypeDir != null) {
                if (fileTypeDir.containsTag(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)) {
                    return fileTypeDir.getString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE);
                }
            }
        } catch (IOException | ImageProcessingException e) {
            Log.w(LOG_TAG, "failed to get mime type from metadata for uri=" + uri, e);
        }
        return null;
    }

    public void rotate(final Activity activity, final String path, final Uri uri, final String mimeType, final boolean clockwise, final ImageOpCallback callback) {
        // the reported `mimeType` (e.g. from Media Store) is sometimes incorrect
        // so we retrieve it again from the file metadata
        String actualMimeType = getMimeType(activity, uri);
        if (actualMimeType == null) {
            actualMimeType = mimeType;
        }
        switch (actualMimeType) {
            case MimeTypes.JPEG:
                rotateJpeg(activity, path, uri, clockwise, callback);
                break;
            case MimeTypes.PNG:
                rotatePng(activity, path, uri, clockwise, callback);
                break;
            default:
                callback.onFailure(new UnsupportedOperationException("unsupported mimeType=" + actualMimeType));
        }
    }

    private void rotateJpeg(final Activity activity, final String path, final Uri uri, boolean clockwise, final ImageOpCallback callback) {
        final String mimeType = MimeTypes.JPEG;
        // copy original file to a temporary file for editing
        final String editablePath = StorageUtils.copyFileToTemp(path);
        if (Env.requireAccessPermission(path)) {
            if (PermissionManager.getSdCardTreeUri(activity) == null) {
                Runnable runnable = () -> rotate(activity, path, uri, mimeType, clockwise, callback);
                new Handler(Looper.getMainLooper()).post(() -> PermissionManager.showSdCardAccessDialog(activity, runnable));
                return;
            }
        }

        int newOrientationCode;
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

            // copy the edited temporary file to the original DocumentFile
            DocumentFileCompat.fromFile(new File(editablePath)).copyTo(DocumentFileCompat.fromSingleUri(activity, uri));
        } catch (IOException e) {
            callback.onFailure(e);
            return;
        }

        // update fields in media store
        int orientationDegrees = MetadataHelper.getOrientationDegreesForExifCode(newOrientationCode);
        Map<String, Object> newFields = new HashMap<>();
        newFields.put("orientationDegrees", orientationDegrees);

        ContentResolver contentResolver = activity.getContentResolver();
        ContentValues values = new ContentValues();
        // from Android Q, media store update needs to be flagged IS_PENDING first
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.put(MediaStore.MediaColumns.IS_PENDING, 1);
            contentResolver.update(uri, values, null, null);
            values.clear();
            values.put(MediaStore.MediaColumns.IS_PENDING, 0);
        }
        // uses MediaStore.Images.Media instead of MediaStore.MediaColumns for APIs < Q
        values.put(MediaStore.Images.Media.ORIENTATION, orientationDegrees);
        int updatedRowCount = contentResolver.update(uri, values, null, null);
        if (updatedRowCount > 0) {
            MediaScannerConnection.scanFile(activity, new String[]{path}, new String[]{mimeType}, (p, u) -> callback.onSuccess(newFields));
        } else {
            Log.w(LOG_TAG, "failed to update fields in Media Store for uri=" + uri);
            callback.onSuccess(newFields);
        }
    }

    private void rotatePng(final Activity activity, final String path, final Uri uri, boolean clockwise, final ImageOpCallback callback) {
        final String mimeType = MimeTypes.PNG;
        // copy original file to a temporary file for editing
        final String editablePath = StorageUtils.copyFileToTemp(path);
        if (Env.requireAccessPermission(path)) {
            if (PermissionManager.getSdCardTreeUri(activity) == null) {
                Runnable runnable = () -> rotate(activity, path, uri, mimeType, clockwise, callback);
                new Handler(Looper.getMainLooper()).post(() -> PermissionManager.showSdCardAccessDialog(activity, runnable));
                return;
            }
        }

        Bitmap originalImage = BitmapFactory.decodeFile(path);
        if (originalImage == null) {
            callback.onFailure(new Exception("failed to decode image at path=" + path));
            return;
        }
        Matrix matrix = new Matrix();
        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();
        matrix.setRotate(clockwise ? 90 : -90, originalWidth >> 1, originalHeight >> 1);
        Bitmap rotatedImage = Bitmap.createBitmap(originalImage, 0, 0, originalWidth, originalHeight, matrix, true);

        try (FileOutputStream fos = new FileOutputStream(editablePath)) {
            rotatedImage.compress(Bitmap.CompressFormat.PNG, 100, fos);

            // copy the edited temporary file to the original DocumentFile
            DocumentFileCompat.fromFile(new File(editablePath)).copyTo(DocumentFileCompat.fromSingleUri(activity, uri));
        } catch (IOException e) {
            callback.onFailure(e);
            return;
        }

        // update fields in media store
        @SuppressWarnings("SuspiciousNameCombination") int rotatedWidth = originalHeight;
        @SuppressWarnings("SuspiciousNameCombination") int rotatedHeight = originalWidth;
        Map<String, Object> newFields = new HashMap<>();
        newFields.put("width", rotatedWidth);
        newFields.put("height", rotatedHeight);

        ContentResolver contentResolver = activity.getContentResolver();
        ContentValues values = new ContentValues();
        // from Android Q, media store update needs to be flagged IS_PENDING first
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.put(MediaStore.MediaColumns.IS_PENDING, 1);
            contentResolver.update(uri, values, null, null);
            values.clear();
            values.put(MediaStore.MediaColumns.IS_PENDING, 0);
        }
        values.put(MediaStore.MediaColumns.WIDTH, rotatedWidth);
        values.put(MediaStore.MediaColumns.HEIGHT, rotatedHeight);
        int updatedRowCount = contentResolver.update(uri, values, null, null);
        if (updatedRowCount > 0) {
            MediaScannerConnection.scanFile(activity, new String[]{path}, new String[]{mimeType}, (p, u) -> callback.onSuccess(newFields));
        } else {
            Log.w(LOG_TAG, "failed to update fields in Media Store for uri=" + uri);
            callback.onSuccess(newFields);
        }
    }

    public interface ImageOpCallback {
        void onSuccess(Map<String, Object> fields);

        void onFailure(Throwable throwable);
    }
}
