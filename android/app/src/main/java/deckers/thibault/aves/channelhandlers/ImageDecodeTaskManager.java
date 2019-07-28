package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.os.AsyncTask;

import java.util.HashMap;

import deckers.thibault.aves.model.ImageEntry;
import io.flutter.plugin.common.MethodChannel;

public class ImageDecodeTaskManager {
    private Activity activity;
    private HashMap<String, AsyncTask> taskMap = new HashMap<>();

    ImageDecodeTaskManager(Activity activity) {
        this.activity = activity;
    }

    void fetch(MethodChannel.Result result, ImageEntry entry, Integer width, Integer height) {
        ImageDecodeTask.Params params = new ImageDecodeTask.Params(entry, width, height, result, this::complete);
        AsyncTask task = new ImageDecodeTask(activity).execute(params);
        taskMap.put(entry.getUri().toString(), task);
    }

    void cancel(String uri) {
        AsyncTask task = taskMap.get(uri);
        if (task != null) task.cancel(true);
        taskMap.remove(uri);
    }

    private void complete(String uri) {
        taskMap.remove(uri);
    }
}
