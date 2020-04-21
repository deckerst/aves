package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.Map;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.model.provider.ImageProvider;
import deckers.thibault.aves.model.provider.ImageProviderFactory;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageFileHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/image";

    private Activity activity;
    private MediaStoreStreamHandler mediaStoreStreamHandler;

    public ImageFileHandler(Activity activity, MediaStoreStreamHandler mediaStoreStreamHandler) {
        this.activity = activity;
        this.mediaStoreStreamHandler = mediaStoreStreamHandler;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getImageEntries":
                new Thread(() -> mediaStoreStreamHandler.fetchAll(activity)).start();
                result.success(null);
                break;
            case "getImageEntry":
                new Thread(() -> getImageEntry(call, new MethodResultWrapper(result))).start();
                break;
            case "getThumbnail":
                new Thread(() -> getThumbnail(call, new MethodResultWrapper(result))).start();
                break;
            case "delete":
                new Thread(() -> delete(call, new MethodResultWrapper(result))).start();
                break;
            case "rename":
                new Thread(() -> rename(call, new MethodResultWrapper(result))).start();
                break;
            case "rotate":
                new Thread(() -> rotate(call, new MethodResultWrapper(result))).start();
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getThumbnail(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map entryMap = call.argument("entry");
        Integer width = call.argument("width");
        Integer height = call.argument("height");
        if (entryMap == null || width == null || height == null) {
            result.error("getThumbnail-args", "failed because of missing arguments", null);
            return;
        }
        ImageEntry entry = new ImageEntry(entryMap);
        new ImageDecodeTask(activity).execute(new ImageDecodeTask.Params(entry, width, height, result));
    }

    private void getImageEntry(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String uriString = call.argument("uri");
        String mimeType = call.argument("mimeType");
        if (uriString == null || mimeType == null) {
            result.error("getImageEntry-args", "failed because of missing arguments", null);
            return;
        }

        Uri uri = Uri.parse(uriString);
        ImageProvider provider = ImageProviderFactory.getProvider(uri);
        if (provider == null) {
            result.error("getImageEntry-provider", "failed to find provider for uri=" + uriString, null);
            return;
        }

        provider.fetchSingle(activity, uri, mimeType, new ImageProvider.ImageOpCallback() {
            @Override
            public void onSuccess(Map<String, Object> entry) {
                result.success(entry);
            }

            @Override
            public void onFailure() {
                result.error("getImageEntry-failure", "failed to get entry for uri=" + uriString, null);
            }
        });
    }

    private void delete(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map entryMap = call.argument("entry");
        if (entryMap == null) {
            result.error("delete-args", "failed because of missing arguments", null);
            return;
        }
        Uri uri = Uri.parse((String) entryMap.get("uri"));
        String path = (String) entryMap.get("path");

        ImageProvider provider = ImageProviderFactory.getProvider(uri);
        if (provider == null) {
            result.error("delete-provider", "failed to find provider for uri=" + uri, null);
            return;
        }
        provider.delete(activity, path, uri, new ImageProvider.ImageOpCallback() {
            @Override
            public void onSuccess(Map<String, Object> newFields) {
                new Handler(Looper.getMainLooper()).post(() -> result.success(newFields));
            }

            @Override
            public void onFailure() {
                new Handler(Looper.getMainLooper()).post(() -> result.error("delete-failure", "failed to delete", null));
            }
        });
    }

    private void rename(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map entryMap = call.argument("entry");
        String newName = call.argument("newName");
        if (entryMap == null || newName == null) {
            result.error("rename-args", "failed because of missing arguments", null);
            return;
        }
        Uri uri = Uri.parse((String) entryMap.get("uri"));
        String path = (String) entryMap.get("path");
        String mimeType = (String) entryMap.get("mimeType");

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
        Map entryMap = call.argument("entry");
        Boolean clockwise = call.argument("clockwise");
        if (entryMap == null || clockwise == null) {
            result.error("rotate-args", "failed because of missing arguments", null);
            return;
        }
        Uri uri = Uri.parse((String) entryMap.get("uri"));
        String path = (String) entryMap.get("path");
        String mimeType = (String) entryMap.get("mimeType");

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
}