package deckers.thibault.aves.channelhandlers;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.support.annotation.NonNull;

import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import java.util.Map;

import deckers.thibault.aves.model.ImageEntry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageDecodeHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/image";

    private Activity activity;
    private ImageDecodeTaskManager imageDecodeTaskManager;
    private MediaStoreStreamHandler mediaStoreStreamHandler;

    public ImageDecodeHandler(Activity activity, MediaStoreStreamHandler mediaStoreStreamHandler) {
        this.activity = activity;
        imageDecodeTaskManager = new ImageDecodeTaskManager(activity);
        this.mediaStoreStreamHandler = mediaStoreStreamHandler;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getImageEntries":
                getPermissionResult(result, activity);
                break;
            case "getImageBytes": {
                Map map = call.argument("entry");
                Integer width = call.argument("width");
                Integer height = call.argument("height");
                if (map == null) {
                    result.error("getImageBytes-args", "failed to get image bytes because 'entry' is null", null);
                    return;
                }
                ImageEntry entry = new ImageEntry(map);
                imageDecodeTaskManager.fetch(result, entry, width, height);
                break;
            }
            case "cancelGetImageBytes": {
                String uri = call.argument("uri");
                imageDecodeTaskManager.cancel(uri);
                result.success(null);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void getPermissionResult(final MethodChannel.Result result, final Activity activity) {
        Dexter.withActivity(activity)
                .withPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        mediaStoreStreamHandler.fetchAll(activity);
                        result.success(null);
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {

                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                        builder.setTitle("We need this permission");
                        builder.setCancelable(false);
                        builder.setPositiveButton("OK", (dialog, id) -> {
                            dialog.cancel();
                            Intent intent = new Intent();
                            intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                            Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                            intent.setData(uri);
                            activity.startActivity(intent);
                        });
                        builder.setNegativeButton("Cancel", (dialog, id) -> dialog.cancel());
                        AlertDialog alert = builder.create();
                        alert.show();
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, final PermissionToken token) {
                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                        builder.setTitle("We need this permission");
                        builder.setCancelable(false);
                        builder.setPositiveButton("OK", (dialog, id) -> {
                            dialog.cancel();
                            token.continuePermissionRequest();
                        });
                        builder.setNegativeButton("Cancel", (dialog, id) -> {
                            dialog.cancel();
                            token.cancelPermissionRequest();
                        });
                        AlertDialog alert = builder.create();
                        alert.show();
                    }
                }).check();
    }
}