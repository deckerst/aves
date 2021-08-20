import 'dart:async';
import 'dart:typed_data';

import 'package:aves/services/output_buffer.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  // return whether operation succeeded (`null` if user cancelled)
  Future<bool?> createFile(String name, String mimeType, Uint8List bytes);

  Future<Uint8List> openFile(String mimeType);

  Future<String?> selectDirectory();
}

class PlatformStorageService implements StorageService {
  static const platform = MethodChannel('deckers.thibault/aves/storage');
  static final StreamsChannel storageAccessChannel = StreamsChannel('deckers.thibault/aves/storage_access_stream');

  @override
  Future<Set<StorageVolume>> getStorageVolumes() async {
    try {
      final result = await platform.invokeMethod('getStorageVolumes');
      return (result as List).cast<Map>().map((map) => StorageVolume.fromMap(map)).toSet();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<List<String>> getGrantedDirectories() async {
    try {
      final result = await platform.invokeMethod('getGrantedDirectories');
      return (result as List).cast<String>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Future<void> revokeDirectoryAccess(String path) async {
    try {
      await platform.invokeMethod('revokeDirectoryAccess', <String, dynamic>{
        'path': path,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  // returns whether user granted access to volume root at `volumePath`
  @override
  Future<bool> requestVolumeAccess(String volumePath) async {
    try {
      final completer = Completer<bool>();
      storageAccessChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'requestVolumeAccess',
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
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
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<bool?> createFile(String name, String mimeType, Uint8List bytes) async {
    try {
      final completer = Completer<bool?>();
      storageAccessChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'createFile',
        'name': name,
        'mimeType': mimeType,
        'bytes': bytes,
      }).listen(
        (data) => completer.complete(data as bool?),
        onError: completer.completeError,
        onDone: () {
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );
      return completer.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<Uint8List> openFile(String mimeType) async {
    try {
      final completer = Completer<Uint8List>.sync();
      final sink = OutputBuffer();
      storageAccessChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'openFile',
        'mimeType': mimeType,
      }).listen(
        (data) {
          final chunk = data as Uint8List;
          sink.add(chunk);
        },
        onError: completer.completeError,
        onDone: () {
          sink.close();
          completer.complete(sink.bytes);
        },
        cancelOnError: true,
      );
      return completer.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return Uint8List(0);
  }

  @override
  Future<String?> selectDirectory() async {
    try {
      final completer = Completer<String?>();
      storageAccessChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'selectDirectory',
      }).listen(
        (data) => completer.complete(data as String?),
        onError: completer.completeError,
        onDone: () {
          if (!completer.isCompleted) completer.complete(null);
        },
        cancelOnError: true,
      );
      return completer.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }
}
