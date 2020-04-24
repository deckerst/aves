package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.EventChannel;

public class MediaStoreStreamHandler implements EventChannel.StreamHandler {
    public static final String CHANNEL = "deckers.thibault/aves/mediastore";

    private static final String LOG_TAG = Utils.createLogTag(MediaStoreStreamHandler.class);

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
//        Log.d(LOG_TAG, "fetchAll start");
//        Instant start = Instant.now();
        Handler handler = new Handler(Looper.getMainLooper());
        new MediaStoreImageProvider().fetchAll(activity, (entry) -> handler.post(() -> eventSink.success(entry))); // 350ms
        handler.post(() -> eventSink.endOfStream());
//        Log.d(LOG_TAG, "fetchAll complete in " + Duration.between(start, Instant.now()).toMillis() + "ms");
    }
}