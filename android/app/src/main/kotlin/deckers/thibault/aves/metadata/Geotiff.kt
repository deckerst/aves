package deckers.thibault.aves.metadata

object Geotiff {
    // 33550
    // ModelPixelScaleTag (optional)
    val TAG_MODEL_PIXEL_SCALE = 0x830e

    // 33922
    // ModelTiepointTag (conditional)
    val TAG_MODEL_TIEPOINT = 0x8482

    // 34264
    // ModelTransformationTag (conditional)
    val TAG_MODEL_TRANSFORMATION = 0x85d8

    // 34735
    // GeoKeyDirectoryTag (mandatory)
    val TAG_GEO_KEY_DIRECTORY = 0x87af

    // 34736
    // GeoDoubleParamsTag (optional)
    val TAG_GEO_DOUBLE_PARAMS = 0x87b0

    // 34737
    // GeoAsciiParamsTag (optional)
    val TAG_GEO_ASCII_PARAMS = 0x87b1
}