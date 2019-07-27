package deckers.thibault.aves;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Key;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.signature.ObjectKey;
import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import deckers.thibault.aves.model.ImageEntry;
import deckers.thibault.aves.model.provider.MediaStoreImageProvider;
import deckers.thibault.aves.utils.Utils;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

class ThumbnailFetcher {
    private Activity activity;
    private HashMap<String, AsyncTask> taskMap = new HashMap<>();

    ThumbnailFetcher(Activity activity) {
        this.activity = activity;
    }

    void fetch(ImageEntry entry, Integer width, Integer height, Result result) {
        BitmapWorkerTask.MyTaskParams params = new BitmapWorkerTask.MyTaskParams(entry, width, height, result, this::complete);
        AsyncTask task = new BitmapWorkerTask(activity).execute(params);
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

public class MainActivity extends FlutterActivity {
    private static final String LOG_TAG = Utils.createLogTag(MainActivity.class);
    private static final String CHANNEL = "deckers.thibault.aves/mediastore";

    private ThumbnailFetcher thumbnailFetcher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        thumbnailFetcher = new ThumbnailFetcher(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "getImageEntries":
                            getPermissionResult(result, this);
                            break;
                        case "getOverlayMetadata":
                            String path = call.argument("path");
                            getOverlayMetadata(result, path);
                            break;
                        case "getImageBytes": {
                            Map map = call.argument("entry");
                            Integer width = call.argument("width");
                            Integer height = call.argument("height");
                            ImageEntry entry = new ImageEntry(map);
                            thumbnailFetcher.fetch(entry, width, height, result);
                            break;
                        }
                        case "cancelGetImageBytes": {
                            String uri = call.argument("uri");
                            thumbnailFetcher.cancel(uri);
                            // do not send `null`, as it closes the channel
                            result.success("");
                            break;
                        }
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

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
                        builder.setPositiveButton("OK", (dialog, id) -> {
                            dialog.cancel();
                            Intent intent = new Intent();
                            intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                            Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                            intent.setData(uri);
                            activity.startActivity(intent);
                        });
                        builder.setNegativeButton("Cancel", (dialog, id) -> dialog.cancel());
                        AlertDialog alert = builder.create();
                        alert.show();
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, final PermissionToken token) {
                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                        builder.setTitle("We need this permission");
                        builder.setCancelable(false);
                        builder.setPositiveButton("OK", (dialog, id) -> {
                            dialog.cancel();
                            token.continuePermissionRequest();
                        });
                        builder.setNegativeButton("Cancel", (dialog, id) -> {
                            dialog.cancel();
                            token.cancelPermissionRequest();
                        });
                        AlertDialog alert = builder.create();
                        alert.show();
                    }
                }).check();
    }

    List<Map> fetchAll(Activity activity) {
        return new MediaStoreImageProvider().fetchAll(activity).stream()
                .map(ImageEntry::toMap)
                .collect(Collectors.toList());
    }

    void getOverlayMetadata (Result result, String path) {
        try (InputStream is = new FileInputStream(path)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            ExifSubIFDDirectory directory = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
            Map<String, String> metadataMap = new HashMap<>();
            if (directory != null) {
                if (directory.containsTag(ExifSubIFDDirectory.TAG_FNUMBER)) {
                    metadataMap.put("aperture", directory.getDescription(ExifSubIFDDirectory.TAG_FNUMBER));
                }
                if (directory.containsTag(ExifSubIFDDirectory.TAG_EXPOSURE_TIME)) {
                    metadataMap.put("exposureTime", directory.getString(ExifSubIFDDirectory.TAG_EXPOSURE_TIME));
                }
                if (directory.containsTag(ExifSubIFDDirectory.TAG_FOCAL_LENGTH)) {
                    metadataMap.put("focalLength", directory.getDescription(ExifSubIFDDirectory.TAG_FOCAL_LENGTH));
                }
                if (directory.containsTag(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT)) {
                    metadataMap.put("iso", "ISO" + directory.getDescription(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT));
                }
            }
            result.success(metadataMap);
        } catch (FileNotFoundException e) {
            result.error("getOverlayMetadata-filenotfound", "failed to get metadata for path=" + path + " (" + e.getMessage() + ")", null);
        } catch (Exception e) {
            result.error("getOverlayMetadata-exception", "failed to get metadata for path=" + path, e);
        }
    }
}

class BitmapWorkerTask extends AsyncTask<BitmapWorkerTask.MyTaskParams, Void, BitmapWorkerTask.MyTaskResult> {
    private static final String LOG_TAG = Utils.createLogTag(BitmapWorkerTask.class);

    static class MyTaskParams {
        ImageEntry entry;
        int width, height;
        Result result;
        Consumer<String> complete;

        MyTaskParams(ImageEntry entry, int width, int height, Result result, Consumer<String> complete) {
            this.entry = entry;
            this.width = width;
            this.height = height;
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

    @SuppressLint("StaticFieldLeak")
    private Activity activity;

    BitmapWorkerTask(Activity activity) {
        this.activity = activity;
    }

    @Override
    protected MyTaskResult doInBackground(MyTaskParams... params) {
        MyTaskParams p = params[0];
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
        return new MyTaskResult(p, data);
    }

    @Override
    protected void onPostExecute(MyTaskResult result) {
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