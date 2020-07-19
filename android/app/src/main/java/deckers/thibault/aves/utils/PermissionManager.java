package deckers.thibault.aves.utils;

import android.app.Activity;
import android.content.Intent;
import android.content.UriPermission;
import android.net.Uri;
import android.os.Build;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;

import java.io.File;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

public class PermissionManager {
    private static final String LOG_TAG = Utils.createLogTag(PermissionManager.class);

    public static final int VOLUME_ROOT_PERMISSION_REQUEST_CODE = 1;

    // permission request code to pending runnable
    private static ConcurrentHashMap<Integer, PendingPermissionHandler> pendingPermissionMap = new ConcurrentHashMap<>();

    public static boolean requireVolumeAccessDialog(Activity activity, @NonNull String anyPath) {
        return StorageUtils.requireAccessPermission(anyPath) && getVolumeTreeUri(activity, anyPath) == null;
    }

    // check access permission to volume root directory & return its tree URI if available
    @Nullable
    public static Uri getVolumeTreeUri(Activity activity, @NonNull String anyPath) {
        String volumeTreeUri = StorageUtils.getVolumeTreeUriForPath(activity, anyPath).orElse(null);
        Optional<UriPermission> uriPermissionOptional = activity.getContentResolver().getPersistedUriPermissions().stream()
                .filter(uriPermission -> uriPermission.getUri().toString().equals(volumeTreeUri))
                .findFirst();
        return uriPermissionOptional.map(UriPermission::getUri).orElse(null);
    }

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

    public static void onPermissionResult(Activity activity, int requestCode, @Nullable Uri treeUri) {
        Log.d(LOG_TAG, "onPermissionResult with requestCode=" + requestCode + ", treeUri=" + treeUri);
        boolean granted = treeUri != null;

        PendingPermissionHandler handler = pendingPermissionMap.remove(requestCode);
        if (handler == null) return;

        if (granted) {
            String requestedPath = handler.path;
            if (isTreeUriPath(requestedPath, treeUri)) {
                StorageUtils.setVolumeTreeUri(activity, requestedPath, treeUri.toString());
            } else {
                granted = false;
            }
        }

        Runnable runnable = granted ? handler.onGranted : handler.onDenied;
        if (runnable == null) return;
        runnable.run();
    }

    private static boolean isTreeUriPath(String path, Uri treeUri) {
        // TODO TLAD check requestedPath match treeUri
        // e.g. OK match for path=/storage/emulated/0/, treeUri=content://com.android.externalstorage.documents/tree/primary%3A
        // e.g. NO match for path=/storage/10F9-3F13/, treeUri=content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures
        Log.d(LOG_TAG, "isTreeUriPath path=" + path + ", treeUri=" + treeUri);
        return true;
    }

    static class PendingPermissionHandler {
        final String path;
        final Runnable onGranted;
        final Runnable onDenied;

        PendingPermissionHandler(@NonNull String path, @NonNull Runnable onGranted, @NonNull Runnable onDenied) {
            this.path = path;
            this.onGranted = onGranted;
            this.onDenied = onDenied;
        }
    }
}
