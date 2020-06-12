package deckers.thibault.aves.channel.streams;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import java.util.Map;

import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import io.flutter.plugin.common.EventChannel;

public class MediaStoreStreamHandler implements EventChannel.StreamHandler {
    public static final String CHANNEL = "deckers.thibault/aves/mediastorestream";

    private Activity activity;
    private EventChannel.EventSink eventSink;
    private Handler handler;
    private Map<Integer, Integer> knownEntries;

    @SuppressWarnings("unchecked")
    public MediaStoreStreamHandler(Activity activity, Object arguments) {
        this.activity = activity;
        if (arguments instanceof Map) {
            Map<String, Object> argMap = (Map<String, Object>) arguments;
            this.knownEntries = (Map<Integer, Integer>) argMap.get("knownEntries");
        }
    }

    @Override
    public void onListen(Object args, final EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        this.handler = new Handler(Looper.getMainLooper());
        new Thread(this::fetchAll).start();
    }

    @Override
    public void onCancel(Object args) {
        // nothing
    }

    private void success(final Map<String, Object> result) {
        handler.post(() -> eventSink.success(result));
    }

    private void endOfStream() {
        handler.post(() -> eventSink.endOfStream());
    }

    void fetchAll() {
        new MediaStoreImageProvider().fetchAll(activity, knownEntries, this::success); // 350ms
        endOfStream();
    }
}