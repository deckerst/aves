import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
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
  ImageStreamCompleter loadImage(ThumbnailProviderKey key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: kReleaseMode ? null : [key.uri, key.extent].join('-'),
      informationCollector: () sync* {
        yield ErrorDescription('uri=${key.uri}, pageId=${key.pageId}, mimeType=${key.mimeType}, extent=${key.extent}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProviderKey key, ImageDecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    final pageId = key.pageId;
    try {
      final bytes = await mediaFetchService.getThumbnail(
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
        throw UnreportedStateError('$uri ($mimeType) loading failed');
      }
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await decode(buffer);
    } catch (error) {
      // loading may fail if the provided MIME type is incorrect (e.g. the Media Store may report a JPEG as a TIFF)
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw UnreportedStateError('$mimeType decoding failed (page $pageId)');
    }
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, ThumbnailProviderKey key, ImageErrorListener handleError) {
    mediaFetchService.resumeLoading(key);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => mediaFetchService.cancelThumbnail(key);
}

@immutable
class ThumbnailProviderKey extends Equatable {
  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  final String uri, mimeType;
  final int? pageId;
  final int rotationDegrees;
  final bool isFlipped;
  final int dateModifiedSecs;
  final double extent;

  @override
  List<Object?> get props => [uri, pageId, dateModifiedSecs, extent];

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
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, pageId=$pageId, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, dateModifiedSecs=$dateModifiedSecs, extent=$extent}';
}
