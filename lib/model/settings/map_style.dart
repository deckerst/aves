// browse providers at https://leaflet-extras.github.io/leaflet-providers/preview/
enum EntryMapStyle { googleNormal, googleHybrid, googleTerrain, osmHot, stamenToner, stamenWatercolor }

extension ExtraEntryMapStyle on EntryMapStyle {
  String get name {
    switch (this) {
      case EntryMapStyle.googleNormal:
        return 'Google Maps';
      case EntryMapStyle.googleHybrid:
        return 'Google Maps (Hybrid)';
      case EntryMapStyle.googleTerrain:
        return 'Google Maps (Terrain)';
      case EntryMapStyle.osmHot:
        return 'Humanitarian OSM';
      case EntryMapStyle.stamenToner:
        return 'Stamen Toner';
      case EntryMapStyle.stamenWatercolor:
        return 'Stamen Watercolor';
      default:
        return toString();
    }
  }

  bool get isGoogleMaps {
    switch (this) {
      case EntryMapStyle.googleNormal:
      case EntryMapStyle.googleHybrid:
      case EntryMapStyle.googleTerrain:
        return true;
      default:
        return false;
    }
  }
}
