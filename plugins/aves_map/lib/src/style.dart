// OSM raster tile providers: https://wiki.openstreetmap.org/wiki/Raster_tile_providers
// OSM vector tile providers: https://wiki.openstreetmap.org/wiki/Vector_tiles#Providers
// Leaflet providers preview: https://leaflet-extras.github.io/leaflet-providers/preview/
// OpenMapTiles styles: https://openmaptiles.org/styles/
class EntryMapStyle {
  final String key;
  final String? name;
  final String? urlTemplate;
  final bool needMobileService;
  final bool isHeavy;

  const EntryMapStyle({
    required this.key,
    this.name,
    this.urlTemplate,
    this.needMobileService = false,
    this.isHeavy = false,
  });
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
  );

  // Raster (Leaflet)

  static const openTopoMap = EntryMapStyle(
    key: 'openTopoMap',
    urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
  );

  static const osmHot = EntryMapStyle(
    key: 'osmHot',
    urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
  );

  static const stamenWatercolor = EntryMapStyle(
    key: 'stamenWatercolor',
    urlTemplate: 'https://watercolormaps.collection.cooperhewitt.org/tile/watercolor/{z}/{x}/{y}.jpg',
  );

  static List<EntryMapStyle> all = [
    // Google
    googleNormal,
    googleHybrid,
    googleTerrain,
    // Vector (OpenMapTiles)
    osmLiberty,
    // Raster (Leaflet)
    openTopoMap,
    osmHot,
    stamenWatercolor,
  ];
}
