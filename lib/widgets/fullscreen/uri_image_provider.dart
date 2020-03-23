import 'dart:typed_data';
import 'dart:ui' as ui show Codec;

import 'package:aves/model/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UriImage extends ImageProvider<UriImage> {
  const UriImage(this.uri, {this.scale = 1.0})
      : assert(uri != null),
        assert(scale != null);

  final String uri;

  final double scale;

  @override
  Future<UriImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<UriImage>(this);
  }

  @override
  ImageStreamCompleter load(UriImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('Uri: $uri');
      },
    );
  }

  Future<ui.Codec> _loadAsync(UriImage key, DecoderCallback decode) async {
    assert(key == this);

    final Uint8List bytes = await ImageFileService.readAsBytes(uri);
    if (bytes.lengthInBytes == 0) {
      return null;
    }

    return await decode(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is UriImage && other.uri == uri && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(uri, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'UriImage')}("$uri", scale: $scale)';
}
