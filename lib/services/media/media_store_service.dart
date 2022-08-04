import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class MediaStoreService {
  Future<List<int>> checkObsoleteContentIds(List<int?> knownContentIds);

  Future<List<int>> checkObsoletePaths(Map<int?, String?> knownPathById);

  // knownEntries: map of contentId -> dateModifiedSecs
  Stream<AvesEntry> getEntries(Map<int?, int?> knownEntries, {String? directory});

  // returns media URI
  Future<Uri?> scanFile(String path, String mimeType);
}

class PlatformMediaStoreService implements MediaStoreService {
  static const _platform = MethodChannel('deckers.thibault/aves/media_store');
  static final _stream = StreamsChannel('deckers.thibault/aves/media_store_stream');

  @override
  Future<List<int>> checkObsoleteContentIds(List<int?> knownContentIds) async {
    try {
      final result = await _platform.invokeMethod('checkObsoleteContentIds', <String, dynamic>{
        'knownContentIds': knownContentIds,
      });
      return (result as List).cast<int>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Future<List<int>> checkObsoletePaths(Map<int?, String?> knownPathById) async {
    try {
      final result = await _platform.invokeMethod('checkObsoletePaths', <String, dynamic>{
        'knownPathById': knownPathById,
      });
      return (result as List).cast<int>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return [];
  }

  @override
  Stream<AvesEntry> getEntries(Map<int?, int?> knownEntries, {String? directory}) {
    try {
      return _stream
          .receiveBroadcastStream(<String, dynamic>{
            'knownEntries': knownEntries,
            'directory': directory,
          })
          .where((event) => event is Map)
          .map((event) => AvesEntry.fromMap(event as Map));
    } on PlatformException catch (e, stack) {
      reportService.recordError(e, stack);
      return Stream.error(e);
    }
  }

  // returns media URI
  @override
  Future<Uri?> scanFile(String path, String mimeType) async {
    try {
      final result = await _platform.invokeMethod('scanFile', <String, dynamic>{
        'path': path,
        'mimeType': mimeType,
      });
      if (result != null) return Uri.tryParse(result);
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return null;
  }
}
