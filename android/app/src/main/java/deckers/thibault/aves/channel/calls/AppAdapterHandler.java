package deckers.thibault.aves.channel.calls;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Key;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.signature.ObjectKey;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static com.bumptech.glide.request.RequestOptions.centerCropTransform;

public class AppAdapterHandler implements MethodChannel.MethodCallHandler {
    private static final String LOG_TAG = Utils.createLogTag(AppAdapterHandler.class);

    public static final String CHANNEL = "deckers.thibault/aves/app";

    private Context context;

    public AppAdapterHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getAppIcon": {
                new Thread(() -> getAppIcon(call, new MethodResultWrapper(result))).start();
                break;
            }
            case "getAppNames": {
                result.success(getAppNames());
                break;
            }
            case "getEnv": {
                result.success(getEnv());
                break;
            }
            case "edit": {
                String title = call.argument("title");
                Uri uri = Uri.parse(call.argument("uri"));
                String mimeType = call.argument("mimeType");
                edit(title, uri, mimeType);
                result.success(null);
                break;
            }
            case "open": {
                String title = call.argument("title");
                Uri uri = Uri.parse(call.argument("uri"));
                String mimeType = call.argument("mimeType");
                open(title, uri, mimeType);
                result.success(null);
                break;
            }
            case "openMap": {
                Uri geoUri = Uri.parse(call.argument("geoUri"));
                openMap(geoUri);
                result.success(null);
                break;
            }
            case "setAs": {
                String title = call.argument("title");
                Uri uri = Uri.parse(call.argument("uri"));
                String mimeType = call.argument("mimeType");
                setAs(title, uri, mimeType);
                result.success(null);
                break;
            }
            case "share": {
                String title = call.argument("title");
                Map<String, List<String>> urisByMimeType = call.argument("urisByMimeType");
                shareMultiple(title, urisByMimeType);
                result.success(null);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private Map<String, String> getAppNames() {
        Map<String, String> nameMap = new HashMap<>();
        Intent intent = new Intent(Intent.ACTION_MAIN, null);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
        PackageManager packageManager = context.getPackageManager();
        List<ResolveInfo> resolveInfoList = packageManager.queryIntentActivities(intent, 0);
        for (ResolveInfo resolveInfo : resolveInfoList) {
            ApplicationInfo applicationInfo = resolveInfo.activityInfo.applicationInfo;
            boolean isSystemPackage = (applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM) != 0;
            if (!isSystemPackage) {
                String appName = String.valueOf(packageManager.getApplicationLabel(applicationInfo));
                nameMap.put(appName, applicationInfo.packageName);
            }
        }
        return nameMap;
    }

    private void getAppIcon(MethodCall call, MethodChannel.Result result) {
        String packageName = call.argument("packageName");
        Double sizeDip = call.argument("sizeDip");
        if (packageName == null || sizeDip == null) {
            result.error("getAppIcon-args", "failed because of missing arguments", null);
            return;
        }

        // convert DIP to physical pixels here, instead of using `devicePixelRatio` in Flutter
        float density = context.getResources().getDisplayMetrics().density;
        int size = (int) Math.round(sizeDip * density);

        byte[] data = null;
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
            } catch (Exception e) {
                Log.w(LOG_TAG, "failed to decode app icon for packageName=" + packageName, e);
            }
            Glide.with(context).clear(target);
        } catch (PackageManager.NameNotFoundException e) {
            Log.w(LOG_TAG, "failed to get app info for packageName=" + packageName, e);
            return;
        }
        if (data != null) {
            result.success(data);
        } else {
            result.error("getAppIcon-null", "failed to get icon for packageName=" + packageName, null);
        }
    }

    private Map<String, String> getEnv() {
        return System.getenv();
    }

    private void edit(String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_EDIT);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.setDataAndType(uri, mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }

    private void open(String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(uri, mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }

    private void openMap(Uri geoUri) {
        Intent intent = new Intent(Intent.ACTION_VIEW, geoUri);
        if (intent.resolveActivity(context.getPackageManager()) != null) {
            context.startActivity(intent);
        }
    }

    private void setAs(String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_ATTACH_DATA);
        intent.setDataAndType(uri, mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }

    private void shareSingle(String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        if (ContentResolver.SCHEME_FILE.equalsIgnoreCase(uri.getScheme())) {
            String path = uri.getPath();
            if (path == null) return;
            String applicationId = context.getApplicationContext().getPackageName();
            Uri apkUri = FileProvider.getUriForFile(context, applicationId + ".fileprovider", new File(path));
            intent.putExtra(Intent.EXTRA_STREAM, apkUri);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        } else {
            intent.putExtra(Intent.EXTRA_STREAM, uri);
        }
        intent.setType(mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }

    private void shareMultiple(String title, @Nullable Map<String, List<String>> urisByMimeType) {
        if (urisByMimeType == null) return;

        ArrayList<Uri> uriList = urisByMimeType.values().stream().flatMap(Collection::stream).map(Uri::parse).collect(Collectors.toCollection(ArrayList::new));
        String[] mimeTypes = urisByMimeType.keySet().toArray(new String[0]);

        // simplify share intent for a single item, as some apps can handle one item but not more
        if (uriList.size() == 1) {
            shareSingle(title, uriList.get(0), mimeTypes[0]);
            return;
        }

        String mimeType = "*/*";
        if (mimeTypes.length == 1) {
            // items have the same mime type & subtype
            mimeType = mimeTypes[0];
        } else {
            // items have different subtypes
            String[] mimeTypeTypes = Arrays.stream(mimeTypes).map(mt -> mt.split("/")[0]).distinct().toArray(String[]::new);
            if (mimeTypeTypes.length == 1) {
                // items have the same mime type
                mimeType = mimeTypeTypes[0] + "/*";
            }
        }

        Intent intent = new Intent(Intent.ACTION_SEND_MULTIPLE);
        intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList);
        intent.setType(mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }
}
