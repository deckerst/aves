package deckers.thibault.aves.channelhandlers;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AppAdapterHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/app";

    private Context context;

    public AppAdapterHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "edit": {
                String title = call.argument("title");
                Uri uri = Uri.parse(call.argument("uri"));
                String mimeType = call.argument("mimeType");
                edit(title, uri, mimeType);
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
            case "showOnMap": {
                Uri geoUri = Uri.parse(call.argument("geoUri"));
                showOnMap(geoUri);
                result.success(null);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void edit(String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_EDIT);
        intent.setDataAndType(uri, mimeType);
        context.startActivity(Intent.createChooser(intent, title));
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

    private void showOnMap(Uri geoUri) {
        Intent intent = new Intent(Intent.ACTION_VIEW, geoUri);
        if (intent.resolveActivity(context.getPackageManager()) != null) {
            context.startActivity(intent);
        }
    }
}
