package deckers.thibault.aves.utils;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.content.UriPermission;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;

import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

public class PermissionManager {
    private static final String LOG_TAG = Utils.createLogTag(PermissionManager.class);

    // permission request code to pending runnable
    private static ConcurrentHashMap<Integer, Runnable> pendingPermissionMap = new ConcurrentHashMap<>();

    // check access permission to SD card directory & return its content URI if available
    public static Uri getSdCardTreeUri(Activity activity) {
        final String sdCardDocumentUri = Env.getSdCardDocumentUri(activity);
        Optional<UriPermission> uriPermissionOptional = activity.getContentResolver().getPersistedUriPermissions().stream()
                .filter(uriPermission -> uriPermission.getUri().toString().equals(sdCardDocumentUri))
                .findFirst();
        return uriPermissionOptional.map(UriPermission::getUri).orElse(null);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public static void showSdCardAccessDialog(final Activity activity, final Runnable pendingRunnable) {
        new AlertDialog.Builder(activity)
                .setTitle("SD Card Access")
                .setMessage("Please select the root directory of the SD card in the next screen, so that this app has permission to access it and complete your request.")
                .setPositiveButton(android.R.string.ok, (dialog, whichButton) -> {
                    Log.i(LOG_TAG, "request user to select and grant access permission to SD card");
                    pendingPermissionMap.put(Constants.SD_CARD_PERMISSION_REQUEST_CODE, pendingRunnable);
                    ActivityCompat.startActivityForResult(activity,
                            new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE),
                            Constants.SD_CARD_PERMISSION_REQUEST_CODE, null);
                })
                .show();
    }

    public static void onPermissionGranted(int requestCode) {
        Runnable runnable = pendingPermissionMap.remove(requestCode);
        if (runnable != null) {
            runnable.run();
        }
    }
}
