package deckers.thibault.aves.channelhandlers;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import deckers.thibault.aves.utils.Utils;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AppAdapterHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/app";

    private static final String LOG_TAG = Utils.createLogTag(AppAdapterHandler.class);

    private Context context;

    public AppAdapterHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d(LOG_TAG, "onMethodCall method=" + call.method + ", arguments=" + call.arguments);
        switch (call.method) {
            case "getAppNames": {
                result.success(getAppNames());
                break;
            }
            case "getAppIcon": {
                String packageName = call.argument("packageName");
                Integer size = call.argument("size");
                if (packageName == null || size == null) {
                    result.error("getAppIcon-args", "failed because of missing arguments", null);
                    return;
                }
                getAppIcon(packageName, size, result);
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
                Uri uri = Uri.parse(call.argument("uri"));
                String mimeType = call.argument("mimeType");
                share(title, uri, mimeType);
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

    private void getAppIcon(String packageName, int size, MethodChannel.Result result) {
        new AppIconDecodeTask().execute(new AppIconDecodeTask.Params(context, packageName, size, result));
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

    private void share(String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_STREAM, uri);
        intent.setType(mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }
}
