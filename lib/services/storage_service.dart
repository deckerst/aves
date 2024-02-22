import 'dart:async';

import 'package:aves/model/covers.dart';
import 'package:aves/services/common/output_buffer.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class StorageService {
  Future<Map<String, int>> getDataUsage();

  Future<Set<StorageVolume>> getStorageVolumes();

  Future<Set<String>> getUntrackedTrashPaths(Iterable<String> knownPaths);

  Future<Set<String>> getUntrackedVaultPaths(String vaultName, Iterable<String> knownPaths);

  Future<String> getVaultRoot();

  Future<int?> getFreeSpace(StorageVolume volume);

  Future<List<String>> getGrantedDirectories();

  Future<Set<VolumeRelativeDirectory>> getInaccessibleDirectories(Iterable<String> dirPaths);

  Future<Set<VolumeRelativeDirectory>> getRestrictedDirectories();

  Future<void> revokeDirectoryAccess(String path);

  // returns number of deleted directories
  Future<int> deleteEmptyRegularDirectories(Set<String> dirPaths);

  Future<bool> deleteTempDirectory();

  // returns whether user granted access to a directory of his choosing
  Future<bool> requestDirectoryAccess(String path);

  Future<bool> canRequestMediaFileBulkAccess();

  Future<bool> canInsertMedia(Set<VolumeRelativeDirectory> directories);

  // returns whether user granted access to URIs
  Future<bool> requestMediaFileAccess(List<String> uris, List<String> mimeTypes);

  // return whether operation succeeded (`null` if user cancelled)
  Future<bool?> createFile(String name, String mimeType, Uint8List bytes);

  Future<Uint8List> openFile([String? mimeType]);
}

class PlatformStorageService implements StorageService {
  static const _platform = MethodChannel('deckers.thibault/aves/storage');
  static final _stream = StreamsChannel('deckers.thibault/aves/activity_result_stream');

  @override
  Future<Map<String, int>> getDataUsage() async {
    try {
      final result = await _platform.invokeMethod('getDataUsage');
      if (result != null) return (result as Map).cast<String, int>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Set<StorageVolume>> getStorageVolumes() async {
    try {
      final result = await _platform.invokeMethod('getStorageVolumes');
      return (result as List).cast<Map>().map(StorageVolume.fromMap).toSet();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Set<String>> getUntrackedTrashPaths(Iterable<String> knownPaths) async {
    try {
      final result = await _platform.invokeMethod('getUntrackedTrashPaths', <String, dynamic>{
        'knownPaths': knownPaths.toList(),
      });
      return (result as List).cast<String>().toSet();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<Set<String>> getUntrackedVaultPaths(String vaultName, Iterable<String> knownPaths) async {
    try {
      final result = await _platform.invokeMethod('getUntrackedVaultPaths', <String, dynamic>{
        'vault': vaultName,
        'knownPaths': knownPaths.toList(),
      });
      return (result as List).cast<String>().toSet();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<String> getVaultRoot() async {
    try {
      final result = await _platform.invokeMethod('getVaultRoot');
      return result as String;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return '';
  }

  @override
  Future<int?> getFreeSpace(StorageVolume volume) async {
    try {
      final result = await _platform.invokeMethod('getFreeSpace', <String, dynamic>{
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
      final result = await _platform.invokeMethod('getGrantedDirectories');
      return (result as List).cast<String>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Future<Set<VolumeRelativeDirectory>> getInaccessibleDirectories(Iterable<String> dirPaths) async {
    try {
      final result = await _platform.invokeMethod('getInaccessibleDirectories', <String, dynamic>{
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
      final result = await _platform.invokeMethod('getRestrictedDirectories');
      if (result != null) {
        return (result as List).cast<Map>().map(VolumeRelativeDirectory.fromMap).toSet();
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<void> revokeDirectoryAccess(String path) async {
    try {
      await _platform.invokeMethod('revokeDirectoryAccess', <String, dynamic>{
        'path': path,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return;
  }

  // returns number of deleted directories
  @override
  Future<int> deleteEmptyRegularDirectories(Set<String> dirPaths) async {
    try {
      final result = await _platform.invokeMethod('deleteEmptyDirectories', <String, dynamic>{
        'dirPaths': dirPaths.where((v) => covers.effectiveAlbumType(v) == AlbumType.regular).toList(),
      });
      if (result != null) return result as int;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return 0;
  }

  @override
  Future<bool> deleteTempDirectory() async {
    try {
      final result = await _platform.invokeMethod('deleteTempDirectory');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<bool> canRequestMediaFileBulkAccess() async {
    try {
      final result = await _platform.invokeMethod('canRequestMediaFileBulkAccess');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<bool> canInsertMedia(Set<VolumeRelativeDirectory> directories) async {
    try {
      final result = await _platform.invokeMethod('canInsertMedia', <String, dynamic>{
        'directories': directories.map((v) => v.toMap()).toList(),
      });
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  // returns whether user granted access to a directory of his choosing
  @override
  Future<bool> requestDirectoryAccess(String path) async {
    try {
      final completer = Completer<bool>();
      _stream.receiveBroadcastStream(<String, dynamic>{
        'op': 'requestDirectoryAccess',
        'path': path,
      }).listen(
        (data) => completer.complete(data as bool),
        onError: completer.completeError,
        onDone: () {
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );
      // `await` here, so that `completeError` will be caught below
      return await completer.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  // returns whether user granted access to URIs
  @override
  Future<bool> requestMediaFileAccess(List<String> uris, List<String> mimeTypes) async {
    try {
      final completer = Completer<bool>();
      _stream.receiveBroadcastStream(<String, dynamic>{
        'op': 'requestMediaFileAccess',
        'uris': uris,
        'mimeTypes': mimeTypes,
      }).listen(
        (data) => completer.complete(data as bool),
        onError: completer.completeError,
        onDone: () {
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );
      // `await` here, so that `completeError` will be caught below
      return await completer.future;
    } on PlatformException catch (e, stack) {
      final message = e.message;
      // mute issue in the specific case when an item:
      // 1) is a Media Store `file` content,
      // 2) has no `images` or `video` entry,
      // 3) is in a restricted directory
      if (message == null || !message.contains('/external/file/')) {
        await reportService.recordError(e, stack);
      }
    }
    return false;
  }

  @override
  Future<bool?> createFile(String name, String mimeType, Uint8List bytes) async {
    try {
      final completer = Completer<bool?>();
      _stream.receiveBroadcastStream(<String, dynamic>{
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
      // `await` here, so that `completeError` will be caught below
      return await completer.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<Uint8List> openFile([String? mimeType]) async {
    try {
      final completer = Completer<Uint8List>.sync();
      final sink = OutputBuffer();
      _stream.receiveBroadcastStream(<String, dynamic>{
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
      // `await` here, so that `completeError` will be caught below
      return await completer.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return Uint8List(0);
  }
}
