import 'dart:async';

import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

class AndroidFileService {
  static const platform = MethodChannel('deckers.thibault/aves/storage');
  static final StreamsChannel storageAccessChannel = StreamsChannel('deckers.thibault/aves/storageaccessstream');

  static Future<Set<StorageVolume>> getStorageVolumes() async {
    try {
      final result = await platform.invokeMethod('getStorageVolumes');
      return (result as List).cast<Map>().map((map) => StorageVolume.fromMap(map)).toSet();
    } on PlatformException catch (e) {
      debugPrint('getStorageVolumes failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  static Future<int> getFreeSpace(StorageVolume volume) async {
    try {
      final result = await platform.invokeMethod('getFreeSpace', <String, dynamic>{
        'path': volume.path,
      });
      return result as int;
    } on PlatformException catch (e) {
      debugPrint('getFreeSpace failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return 0;
  }

  static Future<List<String>> getGrantedDirectories() async {
    try {
      final result = await platform.invokeMethod('getGrantedDirectories');
      return (result as List).cast<String>();
    } on PlatformException catch (e) {
      debugPrint('getGrantedDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return [];
  }

  static Future<void> revokeDirectoryAccess(String path) async {
    try {
      await platform.invokeMethod('revokeDirectoryAccess', <String, dynamic>{
        'path': path,
      });
    } on PlatformException catch (e) {
      debugPrint('revokeDirectoryAccess failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return;
  }

  static Future<Set<VolumeRelativeDirectory>> getInaccessibleDirectories(Iterable<String> dirPaths) async {
    try {
      final result = await platform.invokeMethod('getInaccessibleDirectories', <String, dynamic>{
        'dirPaths': dirPaths.toList(),
      });
      return (result as List).cast<Map>().map((map) => VolumeRelativeDirectory.fromMap(map)).toSet();
    } on PlatformException catch (e) {
      debugPrint('getInaccessibleDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return null;
  }

  static Future<Set<VolumeRelativeDirectory>> getRestrictedDirectories() async {
    try {
      final result = await platform.invokeMethod('getRestrictedDirectories');
      return (result as List).cast<Map>().map((map) => VolumeRelativeDirectory.fromMap(map)).toSet();
    } on PlatformException catch (e) {
      debugPrint('getRestrictedDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return null;
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

  // returns media URI
  static Future<Uri> scanFile(String path, String mimeType) async {
    debugPrint('scanFile with path=$path, mimeType=$mimeType');
    try {
      final uriString = await platform.invokeMethod('scanFile', <String, dynamic>{
        'path': path,
        'mimeType': mimeType,
      });
      return Uri.tryParse(uriString ?? '');
    } on PlatformException catch (e) {
      debugPrint('scanFile failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return null;
  }
}
