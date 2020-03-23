package deckers.thibault.aves.channelhandlers;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel;

// ensure `result` methods are called on the main looper thread
public class MethodResultWrapper implements MethodChannel.Result {
    private MethodChannel.Result methodResult;
    private Handler handler;

    MethodResultWrapper(MethodChannel.Result result) {
        methodResult = result;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
        handler.post(() -> methodResult.success(result));
    }

    @Override
    public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> methodResult.error(errorCode, errorMessage, errorDetails));
    }

    @Override
    public void notImplemented() {
        handler.post(() -> methodResult.notImplemented());
    }
}