import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves_model/aves_model.dart';
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
    required EntryConvertOptions options,
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
            'entries': entries.map((entry) => entry.toPlatformEntryMap()).toList(),
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
            'entriesByDestination': entriesByDestination.map((destination, entries) => MapEntry(destination, entries.map((entry) => entry.toPlatformEntryMap()).toList())),
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
    required EntryConvertOptions options,
    required String destinationAlbum,
    required NameConflictStrategy nameConflictStrategy,
  }) {
    try {
      return _opStream
          .receiveBroadcastStream(<String, dynamic>{
            'op': 'convert',
            'entries': entries.map((entry) => entry.toPlatformEntryMap()).toList(),
            'mimeType': options.mimeType,
            'quality': options.quality,
            'lengthUnit': options.lengthUnit.name,
            'width': options.width,
            'height': options.height,
            'writeMetadata': options.writeMetadata,
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
            'entriesToNewName': entriesToNewName.map((entry, name) => MapEntry(entry.toPlatformEntryMap(), name)),
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
class EntryConvertOptions extends Equatable {
  final EntryConvertAction action;
  final String mimeType;
  final bool writeMetadata;
  final LengthUnit lengthUnit;
  final int width, height, quality;

  @override
  List<Object?> get props => [action, mimeType, writeMetadata, lengthUnit, width, height, quality];

  const EntryConvertOptions({
    required this.action,
    required this.mimeType,
    required this.writeMetadata,
    required this.lengthUnit,
    required this.width,
    required this.height,
    required this.quality,
  });
}
