import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_report/aves_report.dart';
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
        yield ErrorDescription('uri=${key.uri}, pageId=${key.pageId}, mimeType=${key.mimeType}, regionRect=${key.regionRect}');
      },
    );
  }

  bool _shouldFetchRawBytes(RegionProviderKey key) => key.mimeType != MimeTypes.svg;

  Future<ui.Codec> _loadAsync(RegionProviderKey key, ImageDecoderCallback decode) async {
    try {
      return await mediaFetchService.getRegion(
        decoded: _shouldFetchRawBytes(key),
        request: key,
        decode: decode,
        taskKey: key,
      );
    } catch (error) {
      // loading may fail if the provided MIME type is incorrect (e.g. the Media Store may report a JPEG as a TIFF)
      debugPrint('$runtimeType _loadAsync failed for key=$key, error=$error');
      throw UnreportedStateError('region decoding failed for key=$key, error=$error');
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
  final Rectangle<int> regionRect;
  final Size imageSize;

  @override
  List<Object?> get props => [uri, mimeType, pageId, sizeBytes, rotationDegrees, isFlipped, sampleSize, regionRect, imageSize];

  const RegionProviderKey({
    required this.uri,
    required this.mimeType,
    required this.pageId,
    required this.sizeBytes,
    required this.rotationDegrees,
    required this.isFlipped,
    required this.sampleSize,
    required this.regionRect,
    required this.imageSize,
  });
}
