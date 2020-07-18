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

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static void showVolumeAccessDialog(final Activity activity, @NonNull String anyPath, final Runnable pendingRunnable) {
        String volumePath = StorageUtils.getVolumePath(activity, anyPath).orElse(null);
        // TODO TLAD show volume name/ID in the message
        new AlertDialog.Builder(activity)
                .setTitle("Storage Volume Access")
                .setMessage("Please select the root directory of the storage volume in the next screen, so that this app has permission to access it and complete your request.")
                .setPositiveButton(android.R.string.ok, (dialog, button) -> requestVolumeAccess(activity, volumePath, pendingRunnable, null))
                .show();
    }

    public static void requestVolumeAccess(Activity activity, String volumePath, Runnable onGranted, Runnable onDenied) {
        Log.i(LOG_TAG, "request user to select and grant access permission to volume=" + volumePath);
        pendingPermissionMap.put(VOLUME_ROOT_PERMISSION_REQUEST_CODE, new PendingPermissionHandler(volumePath, onGranted, onDenied));

        Intent intent = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && volumePath != null) {
            StorageManager sm = activity.getSystemService(StorageManager.class);
            if (sm != null) {
                StorageVolume volume = sm.getStorageVolume(new File(volumePath));
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

    public static void onPermissionResult(Activity activity, int requestCode, boolean granted, Uri treeUri) {
        Log.d(LOG_TAG, "onPermissionResult with requestCode=" + requestCode + ", granted=" + granted);

        PendingPermissionHandler handler = pendingPermissionMap.remove(requestCode);
        if (handler == null) return;
        StorageUtils.setVolumeTreeUri(activity, handler.volumePath, treeUri.toString());

        Runnable runnable = granted ? handler.onGranted : handler.onDenied;
        if (runnable == null) return;
        runnable.run();
    }

    static class PendingPermissionHandler {
        String volumePath;
        Runnable onGranted;
        Runnable onDenied;

        PendingPermissionHandler(String volumePath, Runnable onGranted, Runnable onDenied) {
            this.volumePath = volumePath;
            this.onGranted = onGranted;
            this.onDenied = onDenied;
        }
    }
}
