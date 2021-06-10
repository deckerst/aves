import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/image_op_events.dart';
import 'package:aves/services/service_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// ignore: import_of_legacy_library_into_null_safe
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

  Future<Map<String, dynamic>> rename(AvesEntry entry, String newName);

  Future<Map<String, dynamic>> rotate(AvesEntry entry, {required bool clockwise});

  Future<Map<String, dynamic>> flip(AvesEntry entry);
}

class PlatformImageFileService implements ImageFileService {
  static const platform = MethodChannel('deckers.thibault/aves/image');
  static final StreamsChannel _byteStreamChannel = StreamsChannel('deckers.thibault/aves/imagebytestream');
  static final StreamsChannel _opStreamChannel = StreamsChannel('deckers.thibault/aves/imageopstream');
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
      debugPrint('getEntry failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      final sink = _OutputBuffer();
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
      debugPrint('getImage failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
          debugPrint('getRegion failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
    if (mimeType == MimeTypes.svg) {
      return Future.sync(() => Uint8List(0));
    }
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
          debugPrint('getThumbnail failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      debugPrint('clearSizedThumbnailDiskCache failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      debugPrint('delete failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      debugPrint('move failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      debugPrint('export failed with code=${e.code}, exception=${e.message}, details=${e.details}');
      return Stream.error(e);
    }
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
      debugPrint('rename failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      debugPrint('rotate failed with code=${e.code}, exception=${e.message}, details=${e.details}');
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
      debugPrint('flip failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }
}

// cf flutter/foundation `consolidateHttpClientResponseBytes`
typedef BytesReceivedCallback = void Function(int cumulative, int? total);

// cf flutter/foundation `consolidateHttpClientResponseBytes`
class _OutputBuffer extends ByteConversionSinkBase {
  List<List<int>>? _chunks = <List<int>>[];
  int _contentLength = 0;
  Uint8List? _bytes;

  @override
  void add(List<int> chunk) {
    assert(_bytes == null);
    _chunks!.add(chunk);
    _contentLength += chunk.length;
  }

  @override
  void close() {
    if (_bytes != null) {
      // We've already been closed; this is a no-op
      return;
    }
    _bytes = Uint8List(_contentLength);
    var offset = 0;
    for (final chunk in _chunks!) {
      _bytes!.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    _chunks = null;
  }

  Uint8List get bytes {
    assert(_bytes != null);
    return _bytes!;
  }
}
