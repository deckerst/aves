package deckers.thibault.aves.model.provider;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.exifinterface.media.ExifInterface;

import com.commonsware.cwac.document.DocumentFileCompat;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import deckers.thibault.aves.model.AvesImageEntry;
import deckers.thibault.aves.model.ExifOrientationOp;
import deckers.thibault.aves.utils.LogUtils;
import deckers.thibault.aves.utils.MimeTypes;
import deckers.thibault.aves.utils.StorageUtils;

// *** about file access to write/rename/delete
// * primary volume
// until 28/Pie, use `File`
// on 29/Q, use `File` after setting `requestLegacyExternalStorage` flag in the manifest
// from 30/R, use `DocumentFile` (not `File`) after requesting permission to the volume root???
// * non primary volumes
// on 19/KitKat, use `DocumentFile` (not `File`) after getting permission for each file
// from 21/Lollipop, use `DocumentFile` (not `File`) after getting permission to the volume root

public abstract class ImageProvider {
    private static final String LOG_TAG = LogUtils.createTag(ImageProvider.class);

    public void fetchSingle(@NonNull final Context context, @NonNull final Uri uri, @Nullable final String mimeType, @NonNull final ImageOpCallback callback) {
        callback.onFailure(new UnsupportedOperationException());
    }

    public ListenableFuture<Object> delete(final Context context, final String path, final Uri uri) {
        return Futures.immediateFailedFuture(new UnsupportedOperationException());
    }

    public void moveMultiple(final Context context, final Boolean copy, final String destinationDir, final List<AvesImageEntry> entries, @NonNull final ImageOpCallback callback) {
        callback.onFailure(new UnsupportedOperationException());
    }

    public void rename(final Context context, final String oldPath, final Uri oldMediaUri, final String mimeType, final String newFilename, final ImageOpCallback callback) {
        if (oldPath == null) {
            callback.onFailure(new IllegalArgumentException("entry does not have a path, uri=" + oldMediaUri));
            return;
        }

        File oldFile = new File(oldPath);
        File newFile = new File(oldFile.getParent(), newFilename);
        if (oldFile.equals(newFile)) {
            Log.w(LOG_TAG, "new name and old name are the same, path=" + oldPath);
            callback.onSuccess(new HashMap<>());
            return;
        }

        DocumentFileCompat df = StorageUtils.getDocumentFile(context, oldPath, oldMediaUri);
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

        MediaScannerConnection.scanFile(context, new String[]{oldPath}, new String[]{mimeType}, null);
        scanNewPath(context, newFile.getPath(), mimeType, callback);
    }

    // support for writing EXIF
    // as of androidx.exifinterface:exifinterface:1.3.0
    private boolean canEditExif(@NonNull String mimeType) {
        switch (mimeType) {
            case "image/jpeg":
            case "image/png":
            case "image/webp":
                return true;
            default:
                return false;
        }
    }

    public void changeOrientation(final Context context, final String path, final Uri uri, final String mimeType, final ExifOrientationOp op, final ImageOpCallback callback) {
        if (!canEditExif(mimeType)) {
            callback.onFailure(new UnsupportedOperationException("unsupported mimeType=" + mimeType));
            return;
        }

        final DocumentFileCompat originalDocumentFile = StorageUtils.getDocumentFile(context, path, uri);
        if (originalDocumentFile == null) {
            callback.onFailure(new Exception("failed to get document file for path=" + path + ", uri=" + uri));
            return;
        }

        // copy original file to a temporary file for editing
        final String editablePath = StorageUtils.copyFileToTemp(originalDocumentFile, path);
        if (editablePath == null) {
            callback.onFailure(new Exception("failed to create a temporary file for path=" + path));
            return;
        }

        Map<String, Object> newFields = new HashMap<>();
        try {
            ExifInterface exif = new ExifInterface(editablePath);
            // when the orientation is not defined, it returns `undefined (0)` instead of the orientation default value `normal (1)`
            // in that case we explicitely set it to `normal` first
            // because ExifInterface fails to rotate an image with undefined orientation
            // as of androidx.exifinterface:exifinterface:1.3.0
            int currentOrientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
            if (currentOrientation == ExifInterface.ORIENTATION_UNDEFINED) {
                exif.setAttribute(ExifInterface.TAG_ORIENTATION, Integer.toString(ExifInterface.ORIENTATION_NORMAL));
            }
            switch (op) {
                case ROTATE_CW:
                    exif.rotate(90);
                    break;
                case ROTATE_CCW:
                    exif.rotate(-90);
                    break;
                case FLIP:
                    exif.flipHorizontally();
                    break;
            }
            exif.saveAttributes();

            // copy the edited temporary file back to the original
            DocumentFileCompat.fromFile(new File(editablePath)).copyTo(originalDocumentFile);

            newFields.put("rotationDegrees", exif.getRotationDegrees());
            newFields.put("isFlipped", exif.isFlipped());
        } catch (IOException e) {
            callback.onFailure(e);
            return;
        }

        MediaScannerConnection.scanFile(context, new String[]{path}, new String[]{mimeType}, (p, u) -> {
            String[] projection = {MediaStore.MediaColumns.DATE_MODIFIED};
            try {
                Cursor cursor = context.getContentResolver().query(uri, projection, null, null, null);
                if (cursor != null) {
                    if (cursor.moveToNext()) {
                        newFields.put("dateModifiedSecs", cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)));
                    }
                    cursor.close();
                }
            } catch (Exception e) {
                callback.onFailure(e);
                return;
            }
            callback.onSuccess(newFields);
        });
    }

    protected void scanNewPath(final Context context, final String path, final String mimeType, final ImageOpCallback callback) {
        MediaScannerConnection.scanFile(context, new String[]{path}, new String[]{mimeType}, (newPath, newUri) -> {
            long contentId = 0;
            Uri contentUri = null;
            if (newUri != null) {
                // newURI is possibly a file media URI (e.g. "content://media/12a9-8b42/file/62872")
                // but we need an image/video media URI (e.g. "content://media/external/images/media/62872")
                contentId = ContentUris.parseId(newUri);
                if (MimeTypes.isImage(mimeType)) {
                    contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentId);
                } else if (MimeTypes.isVideo(mimeType)) {
                    contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentId);
                }
            }
            if (contentUri == null) {
                callback.onFailure(new Exception("failed to get content URI of item at path=" + path));
                return;
            }

            Map<String, Object> newFields = new HashMap<>();
            // we retrieve updated fields as the renamed/moved file became a new entry in the Media Store
            String[] projection = {
                    MediaStore.MediaColumns.DISPLAY_NAME,
                    MediaStore.MediaColumns.TITLE,
                    MediaStore.MediaColumns.DATE_MODIFIED,
            };
            try {
                Cursor cursor = context.getContentResolver().query(contentUri, projection, null, null, null);
                if (cursor != null) {
                    if (cursor.moveToNext()) {
                        newFields.put("uri", contentUri.toString());
                        newFields.put("contentId", contentId);
                        newFields.put("path", path);
                        newFields.put("displayName", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)));
                        newFields.put("title", cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE)));
                        newFields.put("dateModifiedSecs", cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)));
                    }
                    cursor.close();
                }
            } catch (Exception e) {
                callback.onFailure(e);
                return;
            }

            if (newFields.isEmpty()) {
                callback.onFailure(new Exception("failed to get item details from provider at contentUri=" + contentUri));
            } else {
                callback.onSuccess(newFields);
            }
        });
    }

    public interface ImageOpCallback {
        void onSuccess(Map<String, Object> fields);

        void onFailure(Throwable throwable);
    }
}
