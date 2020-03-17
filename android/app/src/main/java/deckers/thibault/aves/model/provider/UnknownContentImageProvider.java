package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.graphics.BitmapFactory;
import android.net.Uri;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import static deckers.thibault.aves.utils.MetadataHelper.getOrientationDegreesForExifCode;

class UnknownContentImageProvider extends ImageProvider {
    @Override
    public void fetchSingle(final Activity activity, final Uri uri, final String mimeType, final ImageOpCallback callback) {
        int width = 0, height = 0, orientationDegrees = 0;
        Long sourceDateTakenMillis = null;

        // check metadata first
        try (InputStream is = activity.getContentResolver().openInputStream(uri)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            JpegDirectory jpegDir = metadata.getFirstDirectoryOfType(JpegDirectory.class);
            if (jpegDir != null) {
                if (jpegDir.containsTag(JpegDirectory.TAG_IMAGE_WIDTH)) {
                    width = jpegDir.getInt(JpegDirectory.TAG_IMAGE_WIDTH);
                }
                if (jpegDir.containsTag(JpegDirectory.TAG_IMAGE_HEIGHT)) {
                    height = jpegDir.getInt(JpegDirectory.TAG_IMAGE_HEIGHT);
                }
            }
            ExifIFD0Directory exifDir = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
            if (exifDir != null) {
                if (exifDir.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
                    orientationDegrees = getOrientationDegreesForExifCode(exifDir.getInt(ExifIFD0Directory.TAG_ORIENTATION));
                }
                if (exifDir.containsTag(ExifIFD0Directory.TAG_DATETIME)) {
                    sourceDateTakenMillis = exifDir.getDate(ExifIFD0Directory.TAG_DATETIME, null, TimeZone.getDefault()).getTime();
                }
            }
        } catch (IOException | ImageProcessingException | MetadataException e) {
            // ignore
        }

        // fallback to decoding the image bounds
        if (width <= 0 || height <= 0) {
            try (InputStream is = activity.getContentResolver().openInputStream(uri)) {
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeStream(is, null, options);
                width = options.outWidth;
                height = options.outHeight;
            } catch (IOException e) {
                // ignore
            }
        }

        if (width <= 0 || height <= 0) {
            callback.onFailure();
            return;
        }

        Map<String, Object> entry = new HashMap<>();
        entry.put("uri", uri.toString());
        entry.put("path", null);
        entry.put("contentId", null);
        entry.put("mimeType", mimeType);
        entry.put("width", width);
        entry.put("height", height);
        entry.put("orientationDegrees", orientationDegrees);
        entry.put("sizeBytes", null);
        entry.put("title", null);
        entry.put("dateModifiedSecs", null);
        entry.put("sourceDateTakenMillis", sourceDateTakenMillis);
        entry.put("bucketDisplayName", null);
        entry.put("durationMillis", null);
        callback.onSuccess(entry);
    }
}
