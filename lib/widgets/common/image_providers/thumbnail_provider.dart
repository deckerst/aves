import 'dart:ui' as ui show Codec;

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThumbnailProvider extends ImageProvider<ThumbnailProviderKey> {
  final ThumbnailProviderKey key;

  ThumbnailProvider(this.key) : assert(key != null);

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
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('uri=${key.uri}, extent=${key.extent}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ThumbnailProviderKey key, DecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    try {
      final bytes = await ImageFileService.getThumbnail(
        uri,
        mimeType,
        key.dateModifiedSecs,
        key.rotationDegrees,
        key.isFlipped,
        key.extent,
        key.extent,
        taskKey: key,
      );
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
    ImageFileService.resumeLoading(key);
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  void pause() => ImageFileService.cancelThumbnail(key);
}

class ThumbnailProviderKey {
  final String uri, mimeType;
  final int dateModifiedSecs, rotationDegrees;
  final bool isFlipped;
  final double extent, scale;

  const ThumbnailProviderKey({
    @required this.uri,
    @required this.mimeType,
    @required this.dateModifiedSecs,
    @required this.rotationDegrees,
    @required this.isFlipped,
    this.extent = 0,
    this.scale = 1,
  })  : assert(uri != null),
        assert(mimeType != null),
        assert(dateModifiedSecs != null),
        assert(rotationDegrees != null),
        assert(isFlipped != null),
        assert(extent != null),
        assert(scale != null);

  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  factory ThumbnailProviderKey.fromEntry(ImageEntry entry, {double extent = 0}) {
    return ThumbnailProviderKey(
      uri: entry.uri,
      mimeType: entry.mimeType,
      // `dateModifiedSecs` can be missing in viewer mode
      dateModifiedSecs: entry.dateModifiedSecs ?? -1,
      rotationDegrees: entry.rotationDegrees,
      isFlipped: entry.isFlipped,
      extent: extent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ThumbnailProviderKey && other.uri == uri && other.extent == extent && other.mimeType == mimeType && other.dateModifiedSecs == dateModifiedSecs && other.rotationDegrees == rotationDegrees && other.isFlipped == isFlipped && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(
        uri,
        mimeType,
        dateModifiedSecs,
        rotationDegrees,
        isFlipped,
        extent,
        scale,
      );

  @override
  String toString() {
    return 'ThumbnailProviderKey{uri=$uri, mimeType=$mimeType, dateModifiedSecs=$dateModifiedSecs, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, extent=$extent, scale=$scale}';
  }
}
