import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

class AndroidFileService {
  static const platform = MethodChannel('deckers.thibault/aves/storage');
  static final StreamsChannel storageAccessChannel = StreamsChannel('deckers.thibault/aves/storageaccessstream');

  static Future<List<Map>> getStorageVolumes() async {
    try {
      final result = await platform.invokeMethod('getStorageVolumes');
      return (result as List).cast<Map>();
    } on PlatformException catch (e) {
      debugPrint('getStorageVolumes failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return [];
  }

  static Future<bool> requireVolumeAccessDialog(String path) async {
    try {
      final result = await platform.invokeMethod('requireVolumeAccessDialog', <String, dynamic>{
        'path': path,
      });
      return result as bool;
    } on PlatformException catch (e) {
      debugPrint('requireVolumeAccessDialog failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return false;
  }

  // returns whether user granted access to volume root at `volumePath`
  static Future<bool> requestVolumeAccess(String volumePath) async {
    try {
      final completer = Completer<bool>();
      storageAccessChannel.receiveBroadcastStream(<String, dynamic>{
        'path': volumePath,
      }).listen(
        (data) => completer.complete(data as bool),
        onError: completer.completeError,
        onDone: () {
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );
      return completer.future;
    } on PlatformException catch (e) {
      debugPrint('requestVolumeAccess failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return false;
  }
}
