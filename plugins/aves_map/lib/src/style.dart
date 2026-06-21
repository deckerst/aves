import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// OSM raster tile providers: https://wiki.openstreetmap.org/wiki/Raster_tile_providers
// OSM vector tile providers: https://wiki.openstreetmap.org/wiki/Vector_tiles#Providers
// Leaflet providers preview: https://leaflet-extras.github.io/leaflet-providers/preview/
// OpenMapTiles styles: https://openmaptiles.org/styles/
// Examples: https://github.com/deckerst/aves/wiki/Custom-maps
class EntryMapStyle extends Equatable {
  final String key;
  final String? name;
  final bool isRaster;
  final String? url; // not strictly a `Uri` as it may contain templates like `{x}`
  final List<String> subdomains;
  final String? userAgent;
  final bool needMobileService;
  final bool isHeavy;
  final double minZoom, maxZoom;

  @override
  List<Object?> get props => [key, name, isRaster, url];

  const EntryMapStyle({
    required this.key,
    this.name,
    this.isRaster = true,
    this.url,
    List<String>? subdomains,
    this.userAgent,
    this.needMobileService = false,
    this.isHeavy = false,
    this.minZoom = 2,
    this.maxZoom = 22,
  }) : subdomains = subdomains ?? const ['a', 'b', 'c'];

  static EntryMapStyle? fromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, Object?>) {
        return _fromMap(jsonMap);
      }
      debugPrint('failed to parse style from json=$jsonString');
    } catch (error) {
      // no need for stack
      debugPrint('failed to parse style from json=$jsonString error=$error');
    }
    return null;
  }

  String toJson() => jsonEncode(_toMap());

  static EntryMapStyle _fromMap(Map<String, Object?> jsonMap) {
    return EntryMapStyle(
      key: jsonMap['key'] as String,
      name: jsonMap['name'] as String?,
      isRaster: jsonMap['isRaster'] as bool,
      url: jsonMap['url'] as String?,
      subdomains: (jsonMap['subdomains'] as List?)?.cast<String>(),
      userAgent: jsonMap['userAgent'] as String?,
      needMobileService: jsonMap['needMobileService'] as bool,
      isHeavy: jsonMap['isHeavy'] as bool,
    );
  }

  Map<String, Object?> _toMap() {
    return {
      'key': key,
      'name': name,
      'isRaster': isRaster,
      'url': url,
      'subdomains': subdomains,
      'userAgent': userAgent,
      'needMobileService': needMobileService,
      'isHeavy': isHeavy,
    };
  }
}

class EntryMapStyles {
  // Google

  static const googleNormal = EntryMapStyle(
    key: 'googleNormal',
    needMobileService: true,
    isHeavy: true,
  );

  static const googleHybrid = EntryMapStyle(
    key: 'googleHybrid',
    needMobileService: true,
    isHeavy: true,
  );

  static const googleTerrain = EntryMapStyle(
    key: 'googleTerrain',
    needMobileService: true,
    isHeavy: true,
  );

  // Vector (OpenMapTiles)

  static const osmLiberty = EntryMapStyle(
    key: 'osmLiberty',
    isRaster: false,
  );

  // Raster (Leaflet)

  static const openTopoMap = EntryMapStyle(
    key: 'openTopoMap',
    url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    // as of 2026/06/01, tiles are not rendered at zoom > 17
    maxZoom: 16, // retina mode will give +1
  );

  static const osmHot = EntryMapStyle(
    key: 'osmHot',
    url: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    // as of 2026/06/01, tiles are upscaled at zoom > 19
    maxZoom: 18, // retina mode will give +1
  );

  static const stamenWatercolor = EntryMapStyle(
    key: 'stamenWatercolor',
    url: 'https://watercolormaps.collection.cooperhewitt.org/tile/watercolor/{z}/{x}/{y}.jpg',
    // as of 2026/06/01, tiles are upscaled at zoom > 19
    maxZoom: 18, // retina mode will give +1
  );

  // default styles that do not need mobile services
  static List<EntryMapStyle> baseStyles = [
    // Vector (OpenMapTiles)
    // osmLiberty, // TODO TLAD find alternative vector tile host
    // Raster (Leaflet)
    openTopoMap,
    osmHot,
    stamenWatercolor,
  ];
}
