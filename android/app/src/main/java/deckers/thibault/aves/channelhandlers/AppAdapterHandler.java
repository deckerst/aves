package deckers.thibault.aves.channelhandlers;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.NonNull;

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
            case "share": {
                String title = call.argument("title");
                Uri uri = Uri.parse(call.argument("uri"));
                String mimeType = call.argument("mimeType");
                share(context, title, uri, mimeType);
                result.success(null);
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void share(Context context, String title, Uri uri, String mimeType) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_STREAM, uri);
        intent.setType(mimeType);
        context.startActivity(Intent.createChooser(intent, title));
    }
}
