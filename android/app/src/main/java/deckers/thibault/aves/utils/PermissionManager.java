package deckers.thibault.aves.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.UriPermission;
import android.net.Uri;
import android.os.Build;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.google.common.base.Splitter;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class PermissionManager {
    private static final String LOG_TAG = Utils.createLogTag(PermissionManager.class);

    public static final int VOLUME_ROOT_PERMISSION_REQUEST_CODE = 1;

    // permission request code to pending runnable
    private static ConcurrentHashMap<Integer, PendingPermissionHandler> pendingPermissionMap = new ConcurrentHashMap<>();

    public static void requestVolumeAccess(@NonNull Activity activity, @NonNull String path, @NonNull Runnable onGranted, @NonNull Runnable onDenied) {
        Log.i(LOG_TAG, "request user to select and grant access permission to volume=" + path);
        pendingPermissionMap.put(VOLUME_ROOT_PERMISSION_REQUEST_CODE, new PendingPermissionHandler(path, onGranted, onDenied));

        Intent intent = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            StorageManager sm = activity.getSystemService(StorageManager.class);
            if (sm != null) {
                StorageVolume volume = sm.getStorageVolume(new File(path));
                if (volume != null) {
                    intent = volume.createOpenDocumentTreeIntent();
                }
            }
        }

        // fallback to basic open document tree intent
        if (intent == null) {
            intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        }

        ActivityCompat.startActivityForResult(activity, intent, VOLUME_ROOT_PERMISSION_REQUEST_CODE, null);
    }

    public static void onPermissionResult(int requestCode, @Nullable Uri treeUri) {
        Log.d(LOG_TAG, "onPermissionResult with requestCode=" + requestCode + ", treeUri=" + treeUri);
        boolean granted = treeUri != null;

        PendingPermissionHandler handler = pendingPermissionMap.remove(requestCode);
        if (handler == null) return;

        Runnable runnable = granted ? handler.onGranted : handler.onDenied;
        if (runnable == null) return;
        runnable.run();
    }

    public static Optional<String> getGrantedDirForPath(@NonNull Context context, @NonNull String anyPath) {
        return getAccessibleDirs(context).stream().filter(anyPath::startsWith).findFirst();
    }

    public static List<Map<String, String>> getInaccessibleDirectories(@NonNull Context context, @NonNull List<String> dirPaths) {
        Set<String> accessibleDirs = getAccessibleDirs(context);

        // find set of inaccessible directories for each volume
        Map<String, Set<String>> dirsPerVolume = new HashMap<>();
        for (String dirPath : dirPaths) {
            if (!dirPath.endsWith(File.separator)) {
                dirPath += File.separator;
            }
            if (accessibleDirs.stream().noneMatch(dirPath::startsWith)) {
                // inaccessible dirs
                StorageUtils.PathSegments segments = new StorageUtils.PathSegments(context, dirPath);
                Set<String> dirSet = dirsPerVolume.getOrDefault(segments.volumePath, new HashSet<>());
                if (dirSet != null) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        // request primary directory on volume from Android R
                        String relativeDir = segments.relativeDir;
                        if (relativeDir != null) {
                            Iterator<String> iterator = Splitter.on(File.separatorChar).omitEmptyStrings().split(relativeDir).iterator();
                            if (iterator.hasNext()) {
                                // primary dir
                                dirSet.add(iterator.next());
                            }
                        }
                    } else {
                        // request volume root until Android Q
                        dirSet.add("");
                    }
                }
                dirsPerVolume.put(segments.volumePath, dirSet);
            }
        }

        // format for easier handling on Flutter
        List<Map<String, String>> inaccessibleDirs = new ArrayList<>();
        StorageManager sm = context.getSystemService(StorageManager.class);
        if (sm != null) {
            for (Map.Entry<String, Set<String>> volumeEntry : dirsPerVolume.entrySet()) {
                String volumePath = volumeEntry.getKey();
                String volumeDescription = "";
                try {
                    StorageVolume volume = sm.getStorageVolume(new File(volumePath));
                    if (volume != null) {
                        volumeDescription = volume.getDescription(context);
                    }
                } catch (IllegalArgumentException e) {
                    // ignore
                }
                for (String relativeDir : volumeEntry.getValue()) {
                    HashMap<String, String> dirMap = new HashMap<>();
                    dirMap.put("volumePath", volumePath);
                    dirMap.put("volumeDescription", volumeDescription);
                    dirMap.put("relativeDir", relativeDir);
                    inaccessibleDirs.add(dirMap);
                }
            }
        }
        Log.d(LOG_TAG, "getInaccessibleDirectories dirPaths=" + dirPaths + " -> inaccessibleDirs=" + inaccessibleDirs);
        return inaccessibleDirs;
    }


    public static void revokeDirectoryAccess(Context context, String path) {
        Optional<Uri> uri = StorageUtils.convertDirPathToTreeUri(context, path);
        if (uri.isPresent()) {
            int flags = Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
            context.getContentResolver().releasePersistableUriPermission(uri.get(), flags);
        }
    }

    // returns paths matching URIs granted by the user
    public static Set<String> getGrantedDirs(Context context) {
        Set<String> grantedDirs = new HashSet<>();
        for (UriPermission uriPermission : context.getContentResolver().getPersistedUriPermissions()) {
            Optional<String> dirPath = StorageUtils.convertTreeUriToDirPath(context, uriPermission.getUri());
            dirPath.ifPresent(grantedDirs::add);
        }
        return grantedDirs;
    }

    // returns paths accessible to the app (granted by the user or by default)
    private static Set<String> getAccessibleDirs(Context context) {
        Set<String> accessibleDirs = new HashSet<>(getGrantedDirs(context));
        // from Android R, we no longer have access permission by default on primary volume
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
            String primaryPath = StorageUtils.getPrimaryVolumePath();
            accessibleDirs.add(primaryPath);
        }
        Log.d(LOG_TAG, "getAccessibleDirs accessibleDirs=" + accessibleDirs);
        return accessibleDirs;
    }

    static class PendingPermissionHandler {
        final String path;
        final Runnable onGranted; // user gave access to a directory, with no guarantee that it matches the specified `path`
        final Runnable onDenied; // user cancelled

        PendingPermissionHandler(@NonNull String path, @NonNull Runnable onGranted, @NonNull Runnable onDenied) {
            this.path = path;
            this.onGranted = onGranted;
            this.onDenied = onDenied;
        }
    }
}
