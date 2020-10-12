import 'dart:ui' as ui show Codec;

import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThumbnailProvider extends ImageProvider<ThumbnailProviderKey> {
  ThumbnailProvider({
    @required this.uri,
    @required this.mimeType,
    @required this.rotationDegrees,
    this.extent = 0,
    this.scale = 1,
  })  : assert(uri != null),
        assert(mimeType != null),
        assert(rotationDegrees != null),
        assert(extent != null),
        assert(scale != null) {
    _cancellationKey = _buildKey(ImageConfiguration.empty);
  }

  final String uri;
  final String mimeType;
  final int rotationDegrees;
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
        uri: uri,
        mimeType: mimeType,
        rotationDegrees: rotationDegrees,
        extent: extent,
        scale: scale,
      );

  @override
  ImageStreamCompleter load(ThumbnailProviderKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('uri=$uri, extent=$extent');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProviderKey key, DecoderCallback decode) async {
    try {
      final bytes = await ImageFileService.getThumbnail(key.uri, key.mimeType, key.rotationDegrees, extent, extent, taskKey: _cancellationKey);
      if (bytes == null) {
        throw StateError('$uri ($mimeType) loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with uri=$uri, error=$error');
      throw StateError('$mimeType decoding failed');
    }
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, ThumbnailProviderKey key, ImageErrorListener handleError) {
    ImageFileService.resumeThumbnail(_cancellationKey);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => ImageFileService.cancelThumbnail(_cancellationKey);
}

class ThumbnailProviderKey {
  final String uri;
  final String mimeType;
  final int rotationDegrees;
  final double extent;
  final double scale;

  ThumbnailProviderKey({
    @required this.uri,
    @required this.mimeType,
    @required this.rotationDegrees,
    @required this.extent,
    this.scale,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ThumbnailProviderKey && other.uri == uri && other.mimeType == mimeType && other.rotationDegrees == rotationDegrees && other.extent == extent && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(uri, mimeType, rotationDegrees, extent, scale);

  @override
  String toString() {
    return 'ThumbnailProviderKey{uri=$uri, mimeType=$mimeType, rotationDegrees=$rotationDegrees, extent=$extent, scale=$scale}';
  }
}
