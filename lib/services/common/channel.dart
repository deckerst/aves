import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

class AvesMethodChannel extends MethodChannel {
  static bool kDebug = false;

  const AvesMethodChannel(super.name);

  @override
  Future<T?> invokeMethod<T>(String method, [arguments]) {
    if (kDebug) {
      debugPrint('$runtimeType platform call isolate=${Isolate.current.debugName} channel=$name method=$method arguments=$arguments');
    }
    return super.invokeMethod(method, arguments);
  }
}

class AvesStreamsChannel extends StreamsChannel {
  AvesStreamsChannel(super.name);

  @override
  Stream receiveBroadcastStream([arguments]) {
    if (AvesMethodChannel.kDebug) {
      debugPrint('$runtimeType platform call isolate=${Isolate.current.debugName} channel=$name arguments=$arguments');
    }
    return super.receiveBroadcastStream(arguments);
  }
}

class AvesChannels {
  static const geocoding = 'deckers.thibault/aves/geocoding';
  static const mediaSession = 'deckers.thibault/aves/media_session';
  static const metadataFetch = 'deckers.thibault/aves/metadata_fetch';

  static const _all = <MethodChannel>[
    AvesMethodChannel(geocoding),
    AvesMethodChannel(mediaSession),
    AvesMethodChannel(metadataFetch),
  ];

  static MethodChannel byName(String name) => _all.firstWhere((v) => v.name == name);
}
