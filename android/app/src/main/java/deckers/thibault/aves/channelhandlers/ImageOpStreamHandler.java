package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import deckers.thibault.aves.model.provider.ImageProvider;
import deckers.thibault.aves.model.provider.ImageProviderFactory;
import io.flutter.plugin.common.EventChannel;

public class ImageOpStreamHandler implements EventChannel.StreamHandler {
    public static final String CHANNEL = "deckers.thibault/aves/imageopstream";

    private Activity activity;
    private EventChannel.EventSink eventSink;
    private Handler handler;
    private List<Map> entryMapList;
    private String op;

    public ImageOpStreamHandler(Activity activity, Object arguments) {
        this.activity = activity;
        if (arguments instanceof Map) {
            Map argMap = (Map) arguments;
            this.op = (String) argMap.get("op");
            this.entryMapList = new ArrayList<>();
            List rawEntries = (List) argMap.get("entries");
            if (rawEntries != null) {
                for (Object entry : rawEntries) {
                    entryMapList.add((Map) entry);
                }
            }
        }
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        this.handler = new Handler(Looper.getMainLooper());
        if ("delete".equals(op)) {
            new Thread(this::delete).start();
        } else {
            endOfStream();
        }
    }

    @Override
    public void onCancel(Object o) {
    }

    // {String uri, bool success}
    private void success(final Map<String, Object> result) {
        handler.post(() -> eventSink.success(result));
    }

    private void error(final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> eventSink.error(errorCode, errorMessage, errorDetails));
    }

    private void endOfStream() {
        handler.post(() -> eventSink.endOfStream());
    }

    private void delete() {
        if (entryMapList.size() == 0) {
            endOfStream();
            return;
        }

        // assume same provider for all entries
        Map firstEntry = entryMapList.get(0);
        Uri firstUri = Uri.parse((String) firstEntry.get("uri"));
        ImageProvider provider = ImageProviderFactory.getProvider(firstUri);
        if (provider == null) {
            error("delete-provider", "failed to find provider for uri=" + firstUri, null);
            return;
        }

        for (Map entryMap : entryMapList) {
            String uriString = (String) entryMap.get("uri");
            Uri uri = Uri.parse(uriString);
            String path = (String) entryMap.get("path");
            provider.delete(activity, path, uri, new ImageProvider.ImageOpCallback() {
                @Override
                public void onSuccess(Map<String, Object> newFields) {
                    Map<String, Object> result = new HashMap<String, Object>() {{
                        put("uri", uriString);
                        put("success", true);
                    }};
                    success(result);
                }

                @Override
                public void onFailure() {
                    Map<String, Object> result = new HashMap<String, Object>() {{
                        put("uri", uriString);
                        put("success", false);
                    }};
                    success(result);
                }
            });
        }
        endOfStream();
    }
}
