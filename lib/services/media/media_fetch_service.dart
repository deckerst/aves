import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/model/app/support.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/decoding.dart';
import 'package:aves/services/common/output_buffer.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

abstract class MediaFetchService {
  Future<AvesEntry?> getEntry(String uri, String? mimeType, {bool allowUnsized = false});

  Future<Uint8List> getSvg(
    String uri,
    String mimeType, {
    required int? sizeBytes,
    BytesReceivedCallback? onBytesReceived,
  });

  Future<Uint8List> getEncodedImage(ImageRequest request);

  Future<ui.ImageDescriptor?> getDecodedImage(ImageRequest request);

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

  Future<void> clearImageDiskCache();

  Future<void> clearImageMemoryCache();

  bool cancelRegion(Object taskKey);

  bool cancelThumbnail(Object taskKey);

  Future<T>? resumeLoading<T>(Object taskKey);
}

class PlatformMediaFetchService implements MediaFetchService {
  static const _platformObject = MethodChannel('deckers.thibault/aves/media_fetch_object');
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
      AvesEntry.normalizeMimeTypeFields(result);
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
      getEncodedImage(
        ImageRequest(
          uri,
          mimeType,
          rotationDegrees: 0,
          isFlipped: false,
          isAnimated: false,
          pageId: null,
          sizeBytes: sizeBytes,
          onBytesReceived: onBytesReceived,
        ),
      );

  @override
  Future<Uint8List> getEncodedImage(ImageRequest request) {
    return _getBytes(request, decoded: false);
  }

  @override
  Future<ui.ImageDescriptor?> getDecodedImage(ImageRequest request) async {
    return _getBytes(request, decoded: true).then(InteropDecoding.bytesToCodec);
  }

  Future<Uint8List> _getBytes(ImageRequest request, {required bool decoded}) async {
    final _onBytesReceived = request.onBytesReceived;
    var bytesReceived = 0;
    final opCompleter = Completer<Uint8List>();
    final sink = OutputBuffer();
    try {
      _byteStream.receiveBroadcastStream(<String, dynamic>{
        'op': 'getFullImage',
        'uri': request.uri,
        'mimeType': request.mimeType,
        'sizeBytes': request.sizeBytes,
        'rotationDegrees': request.rotationDegrees ?? 0,
        'isFlipped': request.isFlipped,
        'isAnimated': request.isAnimated,
        'pageId': request.pageId,
        'decoded': decoded,
      }).listen(
        (data) {
          final chunk = data as Uint8List;
          sink.add(chunk);
          if (_onBytesReceived != null) {
            bytesReceived += chunk.length;
            try {
              _onBytesReceived(bytesReceived, request.sizeBytes);
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
      debugPrint('$runtimeType _getBytes failed with error=$e');
      if (_isUnknownVisual(request.mimeType)) {
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
        final opCompleter = Completer<Uint8List>();
        final sink = OutputBuffer();
        try {
          _byteStream.receiveBroadcastStream(<String, dynamic>{
            'op': 'getRegion',
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
          }).listen(
            (data) => sink.add(data as Uint8List),
            onError: opCompleter.completeError,
            onDone: () {
              sink.close();
              opCompleter.complete(sink.bytes);
            },
            cancelOnError: true,
          );
          // `await` here, so that `completeError` will be caught below
          final bytes = await opCompleter.future;
          return InteropDecoding.bytesToCodec(bytes);
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
        final opCompleter = Completer<Uint8List>();
        final sink = OutputBuffer();
        try {
          _byteStream.receiveBroadcastStream(<String, dynamic>{
            'op': 'getThumbnail',
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
          }).listen(
            (data) => sink.add(data as Uint8List),
            onError: opCompleter.completeError,
            onDone: () {
              sink.close();
              opCompleter.complete(sink.bytes);
            },
            cancelOnError: true,
          );
          // `await` here, so that `completeError` will be caught below
          final bytes = await opCompleter.future;
          return InteropDecoding.bytesToCodec(bytes);
        } on PlatformException catch (e, stack) {
          if (_isUnknownVisual(mimeType) || e.code == 'getThumbnail-large') {
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
  Future<void> clearImageDiskCache() async {
    try {
      return _platformObject.invokeMethod('clearImageDiskCache');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  @override
  Future<void> clearImageMemoryCache() async {
    try {
      return _platformObject.invokeMethod('clearImageMemoryCache');
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

@immutable
class ImageRequest extends Equatable {
  final String uri;
  final String mimeType;
  final int? rotationDegrees;
  final bool isFlipped;
  final bool isAnimated;
  final int? pageId;
  final int? sizeBytes;
  final BytesReceivedCallback? onBytesReceived;

  @override
  List<Object?> get props => [uri, mimeType, rotationDegrees, isFlipped, isAnimated, pageId, sizeBytes, onBytesReceived];

  const ImageRequest(
    this.uri,
    this.mimeType, {
    required this.rotationDegrees,
    required this.isFlipped,
    required this.isAnimated,
    required this.pageId,
    required this.sizeBytes,
    this.onBytesReceived,
  });
}
