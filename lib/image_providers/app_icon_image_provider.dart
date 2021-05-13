import 'dart:ui' as ui show Codec;

import 'package:aves/services/android_app_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppIconImage extends ImageProvider<AppIconImageKey> {
  const AppIconImage({
    required this.packageName,
    required this.size,
    this.scale = 1.0,
  });

  final String packageName;
  final double size;
  final double scale;

  @override
  Future<AppIconImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppIconImageKey>(AppIconImageKey(
      packageName: packageName,
      size: size,
      scale: scale,
    ));
  }

  @override
  ImageStreamCompleter load(AppIconImageKey key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('packageName=$packageName, size=$size');
      },
    );
  }

  Future<ui.Codec> _loadAsync(AppIconImageKey key, DecoderCallback decode) async {
    try {
      final bytes = await AndroidAppService.getAppIcon(key.packageName, key.size);
      if (bytes.isEmpty) {
        throw StateError('$packageName app icon loading failed');
      }
      return await decode(bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with packageName=$packageName, error=$error');
      throw StateError('$packageName app icon decoding failed');
    }
  }
}

class AppIconImageKey {
  final String packageName;
  final double size;
  final double scale;

  const AppIconImageKey({
    required this.packageName,
    required this.size,
    this.scale = 1.0,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AppIconImageKey && other.packageName == packageName && other.size == size && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(packageName, size, scale);
}
