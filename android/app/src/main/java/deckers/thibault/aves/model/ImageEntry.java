package deckers.thibault.aves.model;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.Nullable;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.avi.AviDirectory;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;
import com.drew.metadata.mp4.Mp4Directory;
import com.drew.metadata.mp4.media.Mp4VideoDirectory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import deckers.thibault.aves.utils.MetadataHelper;
import deckers.thibault.aves.utils.MimeTypes;
import deckers.thibault.aves.utils.StorageUtils;

import static deckers.thibault.aves.utils.MetadataHelper.getOrientationDegreesForExifCode;

public class ImageEntry {
    public Uri uri; // content or file URI
    public String path; // best effort to get local path

    public String mimeType;
    @Nullable
    public String title;
    @Nullable
    private String bucketDisplayName;
    @Nullable
    public Integer width, height, orientationDegrees;
    @Nullable
    public Long sizeBytes;
    @Nullable
    public Long dateModifiedSecs;
    @Nullable
    private Long sourceDateTakenMillis;
    @Nullable
    private Long durationMillis;

    public ImageEntry() {
    }

    public ImageEntry(Map map) {
        this.uri = Uri.parse((String) map.get("uri"));
        this.path = (String) map.get("path");
        this.mimeType = (String) map.get("mimeType");
        this.width = (int) map.get("width");
        this.height = (int) map.get("height");
        this.orientationDegrees = (int) map.get("orientationDegrees");
        this.sizeBytes = toLong(map.get("sizeBytes"));
        this.title = (String) map.get("title");
        this.dateModifiedSecs = toLong(map.get("dateModifiedSecs"));
        this.sourceDateTakenMillis = toLong(map.get("sourceDateTakenMillis"));
        this.bucketDisplayName = (String) map.get("bucketDisplayName");
        this.durationMillis = toLong(map.get("durationMillis"));
    }

    public Map<String, Object> toMap() {
        return new HashMap<String, Object>() {{
            put("uri", uri.toString());
            put("path", path);
            put("mimeType", mimeType);
            put("width", width);
            put("height", height);
            put("orientationDegrees", orientationDegrees != null ? orientationDegrees : 0);
            put("sizeBytes", sizeBytes);
            put("title", title);
            put("dateModifiedSecs", dateModifiedSecs);
            put("sourceDateTakenMillis", sourceDateTakenMillis);
            put("bucketDisplayName", bucketDisplayName);
            put("durationMillis", durationMillis);
            // only for map export
            put("contentId", getContentId());
        }};
    }

    private Long getContentId() {
        if (uri != null && ContentResolver.SCHEME_CONTENT.equals(uri.getScheme())) {
            try {
                return ContentUris.parseId(uri);
            } catch (NumberFormatException | UnsupportedOperationException e) {
                // ignore when the ID is not a number
                // e.g. content://com.sec.android.app.myfiles.FileProvider/device_storage/20200109_162621.jpg
            }
        }
        return null;
    }

    public boolean hasSize() {
        return width != null && width > 0 && height != null && height > 0;
    }

    private boolean hasDuration() {
        return durationMillis != null && durationMillis > 0;
    }

    private boolean isImage() {
        return mimeType.startsWith(MimeTypes.IMAGE);
    }

    public boolean isSvg() {
        return mimeType.equals(MimeTypes.SVG);
    }

    public boolean isVideo() {
        return mimeType.startsWith(MimeTypes.VIDEO);
    }

    // metadata retrieval

