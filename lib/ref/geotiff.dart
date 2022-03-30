class GeoTiffExifTags {
  static const int modelPixelScale = 0x830e;
  static const int modelTiePoints = 0x8482;
  static const int modelTransformation = 0x85d8;
  static const int geoKeyDirectory = 0x87af;
  static const int geoDoubleParams = 0x87b0;
  static const int geoAsciiParams = 0x87b1;
}

class GeoTiffKeys {
  static const int modelType = 0x0400;
  static const int rasterType = 0x0401;
  static const int geographicType = 0x0800;
  static const int geogAngularUnits = 0x0806;
  static const int projCSType = 0x0c00;
  static const int projection = 0x0c02;
  static const int projCoordinateTransform = 0x0c03;
  static const int projLinearUnits = 0x0c04;
}
