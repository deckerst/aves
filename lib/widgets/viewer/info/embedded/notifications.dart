import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

enum EmbeddedDataSource { googleDevice, motionPhotoVideo, mpf, videoCover, xmp }

@immutable
class OpenEmbeddedDataNotification extends Notification {
  final EmbeddedDataSource source;
  final List<Object?>? props;
  final String? mimeType, dataUri;
  final int? mpfId;

  const new _private({
    required this.source,
    this.props,
    this.mimeType,
    this.dataUri,
    this.mpfId,
  });

  factory googleDevice({
    required String dataUri,
  }) => OpenEmbeddedDataNotification._private(
    source: EmbeddedDataSource.googleDevice,
    dataUri: dataUri,
  );

  factory motionPhotoVideo() => const OpenEmbeddedDataNotification._private(
    source: EmbeddedDataSource.motionPhotoVideo,
  );

  factory mpf(int id) => OpenEmbeddedDataNotification._private(
    source: EmbeddedDataSource.mpf,
    mpfId: id,
  );

  factory videoCover() => const OpenEmbeddedDataNotification._private(
    source: EmbeddedDataSource.videoCover,
  );

  factory xmp({
    required List<Object?> props,
    required String mimeType,
  }) => OpenEmbeddedDataNotification._private(
    source: EmbeddedDataSource.xmp,
    props: props,
    mimeType: mimeType,
  );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{source=$source, props=$props, mimeType=$mimeType, dataUri=$dataUri, index=$mpfId}';
}
