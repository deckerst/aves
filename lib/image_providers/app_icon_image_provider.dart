import 'dart:ui' as ui show Codec;

import 'package:aves/services/android_app_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

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
      return await decode(bytes.isEmpty ? kTransparentImage : bytes);
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with packageName=$packageName, error=$error');
      throw StateError('$packageName app icon decoding failed');
    }
  }
}

@immutable
class AppIconImageKey extends Equatable {
  final String packageName;
  final double size;
  final double scale;

  @override
  List<Object?> get props => [packageName, size, scale];

  const AppIconImageKey({
    required this.packageName,
    required this.size,
    this.scale = 1.0,
  });
}
