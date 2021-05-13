import 'dart:async';

import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:streams_channel/streams_channel.dart';

abstract class StorageService {
  Future<Set<StorageVolume>> getStorageVolumes();

  Future<int?> getFreeSpace(StorageVolume volume);

  Future<List<String>> getGrantedDirectories();

  Future<void> revokeDirectoryAccess(String path);

  Future<Set<VolumeRelativeDirectory>> getInaccessibleDirectories(Iterable<String> dirPaths);

  Future<Set<VolumeRelativeDirectory>> getRestrictedDirectories();

  // returns whether user granted access to volume root at `volumePath`
  Future<bool> requestVolumeAccess(String volumePath);

  // returns number of deleted directories
  Future<int> deleteEmptyDirectories(Iterable<String> dirPaths);

  // returns media URI
  Future<Uri?> scanFile(String path, String mimeType);
}

class PlatformStorageService implements StorageService {
  static const platform = MethodChannel('deckers.thibault/aves/storage');
  static final StreamsChannel storageAccessChannel = StreamsChannel('deckers.thibault/aves/storageaccessstream');

  @override
  Future<Set<StorageVolume>> getStorageVolumes() async {
    try {
      final result = await platform.invokeMethod('getStorageVolumes');
      return (result as List).cast<Map>().map((map) => StorageVolume.fromMap(map)).toSet();
    } on PlatformException catch (e) {
      debugPrint('getStorageVolumes failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  @override
  Future<int?> getFreeSpace(StorageVolume volume) async {
    try {
      final result = await platform.invokeMethod('getFreeSpace', <String, dynamic>{
        'path': volume.path,
      });
      return result as int?;
    } on PlatformException catch (e) {
      debugPrint('getFreeSpace failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return null;
  }

  @override
  Future<List<String>> getGrantedDirectories() async {
    try {
      final result = await platform.invokeMethod('getGrantedDirectories');
      return (result as List).cast<String>();
    } on PlatformException catch (e) {
      debugPrint('getGrantedDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return [];
  }

  @override
  Future<void> revokeDirectoryAccess(String path) async {
    try {
      await platform.invokeMethod('revokeDirectoryAccess', <String, dynamic>{
        'path': path,
      });
    } on PlatformException catch (e) {
      debugPrint('revokeDirectoryAccess failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return;
  }

  @override
  Future<Set<VolumeRelativeDirectory>> getInaccessibleDirectories(Iterable<String> dirPaths) async {
    try {
      final result = await platform.invokeMethod('getInaccessibleDirectories', <String, dynamic>{
        'dirPaths': dirPaths.toList(),
      });
      if (result != null) {
        return (result as List).cast<Map>().map(VolumeRelativeDirectory.fromMap).toSet();
      }
    } on PlatformException catch (e) {
      debugPrint('getInaccessibleDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  @override
  Future<Set<VolumeRelativeDirectory>> getRestrictedDirectories() async {
    try {
      final result = await platform.invokeMethod('getRestrictedDirectories');
      if (result != null) {
        return (result as List).cast<Map>().map(VolumeRelativeDirectory.fromMap).toSet();
      }
    } on PlatformException catch (e) {
      debugPrint('getRestrictedDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return {};
  }

  // returns whether user granted access to volume root at `volumePath`
  @override
  Future<bool> requestVolumeAccess(String volumePath) async {
    try {
      final completer = Completer<bool>();
      storageAccessChannel.receiveBroadcastStream(<String, dynamic>{
        'path': volumePath,
      }).listen(
        (data) => completer.complete(data as bool?),
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

  // returns number of deleted directories
  @override
  Future<int> deleteEmptyDirectories(Iterable<String> dirPaths) async {
    try {
      final result = await platform.invokeMethod('deleteEmptyDirectories', <String, dynamic>{
        'dirPaths': dirPaths.toList(),
      });
      if (result != null) return result as int;
    } on PlatformException catch (e) {
      debugPrint('deleteEmptyDirectories failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return 0;
  }

  // returns media URI
  @override
  Future<Uri?> scanFile(String path, String mimeType) async {
    debugPrint('scanFile with path=$path, mimeType=$mimeType');
    try {
      final result = await platform.invokeMethod('scanFile', <String, dynamic>{
        'path': path,
        'mimeType': mimeType,
      });
      if (result != null) return Uri.tryParse(result);
    } on PlatformException catch (e) {
      debugPrint('scanFile failed with code=${e.code}, exception=${e.message}, details=${e.details}}');
    }
    return null;
  }
}
