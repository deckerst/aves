package deckers.thibault.aves;

import android.os.Bundle;

import deckers.thibault.aves.channelhandlers.AppAdapterHandler;
import deckers.thibault.aves.channelhandlers.ImageDecodeHandler;
import deckers.thibault.aves.channelhandlers.MediaStoreStreamHandler;
import deckers.thibault.aves.channelhandlers.MetadataHandler;
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
        new MethodChannel(messenger, ImageDecodeHandler.CHANNEL).setMethodCallHandler(new ImageDecodeHandler(this, mediaStoreStreamHandler));
        new MethodChannel(messenger, MetadataHandler.CHANNEL).setMethodCallHandler(new MetadataHandler(this));
        new EventChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandler(mediaStoreStreamHandler);
    }
}

