package deckers.thibault.aves.channel.calls;

import android.content.Context;
import android.media.MediaScannerConnection;
import android.os.Build;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.StorageUtils;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class StorageHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/storage";

    private Context context;

    public StorageHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getStorageVolumes": {
                List<Map<String, Object>> volumes;
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                    volumes = getStorageVolumes();
                } else {
                    // TODO TLAD find alternative for Android <N
                    volumes = new ArrayList<>();
                }
                result.success(volumes);
                break;
            }
            case "getInaccessibleDirectories": {
                List<String> dirPaths = call.argument("dirPaths");
                if (dirPaths == null) {
                    result.error("getInaccessibleDirectories-args", "failed because of missing arguments", null);
                } else {
                    result.success(PermissionManager.getInaccessibleDirectories(context, dirPaths));
                }
                break;
            }
            case "scanFile": {
                scanFile(call, new MethodResultWrapper(result));
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    private List<Map<String, Object>> getStorageVolumes() {
        List<Map<String, Object>> volumes = new ArrayList<>();
        StorageManager sm = context.getSystemService(StorageManager.class);
        if (sm != null) {
            for (String volumePath : StorageUtils.getVolumePaths(context)) {
                try {
                    StorageVolume volume = sm.getStorageVolume(new File(volumePath));
                    if (volume != null) {
                        Map<String, Object> volumeMap = new HashMap<>();
                        volumeMap.put("path", volumePath);
                        volumeMap.put("description", volume.getDescription(context));
                        volumeMap.put("isPrimary", volume.isPrimary());
                        volumeMap.put("isRemovable", volume.isRemovable());
                        volumeMap.put("isEmulated", volume.isEmulated());
                        volumeMap.put("state", volume.getState());
                        volumes.add(volumeMap);
                    }
                } catch (IllegalArgumentException e) {
                    // ignore
                }
            }
        }
        return volumes;
    }

    private void scanFile(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        String mimeType = call.argument("mimeType");
        MediaScannerConnection.scanFile(context, new String[]{path}, new String[]{mimeType}, (p, uri) -> {
            result.success(uri != null ? uri.toString() : null);
        });
    }
}