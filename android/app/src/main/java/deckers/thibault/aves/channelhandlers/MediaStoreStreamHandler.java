package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import io.flutter.plugin.common.EventChannel;

public class MediaStoreStreamHandler implements EventChannel.StreamHandler {
    public static final String CHANNEL = "deckers.thibault/aves/mediastore";

    private EventChannel.EventSink eventSink;

    @Override
    public void onListen(Object args, final EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onCancel(Object args) {
        // nothing
    }

    void fetchAll(Activity activity) {
        Handler handler = new Handler(Looper.getMainLooper());
        new MediaStoreImageProvider().fetchAll(activity, (entry) -> handler.post(() -> eventSink.success(entry))); // 350ms
        handler.post(() -> eventSink.endOfStream());
    }
}