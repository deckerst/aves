import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class MediaEditService {
  String get newOpId;

  Future<void> cancelFileOp(String opId);

  Stream<ImageOpEvent> delete({
    String? opId,
    required Iterable<AvesEntry> entries,
  });

  Stream<MoveOpEvent> move({
    String? opId,
    required Map<String, Iterable<AvesEntry>> entriesByDestination,
    required bool copy,
    required NameConflictStrategy nameConflictStrategy,
  });

  Stream<ExportOpEvent> export(
    Iterable<AvesEntry> entries, {
    required EntryExportOptions options,
    required String destinationAlbum,
    required NameConflictStrategy nameConflictStrategy,
  });

  Stream<MoveOpEvent> rename({
    String? opId,
    required Map<AvesEntry, String> entriesToNewName,
  });

  Future<Map<String, dynamic>> captureFrame(
    AvesEntry entry, {
    required String desiredName,
    required Map<String, dynamic> exif,
    required Uint8List bytes,
    required String destinationAlbum,
    required NameConflictStrategy nameConflictStrategy,
  });
}

class PlatformMediaEditService implements MediaEditService {
  static const _platform = MethodChannel('deckers.thibault/aves/media_edit');
  static final _opStream = StreamsChannel('deckers.thibault/aves/media_op_stream');

  static Map<String, dynamic> _toPlatformEntryMap(AvesEntry entry) {
    return {
      'uri': entry.uri,
      'path': entry.path,
      'pageId': entry.pageId,
      'mimeType': entry.mimeType,
      'width': entry.width,
      'height': entry.height,
      'rotationDegrees': entry.rotationDegrees,
      'isFlipped': entry.isFlipped,
      'dateModifiedSecs': entry.dateModifiedSecs,
      'sizeBytes': entry.sizeBytes,
      'trashed': entry.trashed,
      'trashPath': entry.trashDetails?.path,
    };
  }

  @override
  String get newOpId => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future<void> cancelFileOp(String opId) async {
    try {
      await _platform.invokeMethod('cancelFileOp', <String, dynamic>{
        'opId': opId,
      });
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Stream<ImageOpEvent> delete({
    String? opId,
    required Iterable<AvesEntry> entries,
  }) {
    try {
      return _opStream
          .receiveBroadcastStream(<String, dynamic>{
            'op': 'delete',
            'id': opId,
            'entries': entries.map(_toPlatformEntryMap).toList(),
          })
          .where((event) => event is Map)
          .map((event) => ImageOpEvent.fromMap(event as Map));
    } on PlatformException catch (e, stack) {
      reportService.recordError(e, stack);
      return Stream.error(e);
    }
  }

  @override
  Stream<MoveOpEvent> move({
    String? opId,
    required Map<String, Iterable<AvesEntry>> entriesByDestination,
    required bool copy,
    required NameConflictStrategy nameConflictStrategy,
  }) {
    try {
      return _opStream
          .receiveBroadcastStream(<String, dynamic>{
            'op': 'move',
            'id': opId,
            'entriesByDestination': entriesByDestination.map((destination, entries) => MapEntry(destination, entries.map(_toPlatformEntryMap).toList())),
            'copy': copy,
            'nameConflictStrategy': nameConflictStrategy.toPlatform(),
          })
          .where((event) => event is Map)
          .map((event) => MoveOpEvent.fromMap(event as Map));
    } on PlatformException catch (e, stack) {
      reportService.recordError(e, stack);
      return Stream.error(e);
    }
  }

  @override
  Stream<ExportOpEvent> export(
    Iterable<AvesEntry> entries, {
    required EntryExportOptions options,
    required String destinationAlbum,
    required NameConflictStrategy nameConflictStrategy,
  }) {
    try {
      return _opStream
          .receiveBroadcastStream(<String, dynamic>{
            'op': 'export',
            'entries': entries.map(_toPlatformEntryMap).toList(),
            'mimeType': options.mimeType,
            'width': options.width,
            'height': options.height,
            'destinationPath': destinationAlbum,
            'nameConflictStrategy': nameConflictStrategy.toPlatform(),
          })
          .where((event) => event is Map)
          .map((event) => ExportOpEvent.fromMap(event as Map));
    } on PlatformException catch (e, stack) {
      reportService.recordError(e, stack);
      return Stream.error(e);
    }
  }

  @override
  Stream<MoveOpEvent> rename({
    String? opId,
    required Map<AvesEntry, String> entriesToNewName,
  }) {
    try {
      return _opStream
          .receiveBroadcastStream(<String, dynamic>{
            'op': 'rename',
            'id': opId,
            'entriesToNewName': entriesToNewName.map((key, value) => MapEntry(_toPlatformEntryMap(key), value)),
          })
          .where((event) => event is Map)
          .map((event) => MoveOpEvent.fromMap(event as Map));
    } on PlatformException catch (e, stack) {
      reportService.recordError(e, stack);
      return Stream.error(e);
    }
  }

  @override
  Future<Map<String, dynamic>> captureFrame(
    AvesEntry entry, {
    required String desiredName,
    required Map<String, dynamic> exif,
    required Uint8List bytes,
    required String destinationAlbum,
    required NameConflictStrategy nameConflictStrategy,
  }) async {
    try {
      final result = await _platform.invokeMethod('captureFrame', <String, dynamic>{
        'uri': entry.uri,
        'desiredName': desiredName,
        'exif': exif,
        'bytes': bytes,
        'destinationPath': destinationAlbum,
        'nameConflictStrategy': nameConflictStrategy.toPlatform(),
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    return {};
  }
}

@immutable
class EntryExportOptions extends Equatable {
  final String mimeType;
  final int width, height;

  @override
  List<Object?> get props => [mimeType, width, height];

  const EntryExportOptions({
    required this.mimeType,
    required this.width,
    required this.height,
  });
}
