import 'dart:async';
import 'dart:ui' as ui show Codec;

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        yield ErrorDescription('uri=${key.uri}, rect=${key.rect}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(RegionProviderKey key, DecoderCallback decode) async {
    final uri = key.uri;
    final mimeType = key.mimeType;
    try {
      final bytes = await ImageFileService.getRegion(
        uri,
        mimeType,
        key.rotationDegrees,
        key.isFlipped,
        key.sampleSize,
        key.rect,
        taskKey: key,
      );
      if (bytes == null) {
        throw StateError('$uri ($mimeType) region loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw StateError('$mimeType region decoding failed');
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
  final String uri, mimeType;
  final int rotationDegrees, sampleSize;
  final bool isFlipped;
  final Rect rect;
  final double scale;

  const RegionProviderKey({
    @required this.uri,
    @required this.mimeType,
    @required this.rotationDegrees,
    @required this.isFlipped,
    @required this.sampleSize,
    @required this.rect,
    this.scale = 1.0,
  })  : assert(uri != null),
        assert(mimeType != null),
        assert(rotationDegrees != null),
        assert(isFlipped != null),
        assert(sampleSize != null),
        assert(rect != null),
        assert(scale != null);

  // do not store the entry as it is, because the key should be constant
  // but the entry attributes may change over time
  factory RegionProviderKey.fromEntry(
    ImageEntry entry, {
    @required int sampleSize,
    @required Rect rect,
  }) {
    return RegionProviderKey(
      uri: entry.uri,
      mimeType: entry.mimeType,
      rotationDegrees: entry.rotationDegrees,
      isFlipped: entry.isFlipped,
      sampleSize: sampleSize,
      rect: rect,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RegionProviderKey && other.uri == uri && other.mimeType == mimeType && other.rotationDegrees == rotationDegrees && other.isFlipped == isFlipped && other.sampleSize == sampleSize && other.rect == rect && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(
        uri,
        mimeType,
        rotationDegrees,
        isFlipped,
        mimeType,
        sampleSize,
        rect,
        scale,
      );

  @override
  String toString() {
    return 'RegionProviderKey(uri=$uri, mimeType=$mimeType, rotationDegrees=$rotationDegrees, isFlipped=$isFlipped, sampleSize=$sampleSize, rect=$rect, scale=$scale)';
  }
}
