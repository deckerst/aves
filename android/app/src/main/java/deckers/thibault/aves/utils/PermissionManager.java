package deckers.thibault.aves.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.UriPermission;
import android.net.Uri;
import android.os.Build;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.provider.DocumentsContract;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.core.util.Pair;

import java.io.File;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Stream;

public class PermissionManager {
    private static final String LOG_TAG = Utils.createLogTag(PermissionManager.class);

    // permission request code to pending runnable
    private static ConcurrentHashMap<Integer, Pair<Runnable, Runnable>> pendingPermissionMap = new ConcurrentHashMap<>();

    // check access permission to SD card directory & return its content URI if available
    public static Uri getSdCardTreeUri(Activity activity) {
        final String sdCardDocumentUri = Env.getSdCardDocumentUri(activity);
        Optional<UriPermission> uriPermissionOptional = activity.getContentResolver().getPersistedUriPermissions().stream()
                .filter(uriPermission -> uriPermission.getUri().toString().equals(sdCardDocumentUri))
                .findFirst();
        return uriPermissionOptional.map(UriPermission::getUri).orElse(null);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static void showSdCardAccessDialog(final Activity activity, final Runnable pendingRunnable) {
        new AlertDialog.Builder(activity)
                .setTitle("SD Card Access")
                .setMessage("Please select the root directory of the SD card in the next screen, so that this app has permission to access it and complete your request.")
                .setPositiveButton(android.R.string.ok, (dialog, button) -> requestVolumeAccess(activity, null, pendingRunnable, null))
                .show();
    }

    public static void requestVolumeAccess(Activity activity, String volumePath, Runnable onGranted, Runnable onDenied) {
        Log.i(LOG_TAG, "request user to select and grant access permission to volume=" + volumePath);
        pendingPermissionMap.put(Constants.SD_CARD_PERMISSION_REQUEST_CODE, Pair.create(onGranted, onDenied));

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

        ActivityCompat.startActivityForResult(activity, intent, Constants.SD_CARD_PERMISSION_REQUEST_CODE, null);
    }

    public static void onPermissionResult(int requestCode, boolean granted) {
        Log.d(LOG_TAG, "onPermissionResult with requestCode=" + requestCode + ", granted=" + granted);
        Pair<Runnable, Runnable> runnables = pendingPermissionMap.remove(requestCode);
        if (runnables == null) return;
        Runnable runnable = granted ? runnables.first : runnables.second;
        if (runnable == null) return;
        runnable.run();
    }

    public static boolean hasGrantedPermissionToVolumeRoot(Context context, String path) {
        boolean canAccess = false;
        Stream<Uri> permittedUris = context.getContentResolver().getPersistedUriPermissions().stream().map(UriPermission::getUri);
        // e.g. content://com.android.externalstorage.documents/tree/12A9-8B42%3A
        StorageManager sm = context.getSystemService(StorageManager.class);
        if (sm != null) {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                StorageVolume volume = sm.getStorageVolume(new File(path));
                if (volume != null) {
                    // primary storage doesn't have a UUID
                    String uuid = volume.isPrimary() ? "primary" : volume.getUuid();
                    Uri targetVolumeTreeUri = getVolumeTreeUriFromUuid(uuid);
                    canAccess = permittedUris.anyMatch(uri -> uri.equals(targetVolumeTreeUri));
                }
            } else {
                // TODO TLAD find alternative for Android <N
                canAccess = true;
            }
        }
        return canAccess;
    }

    private static Uri getVolumeTreeUriFromUuid(String uuid) {
        return DocumentsContract.buildTreeDocumentUri(
                "com.android.externalstorage.documents",
                uuid + ":"
        );
    }
}
