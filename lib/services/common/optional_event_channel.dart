import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// adapted from Flutter `EventChannel` in `/services/platform_channel.dart`
// to use an `OptionalMethodChannel` when subscribing to events
class OptionalEventChannel extends EventChannel {
  const OptionalEventChannel(super.name, [super.codec = const StandardMethodCodec(), super.binaryMessenger]);

  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = OptionalMethodChannel(name, codec);
    late StreamController<dynamic> controller;
    controller = StreamController<dynamic>.broadcast(onListen: () async {
      binaryMessenger.setMessageHandler(name, (reply) async {
        if (reply == null) {
          await controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply));
          } on PlatformException catch (e) {
            controller.addError(e);
          }
        }
        return null;
      });
      try {
        await methodChannel.invokeMethod<void>('listen', arguments);
      } catch (error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'services library',
          context: ErrorDescription('while activating platform stream on channel $name'),
        ));
      }
    }, onCancel: () async {
      binaryMessenger.setMessageHandler(name, null);
      try {
        await methodChannel.invokeMethod<void>('cancel', arguments);
      } catch (error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'services library',
          context: ErrorDescription('while de-activating platform stream on channel $name'),
        ));
      }
    });
    return controller.stream;
  }
}
