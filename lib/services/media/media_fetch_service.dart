import 'dart:async';
import 'dart:ui' as ui;

import 'package:aves/image_providers/region_provider.dart';
import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/app/support.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/decoding.dart';
import 'package:aves/services/common/output_buffer.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

abstract class MediaFetchService {
  Future<AvesEntry?> getEntry(String uri, String? mimeType, {bool allowUnsized = false});

  Future<Uint8List> getOriginalBytes(AvesEntry entry);

  Future<ui.Codec> getFullImage({
    required bool decoded,
    required ImageRequest request,
    required ImageDecoderCallback decode,
  });

  // `rect`: region to decode, with coordinates in reference to `imageSize`
  Future<ui.Codec> getRegion({
    required bool decoded,
    required RegionProviderKey request,
    required ImageDecoderCallback decode,
    Object? taskKey,
    int? priority,
  });

  Future<ui.Codec> getThumbnail({
    required bool decoded,
    required ThumbnailProviderKey request,
    ImageDecoderCallback? decode,
    Object? taskKey,
    int? priority,
  });

  Future<void> clearDecoders();

  Future<void> clearImageDiskCache();

  Future<void> clearImageMemoryCache();

  bool cancelRegion(Object taskKey);

  bool cancelThumbnail(Object taskKey);

  Future<T>? resumeLoading<T>(Object taskKey);
}

class PlatformMediaFetchService implements MediaFetchService {
  static const _platformObject = AvesMethodChannel('deckers.thibault/aves/media_fetch_object');
  static final _byteStream = AvesStreamsChannel('deckers.thibault/aves/media_byte_stream');

  static const int _formatTrailerLength = 1; // single format byte
  static const int _formatByteEncoded = 0xCA;
  static const int _formatByteDecoded = 0xFE;

  static bool applyHdrGainmap = false;

  @override
  Future<AvesEntry?> getEntry(String uri, String? mimeType, {bool allowUnsized = false}) async {
    try {
      final result =
          await _platformObject.invokeMethod('getEntry', <String, Object?>{
                'uri': uri,
                'mimeType': mimeType,
                'allowUnsized': allowUnsized,
              })
              as Map;
      AvesEntry.normalizeMimeTypeFields(result);
      return AvesEntry.fromMap(result);
    } on PlatformException catch (e, stack) {
      // ignore media content URIs as it is likely an obsolete Media Store entry
      if (!uri.startsWith('content://media/')) {
        // ignore undecodable types
        if (mimeType != null && !AppSupport.undecodableImages.contains(mimeType)) {
          await reportService.recordError(e, stack);
        }
      }
    }
    return null;
  }

  Map<String, Object?> _requestToArgs(ImageRequest request, {required bool decoded}) {
    return <String, Object?>{
      'op': 'getFullImage',
      'decoded': decoded,
      'uri': request.uri,
      'pageId': request.pageId,
      'mimeType': request.mimeType,
      'sizeBytes': request.sizeBytes,
      'rotationDegrees': request.rotationDegrees ?? 0,
      'isFlipped': request.isFlipped,
    };
  }

