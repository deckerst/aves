package deckers.thibault.aves.channel.calls;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Size;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Key;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.signature.ObjectKey;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

import deckers.thibault.aves.decoder.VideoThumbnail;
import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.MethodChannel;

public class ImageDecodeTask extends AsyncTask<ImageDecodeTask.Params, Void, ImageDecodeTask.Result> {
    private static final String LOG_TAG = Utils.createLogTag(ImageDecodeTask.class);

    static class Params {
        ImageEntry entry;
        Integer width, height, defaultSize;
        MethodChannel.Result result;

        Params(ImageEntry entry, @Nullable Integer width, @Nullable Integer height, Integer defaultSize, MethodChannel.Result result) {
            this.entry = entry;
            this.width = width;
            this.height = height;
            this.result = result;
            this.defaultSize = defaultSize;
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
        Bitmap bitmap = null;
        if (!this.isCancelled()) {
            Exception exception = null;
            Integer w = p.width;
            Integer h = p.height;
            // fetch low quality thumbnails when size is not specified
            if (w == null || h == null || w == 0 || h == 0) {
                p.width = p.defaultSize;
                p.height = p.defaultSize;
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        bitmap = getThumbnailBytesByResolver(p);
                    } else {
                        bitmap = getThumbnailBytesByMediaStore(p);
                    }
                } catch (Exception e) {
                    exception = e;
                }
            }

            // fallback if the native methods failed or for higher quality thumbnails
            try {
                if (bitmap == null) {
                    bitmap = getThumbnailByGlide(p);
                }
            } catch (Exception e) {
                exception = e;
            }

            if (bitmap == null) {
                Log.e(LOG_TAG, "failed to load thumbnail for uri=" + p.entry.uri + ", path=" + p.entry.path, exception);
            }
        } else {
            Log.d(LOG_TAG, "getThumbnail with uri=" + p.entry.uri + " cancelled");
        }
        byte[] data = null;
        if (bitmap != null) {
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            // we compress the bitmap because Dart Image.memory cannot decode the raw bytes
            // Bitmap.CompressFormat.PNG is slower than JPEG
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, stream);
            data = stream.toByteArray();
        }
        return new Result(p, data);
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    private Bitmap getThumbnailBytesByResolver(Params params) throws IOException {
        ImageEntry entry = params.entry;
        Integer width = params.width;
        Integer height = params.height;
//        Log.d(LOG_TAG, "getThumbnailBytesByResolver width=" + width + ", path=" + entry.path);

        ContentResolver resolver = activity.getContentResolver();
        return resolver.loadThumbnail(entry.uri, new Size(width, height), null);
    }

    private Bitmap getThumbnailBytesByMediaStore(Params params) {
        ImageEntry entry = params.entry;
        long contentId = ContentUris.parseId(entry.uri);

        ContentResolver resolver = activity.getContentResolver();
        if (entry.isVideo()) {
            return MediaStore.Video.Thumbnails.getThumbnail(resolver, contentId, MediaStore.Video.Thumbnails.MINI_KIND, null);
        } else {
            Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(resolver, contentId, MediaStore.Images.Thumbnails.MINI_KIND, null);
            // from Android Q, returned thumbnail is already rotated according to EXIF orientation
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q && bitmap != null) {
                Integer orientationDegrees = entry.orientationDegrees;
                if (orientationDegrees != null && orientationDegrees != 0) {
                    Matrix matrix = new Matrix();
                    matrix.postRotate(orientationDegrees);
                    bitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
                }
            }
            return bitmap;
        }
    }

    private Bitmap getThumbnailByGlide(Params params) throws ExecutionException, InterruptedException {
        ImageEntry entry = params.entry;
        int width = params.width;
        int height = params.height;
//        Log.d(LOG_TAG, "getThumbnailByGlide width=" + width + ", path=" + entry.path);

        // add signature to ignore cache for images which got modified but kept the same URI
        Key signature = new ObjectKey("" + entry.dateModifiedSecs + entry.width + entry.orientationDegrees);
        RequestOptions options = new RequestOptions()
                .signature(signature)
                .override(width, height);

        FutureTarget<Bitmap> target;
        if (entry.isVideo()) {
            options = options.diskCacheStrategy(DiskCacheStrategy.RESOURCE);
            target = Glide.with(activity)
                    .asBitmap()
                    .apply(options)
                    .load(new VideoThumbnail(activity, entry.uri))
                    .signature(signature)
                    .submit(width, height);
        } else {
            target = Glide.with(activity)
                    .asBitmap()
                    .apply(options)
                    .load(entry.uri)
                    .signature(signature)
                    .submit(width, height);
        }

        try {
            return target.get();
        } finally {
            Glide.with(activity).clear(target);
        }
    }

    @Override
    protected void onPostExecute(Result result) {
        MethodChannel.Result r = result.params.result;
        String uri = result.params.entry.uri.toString();
        if (result.data != null) {
            r.success(result.data);
        } else {
            r.error("getThumbnail-null", "failed to get thumbnail for uri=" + uri, null);
        }
    }
}
