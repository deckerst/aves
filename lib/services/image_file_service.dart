import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/service_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

class ImageFileService {
  static const platform = MethodChannel('deckers.thibault/aves/image');
  static final StreamsChannel byteChannel = StreamsChannel('deckers.thibault/aves/imagebytestream');
  static final StreamsChannel opChannel = StreamsChannel('deckers.thibault/aves/imageopstream');

  static const thumbnailPriority = ServiceCallPriority.asap;

  static Future<void> getImageEntries() async {
    try {
      await platform.invokeMethod('getImageEntries');
    } on PlatformException catch (e) {
      debugPrint('getImageEntries failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
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

  static Future<Uint8List> getImage(String uri, String mimeType) {
    try {
      final completer = Completer<Uint8List>();
      final bytesBuilder = BytesBuilder(copy: false);
      byteChannel.receiveBroadcastStream(<String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
      }).listen(
        (data) => bytesBuilder.add(data as Uint8List),
        onError: completer.completeError,
        onDone: () => completer.complete(bytesBuilder.takeBytes()),
        cancelOnError: true,
      );
      return completer.future;
    } on PlatformException catch (e) {
      debugPrint('getImage failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return Future.sync(() => Uint8List(0));
  }

  static Future<Uint8List> getThumbnail(ImageEntry entry, int width, int height, {Object taskKey}) {
    return servicePolicy.call(
      () async {
        if (width > 0 && height > 0) {
          try {
            final result = await platform.invokeMethod('getThumbnail', <String, dynamic>{
              'entry': entry.toMap(),
              'width': width,
              'height': height,
            });
            return result as Uint8List;
          } on PlatformException catch (e) {
            debugPrint('getThumbnail failed with code=${e.code}, exception=${e.message}, details=${e.details}');
          }
        }
        return Uint8List(0);
      },
      priority: thumbnailPriority,
      key: taskKey,
    );
  }

  static bool cancelThumbnail(Object taskKey) => servicePolicy.pause(taskKey, thumbnailPriority);

  static Future<T> resumeThumbnail<T>(Object taskKey) => servicePolicy.resume<T>(taskKey, thumbnailPriority);

  static Stream<ImageOpEvent> delete(List<ImageEntry> entries) {
    try {
      return opChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'delete',
        'entries': entries.map((e) => e.toMap()).toList(),
      }).map((event) => ImageOpEvent.fromMap(event));
    } on PlatformException catch (e) {
      debugPrint('delete failed with code=${e.code}, exception=${e.message}, details=${e.details}');
      return Stream.error(e);
    }
  }

  static Stream<MoveOpEvent> move(List<ImageEntry> entries, {@required bool copy, @required String destinationPath}) {
    debugPrint('move ${entries.length} entries');
    try {
      return opChannel.receiveBroadcastStream(<String, dynamic>{
        'op': 'move',
        'entries': entries.map((e) => e.toMap()).toList(),
        'copy': copy,
        'destinationPath': destinationPath,
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
        'entry': entry.toMap(),
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
        'entry': entry.toMap(),
        'clockwise': clockwise,
      }) as Map;
      return result;
    } on PlatformException catch (e) {
      debugPrint('rotate failed with code=${e.code}, exception=${e.message}, details=${e.details}');
    }
    return {};
  }
}

class ImageOpEvent {
  final bool success;
  final String uri;

  ImageOpEvent({
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

  MoveOpEvent({bool success, String uri, this.newFields})
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
