package deckers.thibault.aves.utils;

import androidx.annotation.NonNull;

import java.io.File;

public class PathSegments {
    private String storage;
    private String relativePath;
    private String filename;

    public PathSegments(@NonNull String path, @NonNull String[] storageVolumePaths) {
        for (int i = 0; i < storageVolumePaths.length && storage == null; i++) {
            if (path.startsWith(storageVolumePaths[i])) {
                storage = storageVolumePaths[i];
            }
        }

        int lastSeparatorIndex = path.lastIndexOf(File.separator) + 1;
        if (lastSeparatorIndex > storage.length()) {
            filename = path.substring(lastSeparatorIndex);
            relativePath = path.substring(storage.length(), lastSeparatorIndex);
        }
    }

    public String getStorage() {
        return storage;
    }

    public String getRelativePath() {
        return relativePath;
    }

    public String getFilename() {
        return filename;
    }
}
