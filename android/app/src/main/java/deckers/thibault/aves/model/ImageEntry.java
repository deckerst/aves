package deckers.thibault.aves.model;

import android.content.ContentUris;
import android.content.Context;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.format.DateUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import deckers.thibault.aves.utils.Constants;

public class ImageEntry {
    private static final Uri mediaStoreContentUri = MediaStore.Files.getContentUri("external");

    // from source
    private String path; // best effort to get local path from content providers
    private long contentId; // should be defined for mediastore, use full URI otherwise
    private Uri uri; // should be defined for external content, use ID for mediastore
    private String mimeType;
    private int width, height, orientationDegrees;
    private long sizeBytes;
    private String title, bucketDisplayName;
    private long dateModifiedSecs, sourceDateTakenMillis;
    private long durationMillis;
    // derived
    private boolean isVideo;

    public ImageEntry(Uri uri, String mimeType) {
        this.contentId = -1;
        this.uri = uri;
        this.mimeType = mimeType;
        init();
    }

    public ImageEntry(String path, long id, String mimeType, int width, int height, int orientationDegrees, long sizeBytes,
                      String title, long dateModifiedSecs, long dateTakenMillis, String bucketDisplayName, long durationMillis) {
        this.path = path;
        this.contentId = id;
        this.uri = null;
        this.mimeType = mimeType;
        this.width = width;
        this.height = height;
        this.orientationDegrees = orientationDegrees;
        this.sizeBytes = sizeBytes;
        this.title = title;
        this.dateModifiedSecs = dateModifiedSecs;
        this.sourceDateTakenMillis = dateTakenMillis;
        this.bucketDisplayName = bucketDisplayName;
        this.durationMillis = durationMillis;
        init();
    }

    public static Map toMap(ImageEntry entry) {
        return new HashMap<String, Object>() {{
            put("path", entry.path);
            put("contentId", entry.contentId);
            put("uri", entry.uri);
            put("mimeType", entry.mimeType);
            put("width", entry.width);
            put("height", entry.height);
            put("orientationDegrees", entry.orientationDegrees);
            put("sizeBytes", entry.sizeBytes);
            put("title", entry.title);
            put("dateModifiedSecs", entry.dateModifiedSecs);
            put("sourceDateTakenMillis", entry.sourceDateTakenMillis);
            put("bucketDisplayName", entry.bucketDisplayName);
            put("durationMillis", entry.durationMillis);
        }};
    }

    private void init() {
        isVideo = mimeType.startsWith(Constants.MIME_VIDEO);
    }

    @Nullable
    public String getPath() {
        return path;
    }

    public String getFilename() {
        return path == null ? null : new File(path).getName();
    }

    public InputStream getInputStream(Context context) throws FileNotFoundException {
        // FileInputStream is faster than input stream from ContentResolver
        return path != null ? new FileInputStream(path) : context.getContentResolver().openInputStream(getUri());
    }

    public Uri getUri() {
        if (uri != null) {
            return uri;
        }
        return ContentUris.withAppendedId(mediaStoreContentUri, contentId);
    }

    public boolean isVideo() {
        return isVideo;
    }

    public boolean isEditable() {
        return path != null;
    }

    public boolean isGif() {
        return Constants.MIME_GIF.equals(mimeType);
    }

    public String getMimeType() {
        return mimeType;
    }

    public int getWidth() {
        return width;
    }

    public int getHeight() {
        return height;
    }

    public int getOrientationDegrees() {
        return orientationDegrees;
    }

    public long getSizeBytes() {
        return sizeBytes;
    }

    public String getTitle() {
        return title;
    }

    public long getDateModifiedSecs() {
        return dateModifiedSecs;
    }

    String getBucketDisplayName() {
        return bucketDisplayName;
    }

    public String getDuration() {
        return DateUtils.formatElapsedTime(durationMillis / 1000);
    }

    public int getMegaPixels() {
        return Math.round((width * height) / 1000000f);
    }

    // setters

    public void setContentId(long contentId) {
        this.contentId = contentId;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public void setSizeBytes(long sizeBytes) {
        this.sizeBytes = sizeBytes;
    }

    public void setDateModifiedSecs(long dateModifiedSecs) {
        this.dateModifiedSecs = dateModifiedSecs;
    }

    public void setTitle(String title) {
        this.title = title;
    }
}
