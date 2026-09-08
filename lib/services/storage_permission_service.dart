import 'dart:async';

import 'package:aves/services/app_service.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/services.dart';

enum StorageApi { file, mediaStore, saf }

abstract class StoragePermissionService {
  Future<Map<VolumeRelativeDirectory, List<StorageApi>>> getEditionApis(Iterable<String> dirPaths, {required bool insertion});

  Future<VolumeRelativeDirectory?> getSafDirectoryToRequest(String dirPath);

  Future<List<String>> getSafGrantedDirectories();

  Future<void> revokeSafDirectoryAccess(String dirPath);

  // returns whether user granted access to a directory of his choosing
  Future<bool> requestSafMediaDirectoryAccess(String path);

  // returns a directory to which user granted access
  Future<String?> requestSafAnyDirectoryAccess();

  Future<bool> canRequestMediaStoreBulkAccess();

  // returns whether user granted access to URIs
  Future<bool> requestMediaStoreFileAccess(List<String> uris, List<String> mimeTypes);
}

class PlatformStoragePermissionService implements StoragePermissionService {
  static const _platform = AvesMethodChannel('deckers.thibault/aves/storage_permission');
  static final _stream = AvesStreamsChannel('deckers.thibault/aves/activity_result_stream');

  @override
  Future<Map<VolumeRelativeDirectory, List<StorageApi>>> getEditionApis(Iterable<String> dirPaths, {required bool insertion}) async {
    try {
      final result = await _platform.invokeMethod('getEditionApis', <String, Object?>{
        'dirPaths': dirPaths.toList(),
        'insertion': insertion,
      });
      if (result != null) {
        return Map.fromEntries(
          (result as List).cast<Map>().map((fields) {
            final dir = VolumeRelativeDirectory.fromMap((fields['dir'] as Map).cast<String, Object?>());
            final apis = (fields['apis'] as List).cast<String>().map(StorageApi.values.safeByName).nonNulls.toList();
            return MapEntry(dir, apis);
          }),
        );
      }
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }

  @override
  Future<VolumeRelativeDirectory?> getSafDirectoryToRequest(String dirPath) async {
    try {
      final result = await _platform.invokeMethod('getSafDirectoryToRequest', <String, Object?>{
        'dirPath': dirPath,
      });
      if (result != null) return VolumeRelativeDirectory.fromMap(result as Map);
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<List<String>> getSafGrantedDirectories() async {
    try {
      final result = await _platform.invokeMethod('getSafGrantedDirectories');
      return (result as List).cast<String>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Future<void> revokeSafDirectoryAccess(String dirPath) async {
    try {
      await _platform.invokeMethod('revokeSafDirectoryAccess', <String, Object?>{
        'dirPath': dirPath,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  // returns whether user granted access to a directory of his choosing
  @override
  Future<bool> requestSafMediaDirectoryAccess(String path) async {
    try {
      final opCompleter = Completer<bool>();
      _stream
          .receiveBroadcastStream(<String, Object?>{
            'op': 'requestSafMediaDirectoryAccess',
            'path': path,
          })
          .listen(
            (data) => opCompleter.complete(data as bool),
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

  // returns a directory to which user granted access
  @override
  Future<String?> requestSafAnyDirectoryAccess() async {
    try {
      final opCompleter = Completer<String?>();
      _stream
          .receiveBroadcastStream(<String, Object?>{
            'op': 'requestSafAnyDirectoryAccess',
          })
          .listen(
            (data) => opCompleter.complete(data as String?),
            onError: opCompleter.completeError,
            onDone: () {
              if (!opCompleter.isCompleted) opCompleter.complete(null);
            },
            cancelOnError: true,
          );
      // `await` here, so that `completeError` will be caught below
      return await opCompleter.future;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }

  @override
  Future<bool> canRequestMediaStoreBulkAccess() async {
    try {
      final result = await _platform.invokeMethod('canRequestMediaStoreBulkAccess');
      if (result != null) return result as bool;
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return false;
  }

  // returns whether user granted access to URIs
  @override
  Future<bool> requestMediaStoreFileAccess(List<String> uris, List<String> mimeTypes) async {
    try {
      final opCompleter = Completer<bool>();
      _stream
          .receiveBroadcastStream(<String, Object?>{
            'op': 'requestMediaStoreFileAccess',
            'uris': uris,
            'mimeTypes': mimeTypes,
          })
          .listen(
            (data) => opCompleter.complete(data as bool),
            onError: opCompleter.completeError,
            onDone: () {
              if (!opCompleter.isCompleted) opCompleter.complete(false);
            },
            cancelOnError: true,
          );
      // `await` here, so that `completeError` will be caught below
      return await opCompleter.future;
    } on PlatformException catch (e, stack) {
      if (e.code == 'requestMediaStoreFileAccess-large') {
        throw TooManyItemsException();
      } else {
        final message = e.message;
        // mute issue in the specific case when an item:
        // 1) is a Media Store `file` content,
        // 2) has no `images` or `video` entry,
        // 3) is in a restricted directory
        if (message == null || !message.contains('/external/file/')) {
          await reportService.recordError(e, stack);
        }
      }
    }
    return false;
  }
}
