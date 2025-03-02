import 'dart:async';
import 'dart:math';

import 'package:aves/model/app/support.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/decoding.dart';
import 'package:aves/services/common/output_buffer.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/byte_receiving_codec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';
import 'dart:ui' as ui;

abstract class MediaFetchService {
  Future<AvesEntry?> getEntry(String uri, String? mimeType, {bool allowUnsized = false});

  Future<Uint8List> getSvg(
    String uri,
    String mimeType, {
    required int? sizeBytes,
    BytesReceivedCallback? onBytesReceived,
  });

  Future<Uint8List> getImage(
    String uri,
    String mimeType, {
    required int? rotationDegrees,
    required bool isFlipped,
    required int? pageId,
    required int? sizeBytes,
    BytesReceivedCallback? onBytesReceived,
  });

  // `rect`: region to decode, with coordinates in reference to `imageSize`
  Future<ui.ImageDescriptor?> getRegion(
    String uri,
    String mimeType,
    int rotationDegrees,
    bool isFlipped,
    int sampleSize,
    Rectangle<int> regionRect,
    Size imageSize, {
    required int? pageId,
    required int? sizeBytes,
    Object? taskKey,
    int? priority,
  });

  Future<ui.ImageDescriptor?> getThumbnail({
    required String uri,
    required String mimeType,
    required int rotationDegrees,
    required int? pageId,
    required bool isFlipped,
    required int? dateModifiedMillis,
    required double extent,
    Object? taskKey,
    int? priority,
  });

  Future<void> clearSizedThumbnailDiskCache();

  bool cancelRegion(Object taskKey);

  bool cancelThumbnail(Object taskKey);

  Future<T>? resumeLoading<T>(Object taskKey);
}

class PlatformMediaFetchService implements MediaFetchService {
  static const _platformObject = MethodChannel('deckers.thibault/aves/media_fetch_object');
  static const _platformBytes = MethodChannel('deckers.thibault/aves/media_fetch_bytes', AvesByteReceivingMethodCodec());
  static final _byteStream = StreamsChannel('deckers.thibault/aves/media_byte_stream');
  static const double _thumbnailDefaultSize = 64.0;

