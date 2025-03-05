import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class DescriptorImageProvider extends ImageProvider<DescriptorImageProvider> {
  const DescriptorImageProvider(this.descriptor, {this.scale = 1.0});

  final ui.ImageDescriptor descriptor;
  final double scale;

  @override
  Future<DescriptorImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DescriptorImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(DescriptorImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: 'DescriptorImageProvider(${describeIdentity(key.descriptor)})',
    );
  }

  Future<ui.Codec> _loadAsync(DescriptorImageProvider key, {required ImageDecoderCallback decode}) async {
    assert(key == this);
    return descriptor.instantiateCodec();
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DescriptorImageProvider && other.descriptor == descriptor && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(descriptor.hashCode, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'DescriptorImageProvider')}(${describeIdentity(descriptor)}, scale: ${scale.toStringAsFixed(1)})';
}
