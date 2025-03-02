import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RegionProvider extends ImageProvider<RegionProviderKey> {
  final RegionProviderKey key;

  RegionProvider(this.key);

  @override
  Future<RegionProviderKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<RegionProviderKey>(key);
  }

  @override
  ImageStreamCompleter loadImage(RegionProviderKey key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${key.uri}, pageId=${key.pageId}, mimeType=${key.mimeType}, region=${key.region}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(RegionProviderKey key, ImageDecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    final pageId = key.pageId;
    try {
      final bytes = await mediaFetchService.getRegion(
        uri,
        mimeType,
        key.rotationDegrees,
        key.isFlipped,
        key.sampleSize,
        key.region,
        key.imageSize,
        pageId: pageId,
        sizeBytes: key.sizeBytes,
        taskKey: key,
      );
      if (bytes.isEmpty) {
        throw StateError('$uri ($mimeType) region loading failed');
      }

      final trailerOffset = bytes.length - 4 * 2;
      final trailer = ByteData.sublistView(bytes, trailerOffset);
      final bitmapWidth = trailer.getUint32(0);
      final bitmapHeight = trailer.getUint32(4);

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: bitmapWidth,
        height: bitmapHeight,
        pixelFormat: ui.PixelFormat.rgba8888,
      );

      return descriptor.instantiateCodec();
    } catch (error) {
      // loading may fail if the provided MIME type is incorrect (e.g. the Media Store may report a JPEG as a TIFF)
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw StateError('$mimeType region decoding failed (page $pageId)');
    }
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, RegionProviderKey key, ImageErrorListener handleError) {
    mediaFetchService.resumeLoading(key);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => mediaFetchService.cancelRegion(key);
}

@immutable
class RegionProviderKey extends Equatable {
  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  final String uri, mimeType;
  final int? pageId, sizeBytes;
  final int rotationDegrees, sampleSize;
  final bool isFlipped;
  final Rectangle<int> region;
  final Size imageSize;

  @override
  List<Object?> get props => [uri, pageId, rotationDegrees, isFlipped, sampleSize, region, imageSize];

  const RegionProviderKey({
    required this.uri,
    required this.mimeType,
    required this.pageId,
    required this.sizeBytes,
    required this.rotationDegrees,
    required this.isFlipped,
    required this.sampleSize,
    required this.region,
    required this.imageSize,
  });
}
