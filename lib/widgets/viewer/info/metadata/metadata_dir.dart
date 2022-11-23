import 'dart:collection';

import 'package:flutter/material.dart';

class MetadataDirectory {
  final String name;
  final Color? color;
  final String? parent;
  final int? index;
  final SplayTreeMap<String, String> allTags;
  final SplayTreeMap<String, String> tags;

  // special directory names
  static const exifThumbnailDirectory = 'Exif Thumbnail'; // from metadata-extractor
  static const xmpDirectory = 'XMP'; // from metadata-extractor
  static const mediaDirectory = 'Media'; // custom
  static const coverDirectory = 'Cover'; // custom
  static const geoTiffDirectory = 'GeoTIFF'; // custom

  const MetadataDirectory(
    this.name,
    this.allTags, {
    SplayTreeMap<String, String>? tags,
    this.color,
    this.parent,
    this.index,
  }) : tags = tags ?? allTags;

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
