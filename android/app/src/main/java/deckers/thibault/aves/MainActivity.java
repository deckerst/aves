package deckers.thibault.aves;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import deckers.thibault.aves.channelhandlers.AppAdapterHandler;
import deckers.thibault.aves.channelhandlers.FileAdapterHandler;
import deckers.thibault.aves.channelhandlers.ImageFileHandler;
import deckers.thibault.aves.channelhandlers.MediaStoreStreamHandler;
import deckers.thibault.aves.channelhandlers.MetadataHandler;
import deckers.thibault.aves.utils.Constants;
import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.Utils;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {
    private static final String LOG_TAG = Utils.createLogTag(MainActivity.class);

    public static final String VIEWER_CHANNEL = "deckers.thibault/aves/viewer";

    private Map<String, String> sharedEntryMap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        handleIntent(getIntent());

        MediaStoreStreamHandler mediaStoreStreamHandler = new MediaStoreStreamHandler();

        FlutterView messenger = getFlutterView();
        new MethodChannel(messenger, FileAdapterHandler.CHANNEL).setMethodCallHandler(new FileAdapterHandler(this));
        new MethodChannel(messenger, AppAdapterHandler.CHANNEL).setMethodCallHandler(new AppAdapterHandler(this));
        new MethodChannel(messenger, ImageFileHandler.CHANNEL).setMethodCallHandler(new ImageFileHandler(this, mediaStoreStreamHandler));
        new MethodChannel(messenger, MetadataHandler.CHANNEL).setMethodCallHandler(new MetadataHandler(this));
        new EventChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandler(mediaStoreStreamHandler);

        new MethodChannel(messenger, VIEWER_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.contentEquals("getSharedEntry")) {
                        result.success(sharedEntryMap);
                        sharedEntryMap = null;
                    }
                });
    }

    private void handleIntent(Intent intent) {
        Log.i(LOG_TAG, "handleIntent intent=" + intent);
        if (intent != null && Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri uri = intent.getData();
            String mimeType = intent.getType();
            if (uri != null && mimeType != null) {
                sharedEntryMap = new HashMap<>();
                sharedEntryMap.put("uri", uri.toString());
                sharedEntryMap.put("mimeType", mimeType);
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == Constants.SD_CARD_PERMISSION_REQUEST_CODE && resultCode == RESULT_OK) {
            Uri sdCardDocumentUri = data.getData();
            if (sdCardDocumentUri == null) {
                return;
            }

            Env.setSdCardDocumentUri(this, sdCardDocumentUri.toString());

            // save access permissions across reboots
            final int takeFlags = data.getFlags()
                    & (Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            getContentResolver().takePersistableUriPermission(sdCardDocumentUri, takeFlags);

            // resume pending action
            PermissionManager.onPermissionGranted(requestCode);
        }
    }
}

