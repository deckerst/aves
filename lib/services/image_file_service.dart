import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/service_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

class ImageFileService {
  static const platform = MethodChannel('deckers.thibault/aves/image');
  static final StreamsChannel mediaStoreChannel = StreamsChannel('deckers.thibault/aves/mediastorestream');
  static final StreamsChannel byteChannel = StreamsChannel('deckers.thibault/aves/imagebytestream');
  static final StreamsChannel opChannel = StreamsChannel('deckers.thibault/aves/imageopstream');
  static const double thumbnailDefaultSize = 64.0;

  static Map<String, dynamic> _toPlatformEntryMap(ImageEntry entry) {
    return {
      'uri': entry.uri,
      'path': entry.path,
      'mimeType': entry.mimeType,
      'width': entry.width,
      'height': entry.height,
      'orientationDegrees': entry.orientationDegrees,
      'dateModifiedSecs': entry.dateModifiedSecs,
    };
  }

  // knownEntries: map of contentId -> dateModifiedSecs
  static Stream<ImageEntry> getImageEntries(Map<int, int> knownEntries) {
    try {
      return mediaStoreChannel.receiveBroadcastStream(<String, dynamic>{
        'knownEntries': knownEntries,
      }).map((event) => ImageEntry.fromMap(event));
    } on PlatformException catch (e) {
      debugPrint('getImageEntries failed with code=${e.code}, exception=${e.message}, details=${e.details}');
      return Stream.error(e);
    }
  }

  static Future<List> getObsoleteEntries(List<int> knownContentIds) async {
    try {
      final result = await platform.invokeMethod('getObsoleteEntries', <String, dynamic>{
        'knownContentIds': knownContentIds,
      });
      return (result as List).cast<int>();
    } on PlatformException catch (e) {
      debugPrint('getObsoleteEntries failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return [];
  }

  static Future<ImageEntry> getImageEntry(String uri, String mimeType) async {
    debugPrint('getImageEntry for uri=$uri, mimeType=$mimeType');
    try {
      final result = await platform.invokeMethod('getImageEntry', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      }) as Map;
      return ImageEntry.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('getImageEntry failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return null;
  }

  static Future<Uint8List> getImage(String uri, String mimeType, {int expectedContentLength, BytesReceivedCallback onBytesReceived}) {
    try {
      final completer = Completer<Uint8List>.sync();
      final sink = _OutputBuffer();
      var bytesReceived = 0;
      byteChannel.receiveBroadcastStream(<String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      }).listen(
        (data) {
          final chunk = data as Uint8List;
          sink.add(chunk);
          if (onBytesReceived != null) {
            bytesReceived += chunk.length;
            try {
              onBytesReceived(bytesReceived, expectedContentLength);
            } catch (error, stackTrace) {
              completer.completeError(error, stackTrace);
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

  static Future<Uint8List> getThumbnail(ImageEntry entry, double width, double height, {Object taskKey, int priority}) {
    return servicePolicy.call(
      () async {
        try {
          final result = await platform.invokeMethod('getThumbnail', <String, dynamic>{
            'entry': _toPlatformEntryMap(entry),
            'widthDip': width,
            'heightDip': height,
            'defaultSizeDip': thumbnailDefaultSize,
          });
          return result as Uint8List;
        } on PlatformException catch (e) {
          debugPrint('getThumbnail failed with code=${e.code}, exception=${e.message}, details=${e.details}');
        }
        return Uint8List(0);
      },
//      debugLabel: 'getThumbnail width=$width, height=$height entry=${entry.filenameWithoutExtension}',
      priority: priority ?? (width == 0 || height == 0 ? ServiceCallPriority.getFastThumbnail : ServiceCallPriority.getSizedThumbnail),
      key: taskKey,
    );
  }

  static Future<void> clearSizedThumbnailDiskCache() async {
    try {
      return platform.invokeMethod('clearSizedThumbnailDiskCache');
    } on PlatformException catch (e) {
      debugPrint('clearSizedThumbnailDiskCache failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
  }

  static bool cancelThumbnail(Object taskKey) => servicePolicy.pause(taskKey, [ServiceCallPriority.getFastThumbnail, ServiceCallPriority.getSizedThumbnail]);

  static Future<T> resumeThumbnail<T>(Object taskKey) => servicePolicy.resume<T>(taskKey);

  static Stream<ImageOpEvent> delete(Iterable<ImageEntry> entries) {
    try {
      return opChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'delete',
        'entries': entries.map(_toPlatformEntryMap).toList(),
      }).map((event) => ImageOpEvent.fromMap(event));
    } on PlatformException catch (e) {
      debugPrint('delete failed with code=${e.code}, exception=${e.message}, details=${e.details}');
      return Stream.error(e);
    }
  }

  static Stream<MoveOpEvent> move(Iterable<ImageEntry> entries, {@required bool copy, @required String destinationAlbum}) {
    debugPrint('move ${entries.length} entries');
    try {
      return opChannel.receiveBroadcastStream(<String, dynamic>{
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

  static Future<Map> rename(ImageEntry entry, String newName) async {
    try {
      // return map with: 'contentId' 'path' 'title' 'uri' (all optional)
      final result = await platform.invokeMethod('rename', <String, dynamic>{
        'entry': _toPlatformEntryMap(entry),
        'newName': newName,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('rename failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }

  static Future<Map> rotate(ImageEntry entry, {@required bool clockwise}) async {
    try {
      // return map with: 'width' 'height' 'orientationDegrees' (all optional)
      final result = await platform.invokeMethod('rotate', <String, dynamic>{
        'entry': _toPlatformEntryMap(entry),
        'clockwise': clockwise,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('rotate failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }
}

@immutable
class ImageOpEvent {
  final bool success;
  final String uri;

  const ImageOpEvent({
    this.success,
    this.uri,
  });

  factory ImageOpEvent.fromMap(Map map) {
    return ImageOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ImageOpEvent && other.success == success && other.uri == uri;
  }

  @override
  int get hashCode => hashValues('ImageOpEvent', success, uri);

  @override
  String toString() {
    return 'ImageOpEvent{success=$success, uri=$uri}';
  }
}

class MoveOpEvent extends ImageOpEvent {
  final Map newFields;

  const MoveOpEvent({bool success, String uri, this.newFields})
      : super(
          success: success,
          uri: uri,
        );

  factory MoveOpEvent.fromMap(Map map) {
    return MoveOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
      newFields: map['newFields'],
    );
  }

  @override
  String toString() {
    return 'MoveOpEvent{success=$success, uri=$uri, newFields=$newFields}';
  }
}

// cf flutter/foundation `consolidateHttpClientResponseBytes`
typedef BytesReceivedCallback = void Function(int cumulative, int total);

// cf flutter/foundation `consolidateHttpClientResponseBytes`
class _OutputBuffer extends ByteConversionSinkBase {
  List<List<int>> _chunks = <List<int>>[];
  int _contentLength = 0;
  Uint8List _bytes;

  @override
  void add(List<int> chunk) {
    assert(_bytes == null);
    _chunks.add(chunk);
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
    for (final chunk in _chunks) {
      _bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    _chunks = null;
  }

  Uint8List get bytes {
    assert(_bytes != null);
    return _bytes;
  }
}
