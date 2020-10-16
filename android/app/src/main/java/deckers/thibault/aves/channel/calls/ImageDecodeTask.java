package deckers.thibault.aves.channel.calls;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Size;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DecodeFormat;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.signature.ObjectKey;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

import deckers.thibault.aves.decoder.VideoThumbnail;
import deckers.thibault.aves.utils.BitmapUtils;
import deckers.thibault.aves.utils.LogUtils;
import deckers.thibault.aves.utils.MimeTypes;
import io.flutter.plugin.common.MethodChannel;

public class ImageDecodeTask extends AsyncTask<ImageDecodeTask.Params, Void, ImageDecodeTask.Result> {
    private static final String LOG_TAG = LogUtils.createTag(ImageDecodeTask.class);

    static class Params {
        Uri uri;
        String mimeType;
        Long dateModifiedSecs;
        Integer rotationDegrees, width, height, defaultSize;
        Boolean isFlipped;
        MethodChannel.Result result;

        Params(@NonNull String uri, @NonNull String mimeType, @NonNull Long dateModifiedSecs, @NonNull Integer rotationDegrees, @NonNull Boolean isFlipped, @Nullable Integer width, @Nullable Integer height, Integer defaultSize, MethodChannel.Result result) {
            this.uri = Uri.parse(uri);
            this.mimeType = mimeType;
            this.dateModifiedSecs = dateModifiedSecs;
            this.rotationDegrees = rotationDegrees;
            this.isFlipped = isFlipped;
            this.width = width;
            this.height = height;
            this.result = result;
            this.defaultSize = defaultSize;
        }
    }

    static class Result {
        Params params;
        byte[] data;
        String errorDetails;

        Result(Params params, byte[] data, String errorDetails) {
            this.params = params;
            this.data = data;
            this.errorDetails = errorDetails;
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
        Exception exception = null;
        if (!this.isCancelled()) {
            Integer w = p.width;
            Integer h = p.height;
            // fetch low quality thumbnails when size is not specified
            if (w == null || h == null || w == 0 || h == 0) {
                p.width = p.defaultSize;
                p.height = p.defaultSize;
                // EXIF orientations with flipping are not well supported by the Media Store:
                // the content resolver may return a thumbnail that is automatically rotated
                // according to EXIF orientation, but not flip it when necessary
                if (!p.isFlipped) {
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
            }

            // fallback if the native methods failed or for higher quality thumbnails
            try {
                if (bitmap == null) {
                    bitmap = getThumbnailByGlide(p);
                }
            } catch (Exception e) {
                exception = e;
            }
        } else {
            Log.d(LOG_TAG, "getThumbnail with uri=" + p.uri + " cancelled");
        }

        byte[] data = null;
        if (bitmap != null) {
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            // we compress the bitmap because Dart Image.memory cannot decode the raw bytes
            // Bitmap.CompressFormat.PNG is slower than JPEG
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, stream);
            data = stream.toByteArray();
        }

        String errorDetails = null;
        if (exception != null) {
            errorDetails = exception.getMessage();
            if (errorDetails != null && !errorDetails.isEmpty()) {
                errorDetails = errorDetails.split("\n", 2)[0];
            }
        }
        return new Result(p, data, errorDetails);
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    private Bitmap getThumbnailBytesByResolver(Params params) throws IOException {
        ContentResolver resolver = activity.getContentResolver();
        Bitmap bitmap = resolver.loadThumbnail(params.uri, new Size(params.width, params.height), null);
        String mimeType = params.mimeType;
        if (MimeTypes.needRotationAfterContentResolverThumbnail(mimeType)) {
            bitmap = BitmapUtils.applyExifOrientation(activity, bitmap, params.rotationDegrees, params.isFlipped);
        }
        return bitmap;
    }

    private Bitmap getThumbnailBytesByMediaStore(Params params) {
        long contentId = ContentUris.parseId(params.uri);

        ContentResolver resolver = activity.getContentResolver();
        if (MimeTypes.isVideo(params.mimeType)) {
            return MediaStore.Video.Thumbnails.getThumbnail(resolver, contentId, MediaStore.Video.Thumbnails.MINI_KIND, null);
        } else {
            Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(resolver, contentId, MediaStore.Images.Thumbnails.MINI_KIND, null);
            // from Android Q, returned thumbnail is already rotated according to EXIF orientation
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q && bitmap != null) {
                bitmap = BitmapUtils.applyExifOrientation(activity, bitmap, params.rotationDegrees, params.isFlipped);
            }
            return bitmap;
        }
    }

    private Bitmap getThumbnailByGlide(Params params) throws ExecutionException, InterruptedException {
        Uri uri = params.uri;
        String mimeType = params.mimeType;
        Long dateModifiedSecs = params.dateModifiedSecs;
        Integer rotationDegrees = params.rotationDegrees;
        Boolean isFlipped = params.isFlipped;
        int width = params.width;
        int height = params.height;

        RequestOptions options = new RequestOptions()
                .format(DecodeFormat.PREFER_RGB_565)
                // add signature to ignore cache for images which got modified but kept the same URI
                .signature(new ObjectKey("" + dateModifiedSecs + rotationDegrees + isFlipped + width))
                .override(width, height);

        FutureTarget<Bitmap> target;
        if (MimeTypes.isVideo(mimeType)) {
            options = options.diskCacheStrategy(DiskCacheStrategy.RESOURCE);
            target = Glide.with(activity)
                    .asBitmap()
                    .apply(options)
                    .load(new VideoThumbnail(activity, uri))
                    .submit(width, height);
        } else {
            target = Glide.with(activity)
                    .asBitmap()
                    .apply(options)
                    .load(uri)
                    .submit(width, height);
        }

        try {
            Bitmap bitmap = target.get();
            if (MimeTypes.needRotationAfterGlide(mimeType)) {
                bitmap = BitmapUtils.applyExifOrientation(activity, bitmap, rotationDegrees, isFlipped);
            }
            return bitmap;
        } finally {
            Glide.with(activity).clear(target);
        }
    }

    @Override
    protected void onPostExecute(Result result) {
        Params params = result.params;
        MethodChannel.Result r = params.result;
        String uri = params.uri.toString();
        if (result.data != null) {
            r.success(result.data);
        } else {
            r.error("getThumbnail-null", "failed to get thumbnail for uri=" + uri, result.errorDetails);
        }
    }
}
