package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;

import androidx.annotation.NonNull;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import deckers.thibault.aves.utils.Env;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FileAdapterHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/file";

    private Activity activity;

    public FileAdapterHandler(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getStorageVolumes": {
                List<Map<String, Object>> volumes = new ArrayList<>();
                StorageManager sm = activity.getSystemService(StorageManager.class);
                if (sm != null) {
                    for (String path : Env.getStorageVolumes(activity)) {
                        try {
                            File file = new File(path);
                            StorageVolume volume = sm.getStorageVolume(file);
                            if (volume != null) {
                                Map<String, Object> volumeMap = new HashMap<>();
                                volumeMap.put("path", path);
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
                result.success(volumes);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }
}
