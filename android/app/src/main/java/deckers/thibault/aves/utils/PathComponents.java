package deckers.thibault.aves.utils;

import androidx.annotation.NonNull;

import java.io.File;

public class PathComponents {
    private String storage;
    private String folder;
    private String filename;

    public PathComponents(@NonNull String path, @NonNull String[] storageVolumes) {
        for (int i = 0; i < storageVolumes.length && storage == null; i++) {
            if (path.startsWith(storageVolumes[i])) {
                storage = storageVolumes[i];
            }
        }

        int lastSeparatorIndex = path.lastIndexOf(File.separator) + 1;
        if (lastSeparatorIndex > storage.length()) {
            filename = path.substring(lastSeparatorIndex);
            folder = path.substring(storage.length(), lastSeparatorIndex);
        }
    }

    public String getStorage() {
        return storage;
    }

    String getFolder() {
        return folder;
    }

    String getFilename() {
        return filename;
    }
}
