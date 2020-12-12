package deckers.thibault.aves.metadata

object Geotiff {
    // ModelPixelScaleTag (optional)
    // Tag = 33550 (830E.H)
    // Type = DOUBLE
    // Count = 3
    const val TAG_MODEL_PIXEL_SCALE = 0x830e

    // ModelTiepointTag (conditional)
    // Tag = 33922 (8482.H)
    // Type = DOUBLE
    // Count = 6*K, K = number of tiepoints
    const val TAG_MODEL_TIEPOINT = 0x8482

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
    val TAG_GEO_ASCII_PARAMS = 0x87b1

    private val tagNameMap = hashMapOf(
        TAG_GEO_ASCII_PARAMS to "Geo Ascii Params",
        TAG_GEO_DOUBLE_PARAMS to "Geo Double Params",
        TAG_GEO_KEY_DIRECTORY to "Geo Key Directory",
        TAG_MODEL_PIXEL_SCALE to "Model Pixel Scale",
        TAG_MODEL_TIEPOINT to "Model Tiepoint",
        TAG_MODEL_TRANSFORMATION to "Model Transformation",
    )
    
    fun getTagName(tag: Int): String? {
        return tagNameMap[tag]
    }
}