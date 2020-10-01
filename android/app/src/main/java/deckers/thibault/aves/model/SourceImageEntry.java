package deckers.thibault.aves.model;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;
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
import com.drew.metadata.photoshop.PsdHeaderDirectory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import deckers.thibault.aves.utils.MetadataHelper;
import deckers.thibault.aves.utils.MimeTypes;
import deckers.thibault.aves.utils.StorageUtils;

public class SourceImageEntry {
    public Uri uri; // content or file URI
    public String path; // best effort to get local path

    public String sourceMimeType;
    @Nullable
    public String title;
    @Nullable
    public Integer width, height, rotationDegrees;
    @Nullable
    public Long sizeBytes;
    @Nullable
    public Long dateModifiedSecs;
    @Nullable
    private Long sourceDateTakenMillis;
    @Nullable
    private Long durationMillis;

    public SourceImageEntry() {
    }

    public SourceImageEntry(@NonNull Map<String, Object> map) {
        this.uri = Uri.parse((String) map.get("uri"));
        this.path = (String) map.get("path");
        this.sourceMimeType = (String) map.get("sourceMimeType");
        this.width = (int) map.get("width");
        this.height = (int) map.get("height");
        this.rotationDegrees = (int) map.get("orientationDegrees");
        this.sizeBytes = toLong(map.get("sizeBytes"));
        this.title = (String) map.get("title");
        this.dateModifiedSecs = toLong(map.get("dateModifiedSecs"));
        this.sourceDateTakenMillis = toLong(map.get("sourceDateTakenMillis"));
        this.durationMillis = toLong(map.get("durationMillis"));
    }

    public Map<String, Object> toMap() {
        return new HashMap<String, Object>() {{
            put("uri", uri.toString());
            put("path", path);
            put("sourceMimeType", sourceMimeType);
            put("width", width);
            put("height", height);
            put("orientationDegrees", rotationDegrees != null ? rotationDegrees : 0);
            put("sizeBytes", sizeBytes);
            put("title", title);
            put("dateModifiedSecs", dateModifiedSecs);
            put("sourceDateTakenMillis", sourceDateTakenMillis);
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
        return sourceMimeType.startsWith(MimeTypes.IMAGE);
    }

    public boolean isSvg() {
        return sourceMimeType.equals(MimeTypes.SVG);
    }

    private boolean isVideo() {
        return sourceMimeType.startsWith(MimeTypes.VIDEO);
    }

    // metadata retrieval

    // expects entry with: uri, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    public SourceImageEntry fillPreCatalogMetadata(@NonNull Context context) {
        fillByMediaMetadataRetriever(context);
        if (hasSize() && (!isVideo() || hasDuration())) return this;
        fillByMetadataExtractor(context);
        if (hasSize()) return this;
        fillByBitmapDecode(context);
        return this;
    }

    // expects entry with: uri, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    private void fillByMediaMetadataRetriever(@NonNull Context context) {
        MediaMetadataRetriever retriever = StorageUtils.openMetadataRetriever(context, uri);
        if (retriever != null) {
            try {
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
                    this.rotationDegrees = Integer.parseInt(rotation);
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
            } finally {
                // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                retriever.release();
            }
        }
    }