  @override
  Future<AvesEntry?> getEntry(String uri, String? mimeType, {bool allowUnsized = false}) async {
    try {
      final result = await _platformObject.invokeMethod('getEntry', <String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
        'allowUnsized': allowUnsized,
      }) as Map;
      return AvesEntry.fromMap(result);
    } on PlatformException catch (e, stack) {
      // do not report issues with media content as it is likely an obsolete Media Store entry
      if (!uri.startsWith('content://media/')) {
        await reportService.recordError(e, stack);
      }
    }
    return null;
  }

  @override
  Future<Uint8List> getSvg(
    String uri,
    String mimeType, {
    required int? sizeBytes,
    BytesReceivedCallback? onBytesReceived,
  }) =>
      getImage(
        uri,
        mimeType,
        rotationDegrees: 0,
        isFlipped: false,
        pageId: null,
        sizeBytes: sizeBytes,
        onBytesReceived: onBytesReceived,
      );

  @override
  Future<Uint8List> getImage(
    String uri,
    String mimeType, {
    required int? rotationDegrees,
    required bool isFlipped,
    required int? pageId,
    required int? sizeBytes,
    BytesReceivedCallback? onBytesReceived,
  }) async {
    try {
      final opCompleter = Completer<Uint8List>();
      final sink = OutputBuffer();
      var bytesReceived = 0;
      _byteStream.receiveBroadcastStream(<String, dynamic>{
        'uri': uri,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
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
              onBytesReceived(bytesReceived, sizeBytes);
            } catch (error, stack) {
              opCompleter.completeError(error, stack);
              return;
            }
          }
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
      if (_isUnknownVisual(mimeType)) {
        await reportService.recordError(e, stack);
      }
    }
    return Uint8List(0);
  }

  @override
  Future<ui.ImageDescriptor?> getRegion(
    String uri,
    String mimeType,
    int rotationDegrees,
    bool isFlipped,
    int sampleSize,
    Rectangle<int> regionRect,
    Size imageSize, {
    required int? pageId,
    required int? sizeBytes,
    Object? taskKey,
    int? priority,
  }) {
    return servicePolicy.call(
      () async {
        try {
          final result = await _platformBytes.invokeMethod('getRegion', <String, dynamic>{
            'uri': uri,
            'mimeType': mimeType,
            'sizeBytes': sizeBytes,
            'pageId': pageId,
            'sampleSize': sampleSize,
            'regionX': regionRect.left,
            'regionY': regionRect.top,
            'regionWidth': regionRect.width,
            'regionHeight': regionRect.height,
            'imageWidth': imageSize.width.toInt(),
            'imageHeight': imageSize.height.toInt(),
          });
          if (result != null) {
            final bytes = result as Uint8List;
            return InteropDecoding.bytesToCodec(bytes);
          }
        } on PlatformException catch (e, stack) {
          if (_isUnknownVisual(mimeType)) {
            await reportService.recordError(e, stack);
          }
        }
        return null;
      },
      priority: priority ?? ServiceCallPriority.getRegion,
      key: taskKey,
    );
  }

  @override
  Future<ui.ImageDescriptor?> getThumbnail({
    required String uri,
    required String mimeType,
    required int rotationDegrees,
    required int? pageId,
    required bool isFlipped,
    required int? dateModifiedMillis,
    required double extent,
    Object? taskKey,
    int? priority,
  }) {
    return servicePolicy.call(
      () async {
        try {
          final result = await _platformBytes.invokeMethod('getThumbnail', <String, dynamic>{
            'uri': uri,
            'mimeType': mimeType,
            'dateModifiedMillis': dateModifiedMillis,
            'rotationDegrees': rotationDegrees,
            'isFlipped': isFlipped,
            'widthDip': extent,
            'heightDip': extent,
            'pageId': pageId,
            'defaultSizeDip': _thumbnailDefaultSize,
            'quality': 100,
          });
          if (result != null) {
            final bytes = result as Uint8List;
            return InteropDecoding.bytesToCodec(bytes);
          }
        } on PlatformException catch (e, stack) {
          if (_isUnknownVisual(mimeType)) {
            await reportService.recordError(e, stack);
          }
        }
        return null;
      },
      priority: priority ?? (extent == 0 ? ServiceCallPriority.getFastThumbnail : ServiceCallPriority.getSizedThumbnail),
      key: taskKey,
    );
  }

  @override
  Future<void> clearSizedThumbnailDiskCache() async {
    try {
      return _platformObject.invokeMethod('clearSizedThumbnailDiskCache');
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

  // convenience methods

  bool _isUnknownVisual(String mimeType) => !_knownMediaTypes.contains(mimeType) && MimeTypes.isVisual(mimeType);

  static const Set<String> _knownOpaqueImages = {
    MimeTypes.jpeg,
  };

  static const Set<String> _knownVideos = {
    MimeTypes.v3gpp,
    MimeTypes.asf,
    MimeTypes.avi,
    MimeTypes.aviMSVideo,
    MimeTypes.aviVnd,
    MimeTypes.aviXMSVideo,
    MimeTypes.dvd,
    MimeTypes.flv,
    MimeTypes.flvX,
    MimeTypes.mkv,
    MimeTypes.mkvX,
    MimeTypes.mov,
    MimeTypes.movX,
    MimeTypes.mp2p,
    MimeTypes.mp2t,
    MimeTypes.mp2ts,
    MimeTypes.mp4,
    MimeTypes.mpeg,
    MimeTypes.ogv,
    MimeTypes.realVideo,
    MimeTypes.webm,
    MimeTypes.wmv,
  };

  static final Set<String> _knownMediaTypes = {
    MimeTypes.anyImage,
    ..._knownOpaqueImages,
    ...MimeTypes.alphaImages,
    ...MimeTypes.rawImages,
    ...AppSupport.undecodableImages,
    MimeTypes.anyVideo,
    ..._knownVideos,
  };
}
