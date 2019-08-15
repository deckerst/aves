package deckers.thibault.aves.channelhandlers;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;

import androidx.annotation.NonNull;

import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import java.util.Map;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.model.provider.ImageProvider;
import deckers.thibault.aves.model.provider.ImageProviderFactory;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageFileHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/image";

    private Activity activity;
    private ImageDecodeTaskManager imageDecodeTaskManager;
    private MediaStoreStreamHandler mediaStoreStreamHandler;

    public ImageFileHandler(Activity activity, MediaStoreStreamHandler mediaStoreStreamHandler) {
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
            case "getImageBytes":
                getImageBytes(call, result);
                break;
            case "cancelGetImageBytes":
                cancelGetImageBytes(call, result);
                break;
            case "rename":
                rename(call, result);
                break;
            case "rotate":
                rotate(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getImageBytes(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map map = call.argument("entry");
        Integer width = call.argument("width");
        Integer height = call.argument("height");
        if (map == null || width == null || height == null) {
            result.error("getImageBytes-args", "failed because of missing arguments", null);
            return;
        }
        ImageEntry entry = new ImageEntry(map);
        imageDecodeTaskManager.fetch(result, entry, width, height);
    }

    private void cancelGetImageBytes(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String uri = call.argument("uri");
        imageDecodeTaskManager.cancel(uri);
        result.success(null);
    }

    private void rename(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map map = call.argument("entry");
        String newName = call.argument("newName");
        if (map == null || newName == null) {
            result.error("rename-args", "failed because of missing arguments", null);
            return;
        }
        Uri uri = Uri.parse((String) map.get("uri"));
        String path = (String) map.get("path");
        String mimeType = (String) map.get("mimeType");

        ImageProvider provider = ImageProviderFactory.getProvider(uri);
        if (provider == null) {
            result.error("rename-provider", "failed to find provider for uri=" + uri, null);
            return;
        }
        provider.rename(activity, path, uri, mimeType, newName, new ImageProvider.ImageOpCallback() {
            @Override
            public void onSuccess(Map<String, Object> newFields) {
                new Handler(Looper.getMainLooper()).post(() -> result.success(newFields));
            }

            @Override
            public void onFailure() {
                new Handler(Looper.getMainLooper()).post(() -> result.error("rename-failure", "failed to rename", null));
            }
        });
    }

    private void rotate(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map map = call.argument("entry");
        Boolean clockwise = call.argument("clockwise");
        if (map == null || clockwise == null) {
            result.error("rotate-args", "failed because of missing arguments", null);
            return;
        }
        Uri uri = Uri.parse((String) map.get("uri"));
        String path = (String) map.get("path");
        String mimeType = (String) map.get("mimeType");

        ImageProvider provider = ImageProviderFactory.getProvider(uri);
        if (provider == null) {
            result.error("rotate-provider", "failed to find provider for uri=" + uri, null);
            return;
        }
        provider.rotate(activity, path, uri, mimeType, clockwise, new ImageProvider.ImageOpCallback() {
            @Override
            public void onSuccess(Map<String, Object> newFields) {
                new Handler(Looper.getMainLooper()).post(() -> result.success(newFields));
            }

            @Override
            public void onFailure() {
                new Handler(Looper.getMainLooper()).post(() -> result.error("rotate-failure", "failed to rotate", null));
            }
        });
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