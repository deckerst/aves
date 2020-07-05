package deckers.thibault.aves;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import app.loup.streams_channel.StreamsChannel;
import deckers.thibault.aves.channel.calls.AppAdapterHandler;
import deckers.thibault.aves.channel.calls.ImageFileHandler;
import deckers.thibault.aves.channel.calls.MetadataHandler;
import deckers.thibault.aves.channel.calls.StorageHandler;
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler;
import deckers.thibault.aves.channel.streams.ImageOpStreamHandler;
import deckers.thibault.aves.channel.streams.MediaStoreStreamHandler;
import deckers.thibault.aves.channel.streams.StorageAccessStreamHandler;
import deckers.thibault.aves.utils.PermissionManager;
import deckers.thibault.aves.utils.Utils;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String LOG_TAG = Utils.createLogTag(MainActivity.class);

    public static final String VIEWER_CHANNEL = "deckers.thibault/aves/viewer";

    private Map<String, String> intentDataMap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        handleIntent(getIntent());

        BinaryMessenger messenger = Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger();

        new MethodChannel(messenger, AppAdapterHandler.CHANNEL).setMethodCallHandler(new AppAdapterHandler(this));
        new MethodChannel(messenger, ImageFileHandler.CHANNEL).setMethodCallHandler(new ImageFileHandler(this));
        new MethodChannel(messenger, MetadataHandler.CHANNEL).setMethodCallHandler(new MetadataHandler(this));
        new MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(new StorageHandler(this));

        new StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory(args -> new ImageByteStreamHandler(this, args));
        new StreamsChannel(messenger, ImageOpStreamHandler.CHANNEL).setStreamHandlerFactory(args -> new ImageOpStreamHandler(this, args));
        new StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory(args -> new MediaStoreStreamHandler(this, args));
        new StreamsChannel(messenger, StorageAccessStreamHandler.CHANNEL).setStreamHandlerFactory(args -> new StorageAccessStreamHandler(this, args));

        new MethodChannel(messenger, VIEWER_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.contentEquals("getIntentData")) {
                        result.success(intentDataMap);
                        intentDataMap = null;
                    } else if (call.method.contentEquals("pick")) {
                        result.success(intentDataMap);
                        intentDataMap = null;
                        String resultUri = call.argument("uri");
                        if (resultUri != null) {
                            Intent intent = new Intent();
                            intent.setData(Uri.parse(resultUri));
                            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                            setResult(RESULT_OK, intent);
                        } else {
                            setResult(RESULT_CANCELED);
                        }
                        finish();
                    }
                });
    }

    private void handleIntent(Intent intent) {
        Log.i(LOG_TAG, "handleIntent intent=" + intent);
        if (intent == null) return;
        String action = intent.getAction();
        if (action == null) return;
        switch (action) {
            case Intent.ACTION_VIEW:
                Uri uri = intent.getData();
                String mimeType = intent.getType();
                if (uri != null && mimeType != null) {
                    intentDataMap = new HashMap<>();
                    intentDataMap.put("action", "view");
                    intentDataMap.put("uri", uri.toString());
                    intentDataMap.put("mimeType", mimeType);
                }
                break;
            case Intent.ACTION_GET_CONTENT:
            case Intent.ACTION_PICK:
                intentDataMap = new HashMap<>();
                intentDataMap.put("action", "pick");
                intentDataMap.put("mimeType", intent.getType());
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PermissionManager.VOLUME_ROOT_PERMISSION_REQUEST_CODE) {
            if (resultCode != RESULT_OK || data.getData() == null) {
                PermissionManager.onPermissionResult(this, requestCode, false, null);
                return;
            }

            Uri treeUri = data.getData();

            // save access permissions across reboots
            final int takeFlags = data.getFlags()
                    & (Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            getContentResolver().takePersistableUriPermission(treeUri, takeFlags);

            // resume pending action
            PermissionManager.onPermissionResult(this, requestCode, true, treeUri);
        }
    }
}

