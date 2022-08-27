import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum EmbeddedDataSource { motionPhotoVideo, videoCover, xmp }

@immutable
class OpenEmbeddedDataNotification extends Notification {
  final EmbeddedDataSource source;
  final List<dynamic>? props;
  final String? mimeType;

  const OpenEmbeddedDataNotification._private({
    required this.source,
    this.props,
    this.mimeType,
  });

  factory OpenEmbeddedDataNotification.motionPhotoVideo() => const OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.motionPhotoVideo,
      );

  factory OpenEmbeddedDataNotification.videoCover() => const OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.videoCover,
      );

  factory OpenEmbeddedDataNotification.xmp({
    required List<dynamic> props,
    required String mimeType,
  }) =>
      OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.xmp,
        props: props,
        mimeType: mimeType,
      );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{source=$source, props=$props, mimeType=$mimeType}';
}
