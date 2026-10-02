import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

enum EmbeddedDataSource { googleDevice, motionPhotoVideo, mpf, videoCover, xmp }

@immutable
class const OpenEmbeddedDataNotification._private({
  required final EmbeddedDataSource source,
  final List<Object?>? propPath,
  final String? mimeType,
  final String? dataUri,
  final int? mpfId,
}) extends Notification {
  factory googleDevice({
    required String dataUri,
  }) => OpenEmbeddedDataNotification._private(
    source: .googleDevice,
    dataUri: dataUri,
  );

  factory motionPhotoVideo() => const OpenEmbeddedDataNotification._private(
    source: .motionPhotoVideo,
  );

  factory mpf(int id) => OpenEmbeddedDataNotification._private(
    source: .mpf,
    mpfId: id,
  );

  factory videoCover() => const OpenEmbeddedDataNotification._private(
    source: .videoCover,
  );

  factory xmp({
    required List<Object?> propPath,
    required String mimeType,
  }) => OpenEmbeddedDataNotification._private(
    source: .xmp,
    propPath: propPath,
    mimeType: mimeType,
  );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{source=$source, propPath=$propPath, mimeType=$mimeType, dataUri=$dataUri, index=$mpfId}';
}
