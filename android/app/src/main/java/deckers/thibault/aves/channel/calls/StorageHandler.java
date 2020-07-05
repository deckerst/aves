package deckers.thibault.aves.channel.calls;

import android.app.Activity;
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

    private Activity activity;

    public StorageHandler(Activity activity) {
        this.activity = activity;
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
            case "requireVolumeAccessDialog": {
                String path = call.argument("path");
                if (path == null) {
                    result.success(true);
                } else {
                    result.success(PermissionManager.requireVolumeAccessDialog(activity, path));
                }
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
        StorageManager sm = activity.getSystemService(StorageManager.class);
        if (sm != null) {
            for (String volumePath : StorageUtils.getVolumePaths(activity)) {
                try {
                    StorageVolume volume = sm.getStorageVolume(new File(volumePath));
                    if (volume != null) {
                        Map<String, Object> volumeMap = new HashMap<>();
                        volumeMap.put("path", volumePath);
                        volumeMap.put("description", volume.getDescription(activity));
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
}
