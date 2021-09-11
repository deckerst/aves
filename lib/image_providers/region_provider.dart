import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui show Codec;

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
  ImageStreamCompleter load(RegionProviderKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${key.uri}, pageId=${key.pageId}, mimeType=${key.mimeType}, region=${key.region}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(RegionProviderKey key, DecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    final pageId = key.pageId;
    try {
      final bytes = await mediaFileService.getRegion(
        uri,
        mimeType,
        key.rotationDegrees,
        key.isFlipped,
        key.sampleSize,
        key.region,
        key.imageSize,
        pageId: pageId,
        taskKey: key,
      );
      if (bytes.isEmpty) {
        throw StateError('$uri ($mimeType) region loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw StateError('$mimeType region decoding failed (page $pageId)');
    }
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, RegionProviderKey key, ImageErrorListener handleError) {
    mediaFileService.resumeLoading(key);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => mediaFileService.cancelRegion(key);
}

@immutable
class RegionProviderKey extends Equatable {
  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  final String uri, mimeType;
  final int? pageId;
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
    required this.rotationDegrees,
    required this.isFlipped,
    required this.sampleSize,
    required this.region,
    required this.imageSize,
  });

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, pageId=$pageId, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, sampleSize=$sampleSize, region=$region, imageSize=$imageSize}';
}
