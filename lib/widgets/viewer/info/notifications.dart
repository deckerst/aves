import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackUpNotification extends Notification {}

class FilterSelectedNotification extends Notification {
  final CollectionFilter filter;

  const FilterSelectedNotification(this.filter);
}

class EntryDeletedNotification extends Notification {
  final AvesEntry entry;

  const EntryDeletedNotification(this.entry);
}

class OpenTempEntryNotification extends Notification {
  final AvesEntry entry;

  const OpenTempEntryNotification({
    required this.entry,
  });

  @override
  String toString() => '$runtimeType#${shortHash(this)}{entry=$entry}';
}

enum EmbeddedDataSource { motionPhotoVideo, videoCover, xmp }

class OpenEmbeddedDataNotification extends Notification {
  final EmbeddedDataSource source;
  final String? propPath;
  final String? mimeType;

  const OpenEmbeddedDataNotification._private({
    required this.source,
    this.propPath,
    this.mimeType,
  });

  factory OpenEmbeddedDataNotification.motionPhotoVideo() => OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.motionPhotoVideo,
      );

  factory OpenEmbeddedDataNotification.videoCover() => OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.videoCover,
      );

  factory OpenEmbeddedDataNotification.xmp({
    required String propPath,
    required String mimeType,
  }) =>
      OpenEmbeddedDataNotification._private(
        source: EmbeddedDataSource.xmp,
        propPath: propPath,
        mimeType: mimeType,
      );

  @override
  String toString() => '$runtimeType#${shortHash(this)}{source=$source, propPath=$propPath, mimeType=$mimeType}';
}
