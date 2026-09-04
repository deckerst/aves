import 'dart:async';

import 'package:aves/model/covers.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/output_buffer.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/services.dart';

abstract class StorageService {
  Future<Map<String, int>> getDataUsage();

  Future<Set<StorageVolume>> getStorageVolumes();

  Future<String> getExternalCacheDirectory();

  Future<Set<String>> getUntrackedTrashPaths(Iterable<String> knownPaths);

  Future<Set<String>> getUntrackedVaultPaths(String vaultName, Iterable<String> knownPaths);

  Future<String> getVaultRoot();

  Future<int?> getFreeSpace(StorageVolume volume);

  // returns number of deleted directories
  Future<int> deleteEmptyRegularDirectories(Set<String> dirPaths);

  Future<bool> deleteTempDirectory();

  Future<bool> deleteExternalCache();

  // save provided content to a user selected file
  // skip user interaction if `dirPath` is provided
  // returns whether operation succeeded (`null` if user cancelled)
  Future<bool?> createFile({
    String? dirPath,
    required String basename,
    required String mimeType,
    required Uint8List bytes,
    bool reportErrors,
  });

  // return content from a user selected file
  Future<Uint8List> openFile([String? mimeType]);

  // copy provided file to a user selected file
  // returns whether operation succeeded (`null` if user cancelled)
  Future<bool?> copyFile({
    required String basename,
    required String mimeType,
    required String sourceUri,
  });
}

class PlatformStorageService implements StorageService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/storage');
  static final _stream = AvesStreamsChannel('deckers.thibault/aves/activity_result_stream');

  @override
  Future<Map<String, int>> getDataUsage() async {
    try {
      final result = await _platform.invokeMethod('getDataUsage');
      if (result is Map) return result.cast<String, int>();
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
  Future<String> getExternalCacheDirectory() async {
    try {
      final result = await _platform.invokeMethod('getCacheDirectory', <String, Object?>{
        'external': true,
      });
      return result as String;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return '';
  }

  @override
  Future<Set<String>> getUntrackedTrashPaths(Iterable<String> knownPaths) async {
    try {
      final result = await _platform.invokeMethod('getUntrackedTrashPaths', <String, Object?>{
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
      final result = await _platform.invokeMethod('getUntrackedVaultPaths', <String, Object?>{
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
      final result = await _platform.invokeMethod('getFreeSpace', <String, Object?>{
        'path': volume.path,
      });
      return result as int?;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  // returns number of deleted directories
  @override
  Future<int> deleteEmptyRegularDirectories(Set<String> dirPaths) async {
    try {
      final result = await _platform.invokeMethod('deleteEmptyDirectories', <String, Object?>{
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
  Future<bool> deleteExternalCache() async {
    try {
      final result = await _platform.invokeMethod('deleteExternalCache');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  @override
  Future<bool?> createFile({
    String? dirPath,
    required String basename,
    required String mimeType,
    required Uint8List bytes,
    bool reportErrors = true,
  }) async {
    try {
      final opCompleter = Completer<bool?>();
      _stream
          .receiveBroadcastStream(<String, Object?>{
            'op': 'createFile',
            'dirPath': dirPath,
            'name': '$basename${MimeTypes.extensionFor(mimeType)}',
            'mimeType': mimeType,
            'bytes': bytes,
          })
          .listen(
            (data) => opCompleter.complete(data as bool?),
            onError: opCompleter.completeError,
            onDone: () {
              if (!opCompleter.isCompleted) opCompleter.complete(false);
            },
            cancelOnError: true,
          );
      // `await` here, so that `completeError` will be caught below
      return await opCompleter.future;
    } on PlatformException catch (e, stack) {
      if (reportErrors) {
        await reportService.recordError(e, stack);
      }
    }
    return false;
  }

  @override
  Future<Uint8List> openFile([String? mimeType]) async {
    try {
      final opCompleter = Completer<Uint8List>();
      final sink = OutputBuffer();
      _stream
          .receiveBroadcastStream(<String, Object?>{
            'op': 'openFile',
            'mimeType': mimeType,
          })
          .listen(
            (data) {
              final chunk = data as Uint8List;
              sink.add(chunk);
            },
            onError: opCompleter.completeError,
            onDone: () {
              sink.close();
              opCompleter.complete(sink.bytes);
            },
            cancelOnError: true,
          );
      // `await` here, so that `completeError` will be caught below
      return await opCompleter.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return Uint8List(0);
  }

  @override
  Future<bool?> copyFile({
    required String basename,
    required String mimeType,
    required String sourceUri,
  }) async {
    try {
      final opCompleter = Completer<bool?>();
      _stream
          .receiveBroadcastStream(<String, Object?>{
            'op': 'copyFile',
            'name': '$basename${MimeTypes.extensionFor(mimeType)}',
            'mimeType': mimeType,
            'sourceUri': sourceUri,
          })
          .listen(
            (data) => opCompleter.complete(data as bool?),
            onError: opCompleter.completeError,
            onDone: () {
              if (!opCompleter.isCompleted) opCompleter.complete(false);
            },
            cancelOnError: true,
          );
      // `await` here, so that `completeError` will be caught below
      return await opCompleter.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }
}
