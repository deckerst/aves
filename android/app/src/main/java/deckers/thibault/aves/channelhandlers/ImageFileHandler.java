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
                mediaStoreStreamHandler.fetchAll(activity);
                result.success(null);
                break;
            case "getImageEntry":
                getImageEntry(call, result);
                break;
            case "getImageBytes":
                getImageBytes(call, result);
                break;
            case "cancelGetImageBytes":
                cancelGetImageBytes(call, result);
                break;
            case "delete":
                delete(call, result);
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
        Map entryMap = call.argument("entry");
        Integer width = call.argument("width");
        Integer height = call.argument("height");
        if (entryMap == null || width == null || height == null) {
            result.error("getImageBytes-args", "failed because of missing arguments", null);
            return;
        }
        ImageEntry entry = new ImageEntry(entryMap);
        imageDecodeTaskManager.fetch(result, entry, width, height);
    }

    private void cancelGetImageBytes(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String uri = call.argument("uri");
        imageDecodeTaskManager.cancel(uri);
        result.success(null);
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