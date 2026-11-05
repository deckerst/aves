import 'dart:collection';

import 'package:material_ui/material_ui.dart';

class const MetadataDirectory(
  final String name,
  final SplayTreeMap<String, String> allTags, {
  SplayTreeMap<String, String>? tags,
  final Color? color,
  final String? parent,
  final int? index,
}) {
  final SplayTreeMap<String, String> tags = tags ?? allTags;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const coverDirectory = 'Cover'; // custom
  static const c2paDirectory = 'Content Credentials'; // custom
  static const geoTiffDirectory = 'GeoTIFF'; // custom
  static const mediaDirectory = 'Media'; // custom
  static const mpfImageDirectoryPrefix = 'MPF Image #'; // custom

  MetadataDirectory filterKeys(bool Function(String key) testKey) {
    final filteredTags = SplayTreeMap.of(Map.fromEntries(allTags.entries.where((kv) => testKey(kv.key))));
    return MetadataDirectory(
      name,
      tags,
      tags: filteredTags,
      color: color,
      parent: parent,
      index: index,
    );
  }
}
