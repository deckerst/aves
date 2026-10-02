import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class const ThumbnailProvider(final ThumbnailProviderKey key) extends ImageProvider<ThumbnailProviderKey> {
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
    try {
      return await mediaFetchService.getThumbnail(
        decoded: false,
        request: key,
        decode: decode,
        taskKey: key,
      );
    } catch (error) {
      // loading may fail if the provided MIME type is incorrect (e.g. the Media Store may report a JPEG as a TIFF)
      debugPrint('$runtimeType _loadAsync failed for key=$key, error=$error');
      throw UnreportedStateError('thumbnail decoding failed for key=$key, error=$error');
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
class const ThumbnailProviderKey({
  required final String uri,
  required final String mimeType,
  required final int? pageId,
  required final int rotationDegrees,
  required final bool isFlipped,
  required final int dateModifiedMillis,
  final double extent = 0,
  required final List<VideoThumbnailMethod>? videoThumbnailMethods,
}) extends Equatable {
  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  @override
  List<Object?> get props => [uri, mimeType, pageId, rotationDegrees, isFlipped, dateModifiedMillis, extent, videoThumbnailMethods];

  @override
  String toString() =>
      '$runtimeType#${shortHash(this)}{uri=$uri, mimeType=$mimeType, pageId=$pageId'
      ', rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, dateModifiedMillis=$dateModifiedMillis'
      ', extent=$extent, videoThumbnailMethods=$videoThumbnailMethods}';
}
