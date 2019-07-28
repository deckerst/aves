package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.util.Log;

import java.util.stream.Stream;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.EventChannel;

public class MediaStoreStreamHandler implements EventChannel.StreamHandler {
    public static final String CHANNEL = "deckers.thibault/aves/mediastore";

    private static final String LOG_TAG = Utils.createLogTag(MediaStoreStreamHandler.class);

    private EventChannel.EventSink eventSink;

    @Override
    public void onListen(Object args, final EventChannel.EventSink events) {
        Log.w(LOG_TAG, "onListen with args=" + args);
        eventSink = events;
    }

    @Override
    public void onCancel(Object args) {
        Log.w(LOG_TAG, "onCancel with args=" + args);
    }

    void fetchAll(Activity activity) {
        Log.d(LOG_TAG, "fetchAll start");
        Stream<ImageEntry> stream = new MediaStoreImageProvider().fetchAll(activity);
        stream.map(ImageEntry::toMap)
                .forEach(entry -> eventSink.success(entry));
        eventSink.endOfStream();
    }
}