    // expects entry with: uri, mimeType
    // finds: width, height, orientation, date
    private void fillByMetadataExtractor(@NonNull Context context) {
        if (isSvg()) return;

        try (InputStream is = StorageUtils.openInputStream(context, uri)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);

            switch (sourceMimeType) {
                case MimeTypes.JPEG:
                    for (JpegDirectory dir : metadata.getDirectoriesOfType(JpegDirectory.class)) {
                        if (dir.containsTag(JpegDirectory.TAG_IMAGE_WIDTH)) {
                            width = dir.getInt(JpegDirectory.TAG_IMAGE_WIDTH);
                        }
                        if (dir.containsTag(JpegDirectory.TAG_IMAGE_HEIGHT)) {
                            height = dir.getInt(JpegDirectory.TAG_IMAGE_HEIGHT);
                        }
                    }
                    break;
                case MimeTypes.MP4:
                    for (Mp4VideoDirectory dir : metadata.getDirectoriesOfType(Mp4VideoDirectory.class)) {
                        if (dir.containsTag(Mp4VideoDirectory.TAG_WIDTH)) {
                            width = dir.getInt(Mp4VideoDirectory.TAG_WIDTH);
                        }
                        if (dir.containsTag(Mp4VideoDirectory.TAG_HEIGHT)) {
                            height = dir.getInt(Mp4VideoDirectory.TAG_HEIGHT);
                        }
                    }
                    for (Mp4Directory dir : metadata.getDirectoriesOfType(Mp4Directory.class)) {
                        if (dir.containsTag(Mp4Directory.TAG_DURATION)) {
                            durationMillis = dir.getLong(Mp4Directory.TAG_DURATION);
                        }
                    }
                    break;
                case MimeTypes.AVI:
                    for (AviDirectory dir : metadata.getDirectoriesOfType(AviDirectory.class)) {
                        if (dir.containsTag(AviDirectory.TAG_WIDTH)) {
                            width = dir.getInt(AviDirectory.TAG_WIDTH);
                        }
                        if (dir.containsTag(AviDirectory.TAG_HEIGHT)) {
                            height = dir.getInt(AviDirectory.TAG_HEIGHT);
                        }
                        if (dir.containsTag(AviDirectory.TAG_DURATION)) {
                            durationMillis = dir.getLong(AviDirectory.TAG_DURATION);
                        }
                    }
                    break;
                case MimeTypes.PSD:
                    for (PsdHeaderDirectory dir : metadata.getDirectoriesOfType(PsdHeaderDirectory.class)) {
                        if (dir.containsTag(PsdHeaderDirectory.TAG_IMAGE_WIDTH)) {
                            width = dir.getInt(PsdHeaderDirectory.TAG_IMAGE_WIDTH);
                        }
                        if (dir.containsTag(PsdHeaderDirectory.TAG_IMAGE_HEIGHT)) {
                            height = dir.getInt(PsdHeaderDirectory.TAG_IMAGE_HEIGHT);
                        }
                    }
                    break;
            }

            for (ExifIFD0Directory dir : metadata.getDirectoriesOfType(ExifIFD0Directory.class)) {
                if (dir.containsTag(ExifIFD0Directory.TAG_IMAGE_WIDTH)) {
                    width = dir.getInt(ExifIFD0Directory.TAG_IMAGE_WIDTH);
                }
                if (dir.containsTag(ExifIFD0Directory.TAG_IMAGE_HEIGHT)) {
                    height = dir.getInt(ExifIFD0Directory.TAG_IMAGE_HEIGHT);
                }
                if (dir.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
                    int exifOrientation = dir.getInt(ExifIFD0Directory.TAG_ORIENTATION);
                    rotationDegrees = MetadataHelper.getRotationDegreesForExifCode(exifOrientation);
                }
                if (dir.containsTag(ExifIFD0Directory.TAG_DATETIME)) {
                    sourceDateTakenMillis = dir.getDate(ExifIFD0Directory.TAG_DATETIME, null, TimeZone.getDefault()).getTime();
                }
            }
        } catch (IOException | ImageProcessingException | MetadataException | NoClassDefFoundError e) {
            // ignore
        }
    }

    // expects entry with: uri
    // finds: width, height
    private void fillByBitmapDecode(@NonNull Context context) {
        if (isSvg()) return;

        try (InputStream is = StorageUtils.openInputStream(context, uri)) {
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

    private static Long toLong(@Nullable Object o) {
        if (o == null) return null;
        if (o instanceof Integer) return Long.valueOf((Integer) o);
        return (long) o;
    }
}
