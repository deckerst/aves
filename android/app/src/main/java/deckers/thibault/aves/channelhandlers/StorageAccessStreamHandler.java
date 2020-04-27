package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import java.util.Map;

import deckers.thibault.aves.utils.PermissionManager;
import io.flutter.plugin.common.EventChannel;

// starting activity to give access with the native dialog
// breaks the regular `MethodChannel` so we use a stream channel instead
public class StorageAccessStreamHandler implements EventChannel.StreamHandler {
    public static final String CHANNEL = "deckers.thibault/aves/storageaccessstream";

    private Activity activity;
    private EventChannel.EventSink eventSink;
    private Handler handler;
    private String volumePath;

    public StorageAccessStreamHandler(Activity activity, Object arguments) {
        this.activity = activity;
        if (arguments instanceof Map) {
            Map argMap = (Map) arguments;
            this.volumePath = (String) argMap.get("path");
        }
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        this.handler = new Handler(Looper.getMainLooper());
        Runnable onGranted = () -> success(PermissionManager.hasGrantedPermissionToVolumeRoot(activity, volumePath));
        Runnable onDenied = () -> success(false);
        PermissionManager.requestVolumeAccess(activity, volumePath, onGranted, onDenied);
    }

    @Override
    public void onCancel(Object o) {
    }

    private void success(final boolean result) {
        handler.post(() -> eventSink.success(result));
        endOfStream();
    }

    private void error(final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> eventSink.error(errorCode, errorMessage, errorDetails));
    }

    private void endOfStream() {
        handler.post(() -> eventSink.endOfStream());
    }
}
