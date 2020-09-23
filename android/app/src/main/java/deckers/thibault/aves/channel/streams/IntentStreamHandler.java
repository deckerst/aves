package deckers.thibault.aves.channel.streams;

import io.flutter.plugin.common.EventChannel;

public class IntentStreamHandler implements EventChannel.StreamHandler {
    private EventChannel.EventSink eventSink;

    @Override
    public void onListen(Object args, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object arguments) {
    }

    public void notifyNewIntent() {
        eventSink.success(true);
    }
}