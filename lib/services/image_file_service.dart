import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:aves/model/entry.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/services/output_buffer.dart';
import 'package:aves/services/service_policy.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class ImageFileService {
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

  Stream<ImageOpEvent> delete(Iterable<AvesEntry> entries);

  Stream<MoveOpEvent> move(
    Iterable<AvesEntry> entries, {
    required bool copy,
    required String destinationAlbum,
  });

  Stream<ExportOpEvent> export(
    Iterable<AvesEntry> entries, {
    required String mimeType,
    required String destinationAlbum,
  });

  Future<Map<String, dynamic>> captureFrame(
    AvesEntry entry, {
    required String desiredName,
    required Map<String, dynamic> exif,
    required Uint8List bytes,
    required String destinationAlbum,
  });

  Future<Map<String, dynamic>> rename(AvesEntry entry, String newName);

  Future<Map<String, dynamic>> rotate(AvesEntry entry, {required bool clockwise});

  Future<Map<String, dynamic>> flip(AvesEntry entry);
}

class PlatformImageFileService implements ImageFileService {
  static const platform = MethodChannel('deckers.thibault/aves/image');
  static final StreamsChannel _byteStreamChannel = StreamsChannel('deckers.thibault/aves/image_byte_stream');
  static final StreamsChannel _opStreamChannel = StreamsChannel('deckers.thibault/aves/image_op_stream');
  static const double thumbnailDefaultSize = 64.0;

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
    };
  }

  @override
  Future<AvesEntry?> getEntry(String uri, String? mimeType) async {
    try {
      final result = await platform.invokeMethod('getEntry', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      }) as Map;
      return AvesEntry.fromMap(result);
    } on PlatformException catch (e) {
      await reportService.recordChannelError('getEntry', e);
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
  }) {
    try {
      final completer = Completer<Uint8List>.sync();
      final sink = OutputBuffer();
      var bytesReceived = 0;
      _byteStreamChannel.receiveBroadcastStream(<String, dynamic>{
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
      return completer.future;
    } on PlatformException catch (e) {
      reportService.recordChannelError('getImage', e);
    }
    return Future.sync(() => Uint8List(0));
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
          final result = await platform.invokeMethod('getRegion', <String, dynamic>{
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
        } on PlatformException catch (e) {
          await reportService.recordChannelError('getRegion', e);
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
          final result = await platform.invokeMethod('getThumbnail', <String, dynamic>{
            'uri': uri,
            'mimeType': mimeType,
            'dateModifiedSecs': dateModifiedSecs,
            'rotationDegrees': rotationDegrees,
            'isFlipped': isFlipped,
            'widthDip': extent,
            'heightDip': extent,
            'pageId': pageId,
            'defaultSizeDip': thumbnailDefaultSize,
          });
          if (result != null) return result as Uint8List;
        } on PlatformException catch (e) {
          await reportService.recordChannelError('getThumbnail', e);
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
      return platform.invokeMethod('clearSizedThumbnailDiskCache');
    } on PlatformException catch (e) {
      await reportService.recordChannelError('clearSizedThumbnailDiskCache', e);
    }
  }

  @override
  bool cancelRegion(Object taskKey) => servicePolicy.pause(taskKey, [ServiceCallPriority.getRegion]);

  @override
  bool cancelThumbnail(Object taskKey) => servicePolicy.pause(taskKey, [ServiceCallPriority.getFastThumbnail, ServiceCallPriority.getSizedThumbnail]);

  @override
  Future<T>? resumeLoading<T>(Object taskKey) => servicePolicy.resume<T>(taskKey);

  @override
  Stream<ImageOpEvent> delete(Iterable<AvesEntry> entries) {
    try {
      return _opStreamChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'delete',
        'entries': entries.map(_toPlatformEntryMap).toList(),
      }).map((event) => ImageOpEvent.fromMap(event));
    } on PlatformException catch (e) {
      reportService.recordChannelError('delete', e);
      return Stream.error(e);
    }
  }

  @override
  Stream<MoveOpEvent> move(
    Iterable<AvesEntry> entries, {
    required bool copy,
    required String destinationAlbum,
  }) {
    try {
      return _opStreamChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'move',
        'entries': entries.map(_toPlatformEntryMap).toList(),
        'copy': copy,
        'destinationPath': destinationAlbum,
      }).map((event) => MoveOpEvent.fromMap(event));
    } on PlatformException catch (e) {
      reportService.recordChannelError('move', e);
      return Stream.error(e);
    }
  }

  @override
  Stream<ExportOpEvent> export(
    Iterable<AvesEntry> entries, {
    required String mimeType,
    required String destinationAlbum,
  }) {
    try {
      return _opStreamChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'export',
        'entries': entries.map(_toPlatformEntryMap).toList(),
        'mimeType': mimeType,
        'destinationPath': destinationAlbum,
      }).map((event) => ExportOpEvent.fromMap(event));
    } on PlatformException catch (e) {
      reportService.recordChannelError('export', e);
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
  }) async {
    try {
      final result = await platform.invokeMethod('captureFrame', <String, dynamic>{
        'uri': entry.uri,
        'desiredName': desiredName,
        'exif': exif,
        'bytes': bytes,
        'destinationPath': destinationAlbum,
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      await reportService.recordChannelError('captureFrame', e);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> rename(AvesEntry entry, String newName) async {
    try {
      // returns map with: 'contentId' 'path' 'title' 'uri' (all optional)
      final result = await platform.invokeMethod('rename', <String, dynamic>{
        'entry': _toPlatformEntryMap(entry),
        'newName': newName,
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      await reportService.recordChannelError('rename', e);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> rotate(AvesEntry entry, {required bool clockwise}) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await platform.invokeMethod('rotate', <String, dynamic>{
        'entry': _toPlatformEntryMap(entry),
        'clockwise': clockwise,
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      await reportService.recordChannelError('rotate', e);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> flip(AvesEntry entry) async {
    try {
      // returns map with: 'rotationDegrees' 'isFlipped'
      final result = await platform.invokeMethod('flip', <String, dynamic>{
        'entry': _toPlatformEntryMap(entry),
      });
      if (result != null) return (result as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      await reportService.recordChannelError('flip', e);
    }
    return {};
  }
}
