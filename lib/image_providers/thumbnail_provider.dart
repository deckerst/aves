import 'dart:ui' as ui show Codec;

import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ThumbnailProvider extends ImageProvider<ThumbnailProviderKey> {
  final ThumbnailProviderKey key;

  ThumbnailProvider(this.key);

  @override
  Future<ThumbnailProviderKey> obtainKey(ImageConfiguration configuration) {
    // configuration can be empty (e.g. when obtaining key for eviction)
    // so we do not compute the target width/height here
    // and pass it to the key, to use it later for image loading
    return SynchronousFuture<ThumbnailProviderKey>(key);
  }

  @override
  ImageStreamCompleter load(ThumbnailProviderKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${key.uri}, pageId=${key.pageId}, mimeType=${key.mimeType}, extent=${key.extent}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProviderKey key, DecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    final pageId = key.pageId;
    try {
      final bytes = await imageFileService.getThumbnail(
        uri: uri,
        mimeType: mimeType,
        pageId: pageId,
        rotationDegrees: key.rotationDegrees,
        isFlipped: key.isFlipped,
        dateModifiedSecs: key.dateModifiedSecs,
        extent: key.extent,
        taskKey: key,
      );
      if (bytes.isEmpty) {
        throw StateError('$uri ($mimeType) loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with uri=$uri, error=$error');
      throw StateError('$mimeType decoding failed (page $pageId)');
    }
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, ThumbnailProviderKey key, ImageErrorListener handleError) {
    imageFileService.resumeLoading(key);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => imageFileService.cancelThumbnail(key);
}

class ThumbnailProviderKey {
  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  final String uri, mimeType;
  final int? pageId;
  final int rotationDegrees;
  final bool isFlipped;
  final int dateModifiedSecs;
  final double extent;

  const ThumbnailProviderKey({
    required this.uri,
    required this.mimeType,
    required this.pageId,
    required this.rotationDegrees,
    required this.isFlipped,
    required this.dateModifiedSecs,
    this.extent = 0,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ThumbnailProviderKey && other.uri == uri && other.pageId == pageId && other.dateModifiedSecs == dateModifiedSecs && other.extent == extent;
  }

  @override
  int get hashCode => hashValues(
        uri,
        pageId,
        dateModifiedSecs,
        extent,
      );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, pageId=$pageId, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, dateModifiedSecs=$dateModifiedSecs, extent=$extent}';
}
