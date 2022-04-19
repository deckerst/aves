package deckers.thibault.aves.metadata

object GeoTiffKeys {
    // not a standard tag
    const val GEOTIFF_VERSION = 0

    private const val MODEL_TYPE = 0x0400
    private const val RASTER_TYPE = 0x0401
    private const val CITATION = 0x0402
    private const val GEOG_TYPE = 0x0800
    private const val GEOG_CITATION = 0x0801
    private const val GEOG_GEODETIC_DATUM = 0x0802
    private const val GEOG_LINEAR_UNITS = 0x0804
    private const val GEOG_ANGULAR_UNITS = 0x0806
    private const val GEOG_ELLIPSOID = 0x0808
    private const val GEOG_SEMI_MAJOR_AXIS = 0x0809
    private const val GEOG_SEMI_MINOR_AXIS = 0x080a
    private const val GEOG_INV_FLATTENING = 0x080b
    private const val PROJ_CS_TYPE = 0x0c00
    private const val PROJ_CS_CITATION = 0x0c01
    private const val PROJECTION = 0x0c02
    private const val PROJ_COORD_TRANS = 0x0c03
    private const val PROJ_LINEAR_UNITS = 0x0c04
    private const val PROJ_STD_PARALLEL_1 = 0x0c06
    private const val PROJ_STD_PARALLEL_2 = 0x0c07
    private const val PROJ_NAT_ORIGIN_LONG = 0x0c08
    private const val PROJ_NAT_ORIGIN_LAT = 0x0c09
    private const val PROJ_FALSE_EASTING = 0x0c0a
    private const val PROJ_FALSE_NORTHING = 0x0c0b
    private const val PROJ_SCALE_AT_NAT_ORIGIN = 0x0c14
    private const val PROJ_AZIMUTH_ANGLE = 0x0c16
    private const val VERTICAL_UNITS = 0x1003

    private val tagNameMap = hashMapOf(
        GEOTIFF_VERSION to "GeoTIFF Version",
        MODEL_TYPE to "Model Type",
        RASTER_TYPE to "Raster Type",
        CITATION to "Citation",
        GEOG_TYPE to "Geographic Type",
        GEOG_CITATION to "Geographic Citation",
        GEOG_GEODETIC_DATUM to "Geographic Geodetic Datum",
        GEOG_LINEAR_UNITS to "Geographic Linear Units",
        GEOG_ANGULAR_UNITS to "Geographic Angular Units",
        GEOG_ELLIPSOID to "Geographic Ellipsoid",
        GEOG_SEMI_MAJOR_AXIS to "Semi-major axis",
        GEOG_SEMI_MINOR_AXIS to "Semi-minor axis",
        GEOG_INV_FLATTENING to "Inv. Flattening",
        PROJ_CS_TYPE to "Projected Coordinate System Type",
        PROJ_CS_CITATION to "Projected Coordinate System Citation",
        PROJECTION to "Projection",
        PROJ_COORD_TRANS to "Projected Coordinate Transform",
        PROJ_LINEAR_UNITS to "Projection Linear Units",
        PROJ_STD_PARALLEL_1 to "Projection Standard Parallel 1",
        PROJ_STD_PARALLEL_2 to "Projection Standard Parallel 2",
        PROJ_NAT_ORIGIN_LONG to "Projection Natural Origin Longitude",
        PROJ_NAT_ORIGIN_LAT to "Projection Natural Origin Latitude",
        PROJ_FALSE_EASTING to "Projection False Easting",
        PROJ_FALSE_NORTHING to "Projection False Northing",
        PROJ_SCALE_AT_NAT_ORIGIN to "Projection Scale at Natural Origin",
        PROJ_AZIMUTH_ANGLE to "Projection Azimuth Angle",
        VERTICAL_UNITS to "Vertical Units",
    )

    fun getTagName(tag: Int): String? {
        return tagNameMap[tag]
    }
}

object ExifGeoTiffTags {
    // ModelPixelScaleTag (optional)
    // Tag = 33550 (830E.H)
    // Type = DOUBLE
    // Count = 3
    const val TAG_MODEL_PIXEL_SCALE = 0x830e

    // ModelTiePointTag (conditional)
    // Tag = 33922 (8482.H)
    // Type = DOUBLE
    // Count = 6*K, K = number of tie points
    const val TAG_MODEL_TIE_POINT = 0x8482

    // ModelTransformationTag (conditional)
    // Tag = 34264 (85D8.H)
    // Type = DOUBLE
    // Count = 16
    const val TAG_MODEL_TRANSFORMATION = 0x85d8

    // GeoKeyDirectoryTag (mandatory)
    // Tag = 34735 (87AF.H)
    // Type = UNSIGNED SHORT
    // Count = variable, >= 4
    const val TAG_GEO_KEY_DIRECTORY = 0x87af

    // GeoDoubleParamsTag (optional)
    // Tag = 34736 (87BO.H)
    // Type = DOUBLE
    // Count = variable
    const val TAG_GEO_DOUBLE_PARAMS = 0x87b0

    // GeoAsciiParamsTag (optional)
    // Tag = 34737 (87B1.H)
    // Type = ASCII
    // Count = variable
    const val TAG_GEO_ASCII_PARAMS = 0x87b1

    val tagNameMap = hashMapOf(
        TAG_GEO_ASCII_PARAMS to "Geo Ascii Params",
        TAG_GEO_DOUBLE_PARAMS to "Geo Double Params",
        TAG_GEO_KEY_DIRECTORY to "Geo Key Directory",
        TAG_MODEL_PIXEL_SCALE to "Model Pixel Scale",
        TAG_MODEL_TIE_POINT to "Model Tie Points",
        TAG_MODEL_TRANSFORMATION to "Model Transformation",
    )

    val tags = tagNameMap.keys
}
