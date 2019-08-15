package deckers.thibault.aves;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import deckers.thibault.aves.channelhandlers.AppAdapterHandler;
import deckers.thibault.aves.channelhandlers.ImageFileHandler;
import deckers.thibault.aves.channelhandlers.MediaStoreStreamHandler;
import deckers.thibault.aves.channelhandlers.MetadataHandler;
import deckers.thibault.aves.utils.Constants;
import deckers.thibault.aves.utils.Env;
import deckers.thibault.aves.utils.PermissionManager;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        MediaStoreStreamHandler mediaStoreStreamHandler = new MediaStoreStreamHandler();

        FlutterView messenger = getFlutterView();
        new MethodChannel(messenger, AppAdapterHandler.CHANNEL).setMethodCallHandler(new AppAdapterHandler(this));
        new MethodChannel(messenger, ImageFileHandler.CHANNEL).setMethodCallHandler(new ImageFileHandler(this, mediaStoreStreamHandler));
        new MethodChannel(messenger, MetadataHandler.CHANNEL).setMethodCallHandler(new MetadataHandler(this));
        new EventChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandler(mediaStoreStreamHandler);
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

