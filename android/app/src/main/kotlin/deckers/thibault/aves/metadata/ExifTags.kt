package deckers.thibault.aves.metadata

// Exif tags missing from `metadata-extractor`
object ExifTags {
    // XPosition
    // Tag = 286 (011E.H)
    private const val TAG_X_POSITION = 0x011e

    // YPosition
    // Tag = 287 (011F.H)
    private const val TAG_Y_POSITION = 0x011f

    // ColorMap
    // Tag = 320 (0140.H)
    private const val TAG_COLOR_MAP = 0x0140

    // ExtraSamples
    // Tag = 338 (0152.H)
    // values:
    // EXTRASAMPLE_UNSPECIFIED	0 // unspecified data
    // EXTRASAMPLE_ASSOCALPHA	1 // associated alpha data
    // EXTRASAMPLE_UNASSALPHA	2 // unassociated alpha data
    private const val TAG_EXTRA_SAMPLES = 0x0152

    // SampleFormat
    // Tag = 339 (0153.H)
    // values:
    // SAMPLEFORMAT_UINT            1 // unsigned integer data
    // SAMPLEFORMAT_INT		        2 // signed integer data
    // SAMPLEFORMAT_IEEEFP		    3 // IEEE floating point data
    // SAMPLEFORMAT_VOID		    4 // untyped data
    // SAMPLEFORMAT_COMPLEXINT	    5 // complex signed int
    // SAMPLEFORMAT_COMPLEXIEEEFP	6 // complex ieee floating
    private const val TAG_SAMPLE_FORMAT = 0x0153


    // Rating tag used by Windows, value in percent
    // Tag = 18249 (4749.H)
    // Type = SHORT
    private const val TAG_RATING_PERCENT = 0x4749

    /*
    SGI
    tags 32995-32999
     */

    // Matteing
    // Tag = 32995 (80E3.H)
    // obsoleted by the 6.0 ExtraSamples (338)
    private const val TAG_MATTEING = 0x80e3

    /*
    GeoTIFF
     */

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
    private const val TAG_GEO_DOUBLE_PARAMS = 0x87b0

    // GeoAsciiParamsTag (optional)
    // Tag = 34737 (87B1.H)
    // Type = ASCII
    // Count = variable
    private const val TAG_GEO_ASCII_PARAMS = 0x87b1

    /*
    Photoshop
    https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
    https://www.adobe.io/content/dam/udp/en/open/standards/tiff/TIFFphotoshop.pdf
     */

    // ImageSourceData
    // Tag = 37724 (935C.H)
    // Type = UNDEFINED
    private const val TAG_IMAGE_SOURCE_DATA = 0x935c

    /*
    DNG
    https://www.adobe.com/content/dam/acom/en/products/photoshop/pdfs/dng_spec_1.4.0.0.pdf
     */

    // CameraSerialNumber
    // Tag = 50735 (C62F.H)
    // Type = ASCII
    // Count = variable
    private const val TAG_CAMERA_SERIAL_NUMBER = 0xc62f

    // OriginalRawFileName (optional)
    // Tag = 50827 (C68B.H)
    // Type = ASCII or BYTE
    // Count = variable
    private const val TAG_ORIGINAL_RAW_FILE_NAME = 0xc68b

    private val geotiffTags = listOf(
        TAG_GEO_ASCII_PARAMS,
        TAG_GEO_DOUBLE_PARAMS,
        TAG_GEO_KEY_DIRECTORY,
        TAG_MODEL_PIXEL_SCALE,
        TAG_MODEL_TIEPOINT,
        TAG_MODEL_TRANSFORMATION,
    )

    private val tagNameMap = hashMapOf(
        TAG_X_POSITION to "X Position",
        TAG_Y_POSITION to "Y Position",
        TAG_COLOR_MAP to "Color Map",
        TAG_EXTRA_SAMPLES to "Extra Samples",
        TAG_SAMPLE_FORMAT to "Sample Format",
        TAG_RATING_PERCENT to "Rating Percent",
        // SGI
        TAG_MATTEING to "Matteing",
        // GeoTIFF
        TAG_GEO_ASCII_PARAMS to "Geo Ascii Params",
        TAG_GEO_DOUBLE_PARAMS to "Geo Double Params",
        TAG_GEO_KEY_DIRECTORY to "Geo Key Directory",
        TAG_MODEL_PIXEL_SCALE to "Model Pixel Scale",
        TAG_MODEL_TIEPOINT to "Model Tiepoint",
        TAG_MODEL_TRANSFORMATION to "Model Transformation",
        // Photoshop
        TAG_IMAGE_SOURCE_DATA to "Image Source Data",
        // DNG
        TAG_CAMERA_SERIAL_NUMBER to "Camera Serial Number",
        TAG_ORIGINAL_RAW_FILE_NAME to "Original Raw File Name",
    )

    fun isGeoTiffTag(tag: Int) = geotiffTags.contains(tag)

    fun getTagName(tag: Int): String? {
        return tagNameMap[tag]
    }
}