  Future<Uint8List> _getBytes({
    required String mimeType,
    required Map<String, Object?> arguments,
    BytesReceivedCallback? onBytesReceived,
    int? sizeBytes,
  }) async {
    var bytesReceived = 0;
    final opCompleter = Completer<Uint8List>();
    final sink = OutputBuffer();
    try {
      _byteStream
          .receiveBroadcastStream(arguments)
          .listen(
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
      debugPrint('$runtimeType _getBytes failed with error=$e');
      if (MimeTypes.isVisual(mimeType) && !_knownMediaTypes.contains(mimeType)) {
        await reportService.recordError(e, stack);
      }
    }
    return Uint8List(0);
  }

  Future<ui.Codec> _bytesToCodec(Map<String, dynamic> args, Uint8List bytes, ImageDecoderCallback? decode) async {
    final trailerOffset = bytes.lengthInBytes - _formatTrailerLength;
    if (trailerOffset < 0) {
      throw UnreportedStateError('failed to get image bytes for args=$args');
    }

    final format = bytes[trailerOffset];
    switch (format) {
      case _formatByteEncoded:
        if (decode == null) {
          throw Exception('failed to decode encoded image bytes because decoder callback is missing for args=$args');
        }
        // bytes are expected to be in a basic format decodable by Flutter
        final codec = await InteropDecoding.encodedBytesToCodec(bytes, decode);
        if (codec == null) {
          throw UnreportedStateError('failed to get codec from encoded image bytes for args=$args');
        }
        return codec;
      case _formatByteDecoded:
        // bytes are expected to be in ARGB_8888, necessary for wide gamut or HDR
        final descriptor = await InteropDecoding.rawBytesToDescriptor(bytes);
        if (descriptor == null) {
          throw UnreportedStateError('failed to get descriptor from decoded image bytes for args=$args');
        }
        return descriptor.instantiateCodec();
      default:
        throw UnreportedStateError('unsupported image format byte=$format for args=$args');
    }
  }

  @override
  Future<Uint8List> getOriginalBytes(AvesEntry entry) async {
    final request = ImageRequest(
      entry.uri,
      entry.mimeType,
      rotationDegrees: entry.rotationDegrees,
      isFlipped: entry.isFlipped,
      isAnimated: entry.isAnimated,
      pageId: entry.pageId,
      sizeBytes: entry.sizeBytes,
    );
    final bytes = await _getBytes(
      mimeType: request.mimeType,
      arguments: _requestToArgs(request, decoded: false),
      onBytesReceived: request.onBytesReceived,
      sizeBytes: request.sizeBytes,
    );

    final byteCount = bytes.lengthInBytes;
    if (byteCount <= _formatTrailerLength) {
      throw UnreportedStateError('failed to get image bytes for request=$request');
    }

    // trim custom trailer
    // a view does not reallocate memory and uses the underlying buffer
    return Uint8List.sublistView(bytes, 0, byteCount - _formatTrailerLength);
  }

  @override
  Future<ui.Codec> getFullImage({
    required bool decoded,
    required ImageRequest request,
    required ImageDecoderCallback decode,
  }) async {
    final args = _requestToArgs(request, decoded: decoded);
    final bytes = await _getBytes(
      mimeType: request.mimeType,
      arguments: args,
      onBytesReceived: request.onBytesReceived,
      sizeBytes: request.sizeBytes,
    );
    return await _bytesToCodec(args, bytes, decode);
  }

  @override
  Future<ui.Codec> getRegion({
    required bool decoded,
    required RegionProviderKey request,
    required ImageDecoderCallback decode,
    Object? taskKey,
    int? priority,
  }) {
    final args = <String, Object?>{
      'op': 'getRegion',
      'decoded': decoded,
      'applyGainmap': applyHdrGainmap,
      'uri': request.uri,
      'pageId': request.pageId,
      'mimeType': request.mimeType,
      'sizeBytes': request.sizeBytes,
      'sampleSize': request.sampleSize,
      'regionX': request.regionRect.left,
      'regionY': request.regionRect.top,
      'regionWidth': request.regionRect.width,
      'regionHeight': request.regionRect.height,
      'imageWidth': request.imageSize.width.toInt(),
      'imageHeight': request.imageSize.height.toInt(),
    };
    return servicePolicy.call(
      () async {
        final bytes = await _getBytes(
          mimeType: request.mimeType,
          arguments: args,
        );
        return await _bytesToCodec(args, bytes, decode);
      },
      priority: priority ?? ServiceCallPriority.getRegion,
      key: taskKey,
    );
  }

  @override
  Future<ui.Codec> getThumbnail({
    required bool decoded,
    required ThumbnailProviderKey request,
    ImageDecoderCallback? decode,
    Object? taskKey,
    int? priority,
  }) {
    final uri = request.uri;
    final mimeType = request.mimeType;
    final extentDip = request.extent;
    final args = <String, Object?>{
      'op': 'getThumbnail',
      'decoded': decoded,
      'uri': uri,
      'pageId': request.pageId,
      'mimeType': mimeType,
      'dateModifiedMillis': request.dateModifiedMillis,
      'rotationDegrees': request.rotationDegrees,
      'isFlipped': request.isFlipped,
      'widthDip': extentDip,
      'heightDip': extentDip,
    };
    return servicePolicy.call(
      () async {
        final bytes = await _getBytes(
          mimeType: request.mimeType,
          arguments: args,
        );

        if (bytes.isEmpty && (MimeTypes.isVideo(mimeType) || mimeType == MimeTypes.avif)) {
          final descriptor = await videoMetadataFetcher.getThumbnailDescriptor(
            uri: uri,
            mimeType: mimeType,
            targetExtentDip: extentDip,
          );
          final codec = await descriptor?.instantiateCodec(
            targetWidth: descriptor.width,
            targetHeight: descriptor.height,
          );
          if (codec == null) {
            throw UnreportedStateError('failed to get codec from video screenshot bytes for args=$args');
          }
          return codec;
        } else {
          return await _bytesToCodec(args, bytes, decode);
        }
      },
      priority: priority ?? (extentDip == 0 ? ServiceCallPriority.getFastThumbnail : ServiceCallPriority.getSizedThumbnail),
      key: taskKey,
    );
  }

  @override
  Future<void> clearDecoders() async {
    try {
      return _platformObject.invokeMethod('clearDecoders');
    } on PlatformException catch (e, stack) {
      await reportService.recordError(e, stack);
    }
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
    MimeTypes.dl,
    MimeTypes.dv,
    MimeTypes.dvd,
    MimeTypes.flv,
    MimeTypes.flvX,
    MimeTypes.gl,
    MimeTypes.lsf,
    MimeTypes.m4s,
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
