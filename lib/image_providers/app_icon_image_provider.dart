import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
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
  ImageStreamCompleter loadImage(AppIconImageKey key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('packageName=$packageName, size=$size');
      },
    );
  }

  Future<ui.Codec> _loadAsync(AppIconImageKey key, ImageDecoderCallback decode) async {
    try {
      final descriptor = await appService.getAppIcon(key.packageName, key.size);
      if (descriptor == null) {
        throw UnreportedStateError('$packageName app icon decoding failed');
      }
      return descriptor.instantiateCodec();
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with packageName=$packageName, error=$error');
      throw UnreportedStateError('$packageName app icon decoding failed');
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
