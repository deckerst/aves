package deckers.thibault.aves.channelhandlers;

import android.app.Activity;
import android.util.Log;

import java.util.concurrent.LinkedBlockingDeque;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.MethodChannel;

public class ImageDecodeTaskManager {
    private static final String LOG_TAG = Utils.createLogTag(ImageDecodeTaskManager.class);

    private LinkedBlockingDeque<ImageDecodeTask.Params> taskParamsQueue;
    private boolean running = true;

    ImageDecodeTaskManager(Activity activity) {
        taskParamsQueue = new LinkedBlockingDeque<>();
        new Thread(() -> {
            try {
                while (running) {
                    ImageDecodeTask.Params params = taskParamsQueue.take();
                    new ImageDecodeTask(activity).execute(params);
                    Thread.sleep(10);
                }
            } catch (InterruptedException ex) {
                Log.w(LOG_TAG, ex);
            }
        }).start();
    }

    void fetch(MethodChannel.Result result, ImageEntry entry, Integer width, Integer height) {
        taskParamsQueue.addFirst(new ImageDecodeTask.Params(entry, width, height, result, this::complete));
    }

    void cancel(String uri) {
        boolean removed = taskParamsQueue.removeIf(p -> uri.equals(p.entry.uri.toString()));
        if (removed) Log.d(LOG_TAG, "cancelled uri=" + uri);
    }

    private void complete(String uri) {
        // nothing for now
    }
}
