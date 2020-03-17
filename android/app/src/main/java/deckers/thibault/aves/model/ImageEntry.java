package deckers.thibault.aves.model;

import android.net.Uri;

import androidx.annotation.Nullable;

import java.io.File;
import java.util.Map;

import deckers.thibault.aves.utils.Constants;

public class ImageEntry {
    // from source
    private String path; // best effort to get local path from content providers
    private Uri uri; // content URI
    private String mimeType;
    private int width, height, orientationDegrees;
    private long sizeBytes;
    private String title, bucketDisplayName;
    private long dateModifiedSecs, sourceDateTakenMillis;
    private long durationMillis;

    // uri: content provider uri
    // path: FileUtils.getPathFromUri(activity, itemUri) is useful (for Download, File, etc.) but is slower than directly using `MediaStore.MediaColumns.DATA` from the MediaStore query

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

    public Uri getUri() {
        return uri;
    }

    @Nullable
    public String getPath() {
        return path;
    }

    public String getFilename() {
        return path == null ? null : new File(path).getName();
    }

    public boolean isVideo() {
        return mimeType.startsWith(Constants.MIME_VIDEO);
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

    public long getDateModifiedSecs() {
        return dateModifiedSecs;
    }

    // convenience method

    private static long toLong(Object o) {
        if (o instanceof Integer) return Long.valueOf((Integer) o);
        return (long) o;
    }
}
