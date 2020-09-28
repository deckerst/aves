package deckers.thibault.aves.channel.calls;

import android.app.Activity;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.bumptech.glide.Glide;

import java.util.List;
import java.util.Map;

import deckers.thibault.aves.model.AvesImageEntry;
import deckers.thibault.aves.model.provider.ImageProvider;
import deckers.thibault.aves.model.provider.ImageProviderFactory;
import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageFileHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/image";

    private Activity activity;
    private float density;

    public ImageFileHandler(Activity activity) {
        this.activity = activity;
    }

    public float getDensity() {
        if (density == 0) {
            density = activity.getResources().getDisplayMetrics().density;
        }
        return density;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getObsoleteEntries":
                new Thread(() -> getObsoleteEntries(call, new MethodResultWrapper(result))).start();
                break;
            case "getImageEntry":
                new Thread(() -> getImageEntry(call, new MethodResultWrapper(result))).start();
                break;
            case "getThumbnail":
                new Thread(() -> getThumbnail(call, new MethodResultWrapper(result))).start();
                break;
            case "clearSizedThumbnailDiskCache":
                new Thread(() -> Glide.get(activity).clearDiskCache()).start();
                result.success(null);
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
        Map<String, Object> entryMap = call.argument("entry");
        Double widthDip = call.argument("widthDip");
        Double heightDip = call.argument("heightDip");
        Double defaultSizeDip = call.argument("defaultSizeDip");

        if (entryMap == null || widthDip == null || heightDip == null || defaultSizeDip == null) {
            result.error("getThumbnail-args", "failed because of missing arguments", null);
            return;
        }
        // convert DIP to physical pixels here, instead of using `devicePixelRatio` in Flutter
        float density = getDensity();
        int width = (int) Math.round(widthDip * density);
        int height = (int) Math.round(heightDip * density);
        int defaultSize = (int) Math.round(defaultSizeDip * density);

        AvesImageEntry entry = new AvesImageEntry(entryMap);
        new ImageDecodeTask(activity).execute(new ImageDecodeTask.Params(entry, width, height, defaultSize, result));
    }

    private void getObsoleteEntries(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        List<Integer> known = call.argument("knownContentIds");
        if (known == null) {
            result.error("getObsoleteEntries-args", "failed because of missing arguments", null);
            return;
        }
        List<Integer> obsolete = new MediaStoreImageProvider().getObsoleteContentIds(activity, known);
        result.success(obsolete);
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
            public void onFailure(Throwable throwable) {
                result.error("getImageEntry-failure", "failed to get entry for uri=" + uriString, throwable.getMessage());
            }
        });
    }

    private void rename(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> entryMap = call.argument("entry");
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
            public void onFailure(Throwable throwable) {
                new Handler(Looper.getMainLooper()).post(() -> result.error("rename-failure", "failed to rename", throwable.getMessage()));
            }
        });
    }

    private void rotate(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> entryMap = call.argument("entry");
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
            public void onFailure(Throwable throwable) {
                new Handler(Looper.getMainLooper()).post(() -> result.error("rotate-failure", "failed to rotate", throwable.getMessage()));
            }
        });
    }
}