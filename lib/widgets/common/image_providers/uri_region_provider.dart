import 'dart:async';
import 'dart:ui' as ui show Codec;

import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

class UriRegion extends ImageProvider<UriRegion> {
  const UriRegion({
    @required this.uri,
    @required this.mimeType,
    @required this.rotationDegrees,
    @required this.isFlipped,
    @required this.sampleSize,
    @required this.rect,
    this.scale = 1.0,
  })  : assert(uri != null),
        assert(scale != null);

  final String uri, mimeType;
  final int rotationDegrees, sampleSize;
  final bool isFlipped;
  final Rect rect;
  final double scale;

  @override
  Future<UriRegion> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<UriRegion>(this);
  }

  @override
  ImageStreamCompleter load(UriRegion key, DecoderCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      scale: key.scale,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('uri=$uri, mimeType=$mimeType');
      },
    );
  }

  Future<ui.Codec> _loadAsync(UriRegion key, DecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    assert(key == this);

    try {
      final bytes = await ImageFileService.getRegion(
        uri,
        mimeType,
        rotationDegrees,
        isFlipped,
        sampleSize,
        rect,
      );
      if (bytes == null) {
        throw StateError('$uri ($mimeType) loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with mimeType=$mimeType, uri=$uri, error=$error');
      throw StateError('$mimeType decoding failed');
    } finally {
      unawaited(chunkEvents.close());
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is UriRegion && other.uri == uri && other.sampleSize == sampleSize && other.rect == rect && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(uri, sampleSize, rect, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'UriRegion')}(uri=$uri, mimeType=$mimeType, scale=$scale)';
}
