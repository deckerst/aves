import 'dart:typed_data';
import 'dart:ui' as ui show Codec;

import 'package:aves/utils/android_app_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppIconImage extends ImageProvider<AppIconImageKey> {
  const AppIconImage({
    @required this.packageName,
    @required this.size,
    this.scale = 1.0,
  })  : assert(packageName != null),
        assert(scale != null);

  final String packageName;
  final double size;
  final double scale;

  @override
  Future<AppIconImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppIconImageKey>(AppIconImageKey(
      packageName: packageName,
      sizePixels: (size * configuration.devicePixelRatio).round(),
      scale: scale,
    ));
  }

  @override
  ImageStreamCompleter load(AppIconImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('uri=$packageName, size=$size');
      },
    );
  }

  Future<ui.Codec> _loadAsync(AppIconImageKey key, DecoderCallback decode) async {
    final Uint8List bytes = await AndroidAppService.getAppIcon(key.packageName, key.sizePixels);
    if (bytes.lengthInBytes == 0) {
      return null;
    }

    return await decode(bytes);
  }
}

class AppIconImageKey {
  final String packageName;
  final int sizePixels;
  final double scale;

  const AppIconImageKey({
    @required this.packageName,
    @required this.sizePixels,
    this.scale,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AppIconImageKey && other.packageName == packageName && other.sizePixels == sizePixels && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(packageName, sizePixels, scale);
}
