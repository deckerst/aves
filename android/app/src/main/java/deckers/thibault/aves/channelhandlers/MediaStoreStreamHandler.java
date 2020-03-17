package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.util.Log;

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
        Log.d(LOG_TAG, "fetchAll start");
//        Instant start = Instant.now();
        new MediaStoreImageProvider().fetchAll(activity, eventSink); // 350ms
        eventSink.endOfStream();
//        Log.d(LOG_TAG, "fetchAll complete in " + Duration.between(start, Instant.now()).toMillis() + "ms");
    }
}