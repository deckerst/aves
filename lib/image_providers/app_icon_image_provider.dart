import 'dart:ui' as ui;

import 'package:aves/services/common/services.dart';
import 'package:aves_report/aves_report.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class const AppIconImage({
  required final String packageName,
  required final double size,
  final double scale = 1.0,
}) extends ImageProvider<AppIconImageKey> {
  @override
  Future<AppIconImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppIconImageKey>(
      AppIconImageKey(
        packageName: packageName,
        size: size,
        scale: scale,
      ),
    );
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
      return await descriptor.instantiateCodec();
    } catch (error) {
      debugPrint('$runtimeType _loadAsync failed with packageName=$packageName, error=$error');
      throw UnreportedStateError('$packageName app icon decoding failed');
    }
  }
}

@immutable
class const AppIconImageKey({
  required final String packageName,
  required final double size,
  final double scale = 1.0,
}) extends Equatable {
  @override
  List<Object?> get props => [packageName, size, scale];
}
