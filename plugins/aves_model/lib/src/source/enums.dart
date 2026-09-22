enum SourceState { loading, cataloguing, locatingCountries, locatingPlaces, ready }

enum SortFactor {
  // common
  date,
  size,
  path,
  // chips only
  chipName,
  count,
  // entry only
  albumItemName,
  rating,
  duration,
}

enum ChipSectionFactor { none, importance, mimeType, volume }

enum EntrySectionFactor {
  none,
  album,
  month,
  day,
  // unselectable, used by some sort factors
  name,
  rating,
}

enum TileLayout { mosaic, grid, list, calendar }
