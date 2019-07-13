package deckers.thibault.aves;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Log;
import android.util.Size;
import android.util.SparseArray;

import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collectors;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import deckers.thibault.aves.utils.Utils;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

class ThumbnailFetcher {
    private ContentResolver contentResolver;
    private SparseArray<AsyncTask> taskMap = new SparseArray<>();

    ThumbnailFetcher(ContentResolver contentResolver) {
        this.contentResolver = contentResolver;
    }

    void fetch (Integer id, Result result) {
        AsyncTask task = new BitmapWorkerTask(contentResolver).execute(new BitmapWorkerTask.MyTaskParams(id, result, this::complete));
        taskMap.append(id, task);
    }

    void cancel(Integer id) {
        AsyncTask task = taskMap.get(id, null);
        if (task != null) task.cancel(true);
        taskMap.remove(id);
    }

    void complete(Integer id) {
        taskMap.remove(id);
    }
}

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "deckers.thibault.aves/mediastore";

    private ThumbnailFetcher thumbnailFetcher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        thumbnailFetcher = new ThumbnailFetcher(getContentResolver());
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "getImages":
                            getPermissionResult(result, this);
                            break;
                        case "getThumbnail": {
                            Integer id = call.argument("id");
                            thumbnailFetcher.fetch(id, result);
                            break;
                        }
                        case "cancelGetThumbnail": {
                            Integer id = call.argument("id");
                            thumbnailFetcher.cancel(id);
                            result.success(null);
                            break;
                        }
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

//  public void getImageThumbnail(final Result result, String uri, int width, int height) {
//    // https://developer.android.com/reference/android/content/ContentResolver.html#loadThumbnail(android.net.Uri,%20android.util.Size,%20android.os.CancellationSignal)
//    try {
//      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//        Bitmap bmp = getContentResolver().loadThumbnail(Uri.parse(uri), new Size(width, height), null);
//        result.success(bmp);
//      } else {
//        // TODO get by mediastore
//        getContentResolver().
//      }
//    } catch (IOException e) {
//      e.printStackTrace();
//    }
//  }

    public void getPermissionResult(final Result result, final Activity activity) {
        Dexter.withActivity(activity)
                .withPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        result.success(fetchAll(activity));
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {

                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                        builder.setTitle("We need this permission");
                        builder.setCancelable(false);
                        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                                Intent intent = new Intent();
                                intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                                intent.setData(uri);
                                activity.startActivity(intent);

                            }
                        });
                        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
                        AlertDialog alert = builder.create();
                        alert.show();


                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, final PermissionToken token) {

                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                        builder.setTitle("We need this permission");
                        builder.setCancelable(false);
                        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                                token.continuePermissionRequest();

                            }
                        });
                        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                                token.cancelPermissionRequest();
                            }
                        });
                        AlertDialog alert = builder.create();
                        alert.show();
                    }
                }).check();
    }

    public List<Map> fetchAll(Activity activity) {
        return new MediaStoreImageProvider().fetchAll(activity).stream()
                .map(ImageEntry::toMap)
                .collect(Collectors.toList());
    }
}

class BitmapWorkerTask extends AsyncTask<BitmapWorkerTask.MyTaskParams, Void, BitmapWorkerTask.MyTaskResult> {
    private static final String LOG_TAG = Utils.createLogTag(BitmapWorkerTask.class);

    static class MyTaskParams {
        Integer id;
        Result result;
        Consumer<Integer> complete;

        MyTaskParams(Integer id, Result result, Consumer<Integer> complete) {
            this.id = id;
            this.result = result;
            this.complete = complete;
        }
    }

    static class MyTaskResult {
        MyTaskParams params;
        byte[] data;

        MyTaskResult(MyTaskParams params, byte[] data) {
            this.params = params;
            this.data = data;
        }
    }

    private ContentResolver cr;

    BitmapWorkerTask(ContentResolver cr) {
        this.cr = cr;
    }

    @Override
    protected MyTaskResult doInBackground(MyTaskParams... params) {
        MyTaskParams p = params[0];
        byte[] data = null;
        if (!this.isCancelled()) {
            Log.d(LOG_TAG, "getThumbnail with id=" + p.id + "(called)");
            Bitmap bmp = MediaStore.Images.Thumbnails.getThumbnail(cr, p.id, MediaStore.Images.Thumbnails.MINI_KIND, null);
            if (bmp != null) {
                ByteArrayOutputStream stream = new ByteArrayOutputStream();
                bmp.compress(Bitmap.CompressFormat.JPEG, 90, stream);
                data = stream.toByteArray();
            }
        } else {
            Log.d(LOG_TAG, "getThumbnail with id=" + p.id + "(cancelled)");
        }
        return new MyTaskResult(p, data);
    }

    @Override
    protected void onPostExecute(MyTaskResult result) {
        MethodChannel.Result r = result.params.result;
        result.params.complete.accept(result.params.id);
        if (result.data != null) {
            r.success(result.data);
        } else {
            r.error("getthumbnail-null", "failed to get thumbnail for id=" + result.params.id, null);
        }
    }
}