    // expects entry with: uri/path, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    public ImageEntry fillPreCatalogMetadata(Context context) {
        fillByMediaMetadataRetriever(context);
        if (hasSize() && (!isVideo() || hasDuration())) return this;
        fillByMetadataExtractor(context);
        if (hasSize()) return this;
        fillByBitmapDecode(context);
        return this;
    }

    // expects entry with: uri/path, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    private void fillByMediaMetadataRetriever(Context context) {
        try (MediaMetadataRetriever retriever = StorageUtils.openMetadataRetriever(context, uri, path)) {
            String width = null, height = null, rotation = null, durationMillis = null;
            if (isImage()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH);
                    height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT);
                    rotation = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION);
                }
            } else if (isVideo()) {
                width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
                height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
                rotation = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION);
                durationMillis = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            }
            if (width != null) {
                this.width = Integer.parseInt(width);
            }
            if (height != null) {
                this.height = Integer.parseInt(height);
            }
            if (rotation != null) {
                this.orientationDegrees = Integer.parseInt(rotation);
            }
            if (durationMillis != null) {
                this.durationMillis = Long.parseLong(durationMillis);
            }

            String dateString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE);
            long dateMillis = MetadataHelper.parseVideoMetadataDate(dateString);
            // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
            if (dateMillis > 0) {
                this.sourceDateTakenMillis = dateMillis;
            }

            String title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
            if (title != null) {
                this.title = title;
            }
        } catch (Exception e) {
            // ignore
        }
    }

    // expects entry with: uri/path, mimeType
    // finds: width, height, orientation, date
    private void fillByMetadataExtractor(Context context) {
        if (MimeTypes.SVG.equals(mimeType)) return;

        try (InputStream is = StorageUtils.openInputStream(context, uri, path)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);

            if (MimeTypes.JPEG.equals(mimeType)) {
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
            } else if (MimeTypes.MP4.equals(mimeType)) {
                Mp4VideoDirectory mp4VideoDir = metadata.getFirstDirectoryOfType(Mp4VideoDirectory.class);
                if (mp4VideoDir != null) {
                    if (mp4VideoDir.containsTag(Mp4VideoDirectory.TAG_WIDTH)) {
                        width = mp4VideoDir.getInt(Mp4VideoDirectory.TAG_WIDTH);
                    }
                    if (mp4VideoDir.containsTag(Mp4VideoDirectory.TAG_HEIGHT)) {
                        height = mp4VideoDir.getInt(Mp4VideoDirectory.TAG_HEIGHT);
                    }
                }
                Mp4Directory mp4Dir = metadata.getFirstDirectoryOfType(Mp4Directory.class);
                if (mp4Dir != null) {
                    if (mp4Dir.containsTag(Mp4Directory.TAG_DURATION)) {
                        durationMillis = mp4Dir.getLong(Mp4Directory.TAG_DURATION);
                    }
                }
            } else if (MimeTypes.AVI.equals(mimeType)) {
                AviDirectory aviDir = metadata.getFirstDirectoryOfType(AviDirectory.class);
                if (aviDir != null) {
                    if (aviDir.containsTag(AviDirectory.TAG_WIDTH)) {
                        width = aviDir.getInt(AviDirectory.TAG_WIDTH);
                    }
                    if (aviDir.containsTag(AviDirectory.TAG_HEIGHT)) {
                        height = aviDir.getInt(AviDirectory.TAG_HEIGHT);
                    }
                    if (aviDir.containsTag(AviDirectory.TAG_DURATION)) {
                        durationMillis = aviDir.getLong(AviDirectory.TAG_DURATION);
                    }
                }
            }
        } catch (IOException | ImageProcessingException | MetadataException e) {
            // ignore
        }
    }

    // expects entry with: uri/path
    // finds: width, height
    private void fillByBitmapDecode(Context context) {
        if (MimeTypes.SVG.equals(mimeType)) return;

        try (InputStream is = StorageUtils.openInputStream(context, uri, path)) {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeStream(is, null, options);
            width = options.outWidth;
            height = options.outHeight;
        } catch (IOException e) {
            // ignore
        }
    }

    // convenience method

    private static Long toLong(Object o) {
        if (o == null) return null;
        if (o instanceof Integer) return Long.valueOf((Integer) o);
        return (long) o;
    }
}
