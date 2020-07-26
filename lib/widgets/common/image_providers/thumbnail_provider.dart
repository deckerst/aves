import 'dart:typed_data';
import 'dart:ui' as ui show Codec;

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThumbnailProvider extends ImageProvider<ThumbnailProviderKey> {
  ThumbnailProvider({
    @required this.entry,
    this.extent = 0,
    this.scale = 1,
  })  : assert(entry != null),
        assert(extent != null),
        assert(scale != null) {
    _cancellationKey = _buildKey(ImageConfiguration.empty);
  }

  final ImageEntry entry;
  final double extent;
  final double scale;

  Object _cancellationKey;

  @override
  Future<ThumbnailProviderKey> obtainKey(ImageConfiguration configuration) {
    // configuration can be empty (e.g. when obtaining key for eviction)
    // so we do not compute the target width/height here
    // and pass it to the key, to use it later for image loading
    return SynchronousFuture<ThumbnailProviderKey>(_buildKey(configuration));
  }

  ThumbnailProviderKey _buildKey(ImageConfiguration configuration) => ThumbnailProviderKey(
        entry: entry,
        extent: extent,
        scale: scale,
      );

  @override
  ImageStreamCompleter load(ThumbnailProviderKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${entry.uri}, extent=$extent');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProviderKey key, DecoderCallback decode) async {
    final bytes = await ImageFileService.getThumbnail(key.entry, extent, extent, taskKey: _cancellationKey);
    return await decode(bytes ?? Uint8List(0));
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, ThumbnailProviderKey key, ImageErrorListener handleError) {
    ImageFileService.resumeThumbnail(_cancellationKey);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => ImageFileService.cancelThumbnail(_cancellationKey);
}

class ThumbnailProviderKey {
  final ImageEntry entry;
  final double extent;
  final double scale;

  const ThumbnailProviderKey({
    @required this.entry,
    @required this.extent,
    this.scale,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ThumbnailProviderKey && other.entry.contentId == entry.contentId && other.extent == extent && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(entry.contentId, extent, scale);

  @override
  String toString() {
    return 'ThumbnailProviderKey{contentId=${entry.contentId}, extent=$extent, scale=$scale}';
  }
}
