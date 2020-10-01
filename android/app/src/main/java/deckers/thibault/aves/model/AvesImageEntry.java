package deckers.thibault.aves.model;

import android.net.Uri;

import androidx.annotation.Nullable;

import java.util.Map;

import deckers.thibault.aves.utils.MimeTypes;

public class AvesImageEntry {
    public Uri uri; // content or file URI
    public String path; // best effort to get local path
    public String mimeType;
    @Nullable
    public Integer width, height, rotationDegrees;
    @Nullable
    public Long dateModifiedSecs;

    public AvesImageEntry(Map<String, Object> map) {
        this.uri = Uri.parse((String) map.get("uri"));
        this.path = (String) map.get("path");
        this.mimeType = (String) map.get("mimeType");
        this.width = (Integer) map.get("width");
        this.height = (Integer) map.get("height");
        this.rotationDegrees = (Integer) map.get("orientationDegrees");
        this.dateModifiedSecs = toLong(map.get("dateModifiedSecs"));
    }

    public boolean isVideo() {
        return mimeType.startsWith(MimeTypes.VIDEO);
    }

    // convenience method

    private static Long toLong(Object o) {
        if (o == null) return null;
        if (o instanceof Integer) return Long.valueOf((Integer) o);
        return (long) o;
    }
}
