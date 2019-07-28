package deckers.thibault.aves.channelhandlers;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.util.Log;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Key;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.signature.ObjectKey;

import java.io.ByteArrayOutputStream;
import java.util.function.Consumer;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.MethodChannel;

public class ImageDecodeTask extends AsyncTask<ImageDecodeTask.Params, Void, ImageDecodeTask.Result> {
    private static final String LOG_TAG = Utils.createLogTag(ImageDecodeTask.class);

    static class Params {
        ImageEntry entry;
        int width, height;
        MethodChannel.Result result;
        Consumer<String> complete;

        Params(ImageEntry entry, int width, int height, MethodChannel.Result result, Consumer<String> complete) {
            this.entry = entry;
            this.width = width;
            this.height = height;
            this.result = result;
            this.complete = complete;
        }
    }

    static class Result {
        Params params;
        byte[] data;

        Result(Params params, byte[] data) {
            this.params = params;
            this.data = data;
        }
    }

    @SuppressLint("StaticFieldLeak")
    private Activity activity;

    ImageDecodeTask(Activity activity) {
        this.activity = activity;
    }

    @Override
    protected Result doInBackground(Params... params) {
        Params p = params[0];
        ImageEntry entry = p.entry;
        byte[] data = null;
        if (!this.isCancelled()) {
            // add signature to ignore cache for images which got modified but kept the same URI
            Key signature = new ObjectKey("" + entry.getDateModifiedSecs() + entry.getWidth() + entry.getOrientationDegrees());
            FutureTarget<Bitmap> target = Glide.with(activity)
                    .asBitmap()
                    .load(entry.getUri())
                    .signature(signature)
                    .submit(p.width, p.height);
            try {
                Bitmap bmp = target.get();
                if (bmp != null) {
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    bmp.compress(Bitmap.CompressFormat.JPEG, 90, stream);
                    data = stream.toByteArray();
                }
            } catch (InterruptedException e) {
                Log.d(LOG_TAG, "getImageBytes with uri=" + entry.getUri() + " interrupted");
            } catch (Exception e) {
                e.printStackTrace();
            }
            Glide.with(activity).clear(target);
        } else {
            Log.d(LOG_TAG, "getImageBytes with uri=" + entry.getUri() + " cancelled");
        }
        return new Result(p, data);
    }

    @Override
    protected void onPostExecute(Result result) {
        MethodChannel.Result r = result.params.result;
        String uri = result.params.entry.getUri().toString();
        result.params.complete.accept(uri);
        if (result.data != null) {
            r.success(result.data);
        } else {
            r.error("getImageBytes-null", "failed to get thumbnail for uri=" + uri, null);
        }
    }
}
