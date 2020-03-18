package deckers.thibault.aves.model.provider;

import android.app.Activity;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;

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

import deckers.thibault.aves.utils.Constants;
import deckers.thibault.aves.utils.MetadataHelper;

import static deckers.thibault.aves.utils.MetadataHelper.getOrientationDegreesForExifCode;

class UnknownContentImageProvider extends ImageProvider {
    @Override
    public void fetchSingle(final Activity activity, final Uri uri, final String mimeType, final ImageOpCallback callback) {
        int width = 0, height = 0;
        Integer orientationDegrees = null;
        Long sourceDateTakenMillis = null, durationMillis = null;
        String title = null;

        // check first metadata with MediaMetadataRetriever

        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        try {
            retriever.setDataSource(activity, uri);

            title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
            String dateString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE);
            long dateMillis = MetadataHelper.parseVideoMetadataDate(dateString);
            // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
            if (dateMillis > 0) {
                sourceDateTakenMillis = dateMillis;
            }

            String widthString = null, heightString = null, rotationString = null, durationMillisString = null;
            if (mimeType.startsWith(Constants.MIME_IMAGE)) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    widthString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH);
                    heightString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT);
                    rotationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION);
                }
            } else if (mimeType.startsWith(Constants.MIME_VIDEO)) {
                widthString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
                heightString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
                rotationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION);
                durationMillisString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            }
            if (widthString != null) {
                width = Integer.parseInt(widthString);
            }
            if (heightString != null) {
                height = Integer.parseInt(heightString);
            }
            if (rotationString != null) {
                orientationDegrees = Integer.parseInt(rotationString);
            }
            if (durationMillisString != null) {
                durationMillis = Long.parseLong(durationMillisString);
            }
        } catch (Exception e) {
            // ignore
        } finally {
            retriever.release();
        }

        // fallback to metadata-extractor for known types
        if (width <= 0 || height <= 0 || orientationDegrees == null || sourceDateTakenMillis == null) {
            if (Constants.MIME_JPEG.equals(mimeType)) {
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
            }
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
        entry.put("orientationDegrees", orientationDegrees != null ? orientationDegrees : 0);
        entry.put("sizeBytes", null);
        entry.put("title", title);
        entry.put("dateModifiedSecs", null);
        entry.put("sourceDateTakenMillis", sourceDateTakenMillis);
        entry.put("bucketDisplayName", null);
        entry.put("durationMillis", durationMillis);
        callback.onSuccess(entry);
    }
}
