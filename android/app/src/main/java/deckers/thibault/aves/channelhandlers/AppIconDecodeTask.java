package deckers.thibault.aves.channelhandlers;

import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Log;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Key;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.signature.ObjectKey;

import java.io.ByteArrayOutputStream;

import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.MethodChannel;

import static com.bumptech.glide.request.RequestOptions.centerCropTransform;

public class AppIconDecodeTask extends AsyncTask<AppIconDecodeTask.Params, Void, AppIconDecodeTask.Result> {
    private static final String LOG_TAG = Utils.createLogTag(AppIconDecodeTask.class);

    static class Params {
        Context context;
        String packageName;
        int size;
        MethodChannel.Result result;

        Params(Context context, String packageName, int size, MethodChannel.Result result) {
            this.context = context;
            this.packageName = packageName;
            this.size = size;
            this.result = result;
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

    @Override
    protected Result doInBackground(Params... params) {
        Params p = params[0];
        Context context = p.context;
        String packageName = p.packageName;
        int size = p.size;

        byte[] data = null;
        if (!this.isCancelled()) {
            try {
                int iconResourceId = context.getPackageManager().getApplicationInfo(packageName, 0).icon;
                Uri uri = new Uri.Builder()
                        .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                        .authority(packageName)
                        .path(String.valueOf(iconResourceId))
                        .build();

                // add signature to ignore cache for images which got modified but kept the same URI
                Key signature = new ObjectKey(packageName + size);
                RequestOptions options = new RequestOptions()
                        .signature(signature)
                        .override(size, size);

                FutureTarget<Bitmap> target = Glide.with(context)
                        .asBitmap()
                        .apply(options)
                        .apply(centerCropTransform())
                        .load(uri)
                        .signature(signature)
                        .submit(size, size);

                try {
                    Bitmap bmp = target.get();
                    if (bmp != null) {
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        bmp.compress(Bitmap.CompressFormat.PNG, 100, stream);
                        data = stream.toByteArray();
                    }
                } catch (InterruptedException e) {
                    Log.d(LOG_TAG, "getAppIcon with packageName=" + packageName + " interrupted");
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Glide.with(context).clear(target);
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        } else {
            Log.d(LOG_TAG, "getAppIcon with packageName=" + packageName + " cancelled");
        }
        return new Result(p, data);
    }

    @Override
    protected void onPostExecute(Result result) {
        MethodChannel.Result r = result.params.result;
        if (result.data != null) {
            r.success(result.data);
        } else {
            r.error("getAppIcon-null", "failed to get icon for packageName=" + result.params.packageName, null);
        }
    }
}
