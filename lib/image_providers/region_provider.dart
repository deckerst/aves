import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui show Codec;

import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RegionProvider extends ImageProvider<RegionProviderKey> {
  final RegionProviderKey key;

  RegionProvider(this.key) : assert(key != null);

  @override
  Future<RegionProviderKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<RegionProviderKey>(key);
  }

  @override
  ImageStreamCompleter load(RegionProviderKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${key.uri}, page=${key.page}, mimeType=${key.mimeType}, region=${key.region}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(RegionProviderKey key, DecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    final page = key.page;
    try {
      final bytes = await ImageFileService.getRegion(
        uri,
        mimeType,
        key.rotationDegrees,
        key.isFlipped,
        key.sampleSize,
        key.region,
        key.imageSize,
        page: page,
        taskKey: key,
      );
      if (bytes == null) {
        throw StateError('$uri ($mimeType) region loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw StateError('$mimeType region decoding failed (page $page)');
    }
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, RegionProviderKey key, ImageErrorListener handleError) {
    ImageFileService.resumeLoading(key);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => ImageFileService.cancelRegion(key);
}

class RegionProviderKey {
  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  final String uri, mimeType;
  final int page, rotationDegrees, sampleSize;
  final bool isFlipped;
  final Rectangle<int> region;
  final Size imageSize;
  final double scale;

  const RegionProviderKey({
    @required this.uri,
    @required this.mimeType,
    @required this.page,
    @required this.rotationDegrees,
    @required this.isFlipped,
    @required this.sampleSize,
    @required this.region,
    @required this.imageSize,
    this.scale = 1.0,
  })  : assert(uri != null),
        assert(mimeType != null),
        assert(rotationDegrees != null),
        assert(isFlipped != null),
        assert(sampleSize != null),
        assert(region != null),
        assert(imageSize != null),
        assert(scale != null);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RegionProviderKey && other.uri == uri && other.mimeType == mimeType && other.page == page && other.rotationDegrees == rotationDegrees && other.isFlipped == isFlipped && other.sampleSize == sampleSize && other.region == region && other.imageSize == imageSize && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(
        uri,
        mimeType,
        page,
        rotationDegrees,
        isFlipped,
        sampleSize,
        region,
        imageSize,
        scale,
      );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, page=$page, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, sampleSize=$sampleSize, region=$region, imageSize=$imageSize, scale=$scale}';
}
