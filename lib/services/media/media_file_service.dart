import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/output_buffer.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class MediaFileService {
  String get newOpId;

  Future<AvesEntry?> getEntry(String uri, String? mimeType);

  Future<Uint8List> getSvg(
    String uri,
    String mimeType, {
    int? expectedContentLength,
    BytesReceivedCallback? onBytesReceived,
  });

  Future<Uint8List> getImage(
    String uri,
    String mimeType,
    int? rotationDegrees,
    bool isFlipped, {
    int? pageId,
    int? expectedContentLength,
    BytesReceivedCallback? onBytesReceived,
  });

  // `rect`: region to decode, with coordinates in reference to `imageSize`
  Future<Uint8List> getRegion(
    String uri,
    String mimeType,
    int rotationDegrees,
    bool isFlipped,
    int sampleSize,
    Rectangle<int> regionRect,
    Size imageSize, {
    int? pageId,
    Object? taskKey,
    int? priority,
  });

  Future<Uint8List> getThumbnail({
    required String uri,
    required String mimeType,
    required int rotationDegrees,
    required int? pageId,
    required bool isFlipped,
    required int? dateModifiedSecs,
    required double extent,
    Object? taskKey,
    int? priority,
  });

  Future<void> clearSizedThumbnailDiskCache();

  bool cancelRegion(Object taskKey);

  bool cancelThumbnail(Object taskKey);

  Future<T>? resumeLoading<T>(Object taskKey);

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

class PlatformMediaFileService implements MediaFileService {
  static const _platform = MethodChannel('deckers.thibault/aves/media_file');
  static final _byteStream = StreamsChannel('deckers.thibault/aves/media_byte_stream');
  static final _opStream = StreamsChannel('deckers.thibault/aves/media_op_stream');
  static const double _thumbnailDefaultSize = 64.0;

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
  Future<AvesEntry?> getEntry(String uri, String? mimeType) async {
    try {
      final result = await _platform.invokeMethod('getEntry', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      }) as Map;
      return AvesEntry.fromMap(result);
    } on PlatformException catch (e, stack) {
      // do not report issues with simple parameter-less media content
      // as it is likely an obsolete Media Store entry
      if (!uri.startsWith('content://media/external/') || uri.contains('?')) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<Uint8List> getSvg(
    String uri,
    String mimeType, {
    int? expectedContentLength,
    BytesReceivedCallback? onBytesReceived,
  }) =>
      getImage(
        uri,
        mimeType,
        0,
        false,
        expectedContentLength: expectedContentLength,
        onBytesReceived: onBytesReceived,
      );

  @override
  Future<Uint8List> getImage(
    String uri,
    String mimeType,
    int? rotationDegrees,
    bool isFlipped, {
    int? pageId,
    int? expectedContentLength,
    BytesReceivedCallback? onBytesReceived,
  }) async {
    try {
      final completer = Completer<Uint8List>.sync();
      final sink = OutputBuffer();
      var bytesReceived = 0;
      _byteStream.receiveBroadcastStream(<String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
        'rotationDegrees': rotationDegrees ?? 0,
        'isFlipped': isFlipped,
        'pageId': pageId,
      }).listen(
        (data) {
          final chunk = data as Uint8List;
          sink.add(chunk);
          if (onBytesReceived != null) {
            bytesReceived += chunk.length;
            try {
              onBytesReceived(bytesReceived, expectedContentLength);
            } catch (error, stack) {
              completer.completeError(error, stack);
              return;
            }
          }
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
      if (!MimeTypes.knownMediaTypes.contains(mimeType) && MimeTypes.isVisual(mimeType)) {
        await reportService.recordError(e, stack);
      }
    }
    return Uint8List(0);
  }

  @override
  Future<Uint8List> getRegion(
    String uri,
    String mimeType,
    int rotationDegrees,
    bool isFlipped,
    int sampleSize,
    Rectangle<int> regionRect,
    Size imageSize, {
    int? pageId,
    Object? taskKey,
    int? priority,
  }) {
    return servicePolicy.call(
      () async {
        try {
          final result = await _platform.invokeMethod('getRegion', <String, dynamic>{
            'uri': uri,
            'mimeType': mimeType,
            'pageId': pageId,
            'sampleSize': sampleSize,
            'regionX': regionRect.left,
            'regionY': regionRect.top,
            'regionWidth': regionRect.width,
            'regionHeight': regionRect.height,
            'imageWidth': imageSize.width.toInt(),
            'imageHeight': imageSize.height.toInt(),
          });
          if (result != null) return result as Uint8List;
        } on PlatformException catch (e, stack) {
          if (!MimeTypes.knownMediaTypes.contains(mimeType) && MimeTypes.isVisual(mimeType)) {
            await reportService.recordError(e, stack);
          }
        }
        return Uint8List(0);
      },
      priority: priority ?? ServiceCallPriority.getRegion,
      key: taskKey,
    );
  }

  @override
  Future<Uint8List> getThumbnail({
    required String uri,
    required String mimeType,
    required int rotationDegrees,
    required int? pageId,
    required bool isFlipped,
    required int? dateModifiedSecs,
    required double extent,
    Object? taskKey,
    int? priority,
  }) {
    return servicePolicy.call(
      () async {
        try {
          final result = await _platform.invokeMethod('getThumbnail', <String, dynamic>{
            'uri': uri,
            'mimeType': mimeType,
            'dateModifiedSecs': dateModifiedSecs,
            'rotationDegrees': rotationDegrees,
            'isFlipped': isFlipped,
            'widthDip': extent,
            'heightDip': extent,
            'pageId': pageId,
            'defaultSizeDip': _thumbnailDefaultSize,
          });
          if (result != null) return result as Uint8List;
        } on PlatformException catch (e, stack) {
          if (!MimeTypes.knownMediaTypes.contains(mimeType) && MimeTypes.isVisual(mimeType)) {
            await reportService.recordError(e, stack);
          }
        }
        return Uint8List(0);
      },
      priority: priority ?? (extent == 0 ? ServiceCallPriority.getFastThumbnail : ServiceCallPriority.getSizedThumbnail),
      key: taskKey,
    );
  }

  @override
  Future<void> clearSizedThumbnailDiskCache() async {
    try {
      return _platform.invokeMethod('clearSizedThumbnailDiskCache');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  bool cancelRegion(Object taskKey) => servicePolicy.pause(taskKey, [ServiceCallPriority.getRegion]);

  @override
  bool cancelThumbnail(Object taskKey) => servicePolicy.pause(taskKey, [ServiceCallPriority.getFastThumbnail, ServiceCallPriority.getSizedThumbnail]);

  @override
  Future<T>? resumeLoading<T>(Object taskKey) => servicePolicy.resume<T>(taskKey);

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
