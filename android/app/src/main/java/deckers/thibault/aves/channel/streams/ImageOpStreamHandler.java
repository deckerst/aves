package deckers.thibault.aves.channel.streams;

import android.app.Activity;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.model.provider.ImageProvider;
import deckers.thibault.aves.model.provider.ImageProviderFactory;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.EventChannel;

public class ImageOpStreamHandler implements EventChannel.StreamHandler {
    private static final String LOG_TAG = Utils.createLogTag(ImageOpStreamHandler.class);

    public static final String CHANNEL = "deckers.thibault/aves/imageopstream";

    private Activity activity;
    private EventChannel.EventSink eventSink;
    private Handler handler;
    private Map<String, Object> argMap;
    private List<Map<String, Object>> entryMapList;
    private String op;

    @SuppressWarnings("unchecked")
    public ImageOpStreamHandler(Activity activity, Object arguments) {
        this.activity = activity;
        if (arguments instanceof Map) {
            argMap = (Map<String, Object>) arguments;
            this.op = (String) argMap.get("op");
            this.entryMapList = new ArrayList<>();
            List<Map<String, Object>> rawEntries = (List<Map<String, Object>>) argMap.get("entries");
            if (rawEntries != null) {
                entryMapList.addAll(rawEntries);
            }
        }
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        this.handler = new Handler(Looper.getMainLooper());
        if ("delete".equals(op)) {
            new Thread(this::delete).start();
        } else if ("move".equals(op)) {
            new Thread(this::move).start();
        } else {
            endOfStream();
        }
    }

    @Override
    public void onCancel(Object o) {
    }

    // {String uri, bool success, [Map<String, Object> newFields]}
    private void success(final Map<String, Object> result) {
        handler.post(() -> eventSink.success(result));
    }

    private void error(final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> eventSink.error(errorCode, errorMessage, errorDetails));
    }

    private void endOfStream() {
        handler.post(() -> eventSink.endOfStream());
    }

    private void move() {
        if (entryMapList.size() == 0) {
            endOfStream();
            return;
        }

        // assume same provider for all entries
        Map<String, Object> firstEntry = entryMapList.get(0);
        Uri firstUri = Uri.parse((String) firstEntry.get("uri"));
        ImageProvider provider = ImageProviderFactory.getProvider(firstUri);
        if (provider == null) {
            error("move-provider", "failed to find provider for uri=" + firstUri, null);
            return;
        }

        Boolean copy = (Boolean) argMap.get("copy");
        String destinationDir = (String) argMap.get("destinationPath");
        if (copy == null || destinationDir == null) return;

        ArrayList<ImageEntry> entries = entryMapList.stream().map(ImageEntry::new).collect(Collectors.toCollection(ArrayList::new));
        provider.moveMultiple(activity, copy, destinationDir, entries, new ImageProvider.ImageOpCallback() {
            @Override
            public void onSuccess(Map<String, Object> fields) {
                success(fields);
            }

            @Override
            public void onFailure(Throwable throwable) {
                error("move-failure", "failed to move entries", throwable);
            }
        });
        endOfStream();
    }

    private void delete() {
        if (entryMapList.size() == 0) {
            endOfStream();
            return;
        }

        // assume same provider for all entries
        Map<String, Object> firstEntry = entryMapList.get(0);
        Uri firstUri = Uri.parse((String) firstEntry.get("uri"));
        ImageProvider provider = ImageProviderFactory.getProvider(firstUri);
        if (provider == null) {
            error("delete-provider", "failed to find provider for uri=" + firstUri, null);
            return;
        }

        for (Map<String, Object> entryMap : entryMapList) {
            String uriString = (String) entryMap.get("uri");
            Uri uri = Uri.parse(uriString);
            String path = (String) entryMap.get("path");

            Map<String, Object> result = new HashMap<String, Object>() {{
                put("uri", uriString);
            }};
            try {
                provider.delete(activity, path, uri).get();
                result.put("success", true);
            } catch (ExecutionException | InterruptedException e) {
                Log.w(LOG_TAG, "failed to delete entry with path=" + path, e);
                result.put("success", false);
            }
            success(result);

        }
        endOfStream();
    }
}
