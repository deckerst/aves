package deckers.thibault.aves.metadata

/*
Exif tags missing from `metadata-extractor`

Photoshop
https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
https://www.adobe.io/content/dam/udp/en/open/standards/tiff/TIFFphotoshop.pdf
 */
object ExifTags {
    private const val TAG_X_POSITION = 0x011e
    private const val TAG_Y_POSITION = 0x011f
    private const val TAG_T4_OPTIONS = 0x0124
    private const val TAG_T6_OPTIONS = 0x0125
    private const val TAG_COLOR_MAP = 0x0140
    private const val TAG_EXTRA_SAMPLES = 0x0152
    private const val TAG_SAMPLE_FORMAT = 0x0153
    private const val TAG_RATING_PERCENT = 0x4749
    private const val SONY_RAW_FILE_TYPE = 0x7000
    private const val SONY_TONE_CURVE = 0x7010
    private const val TAG_MATTEING = 0x80e3

    // sensing method (0x9217) redundant with sensing method (0xA217)
    private const val TAG_SENSING_METHOD = 0x9217
    private const val TAG_IMAGE_SOURCE_DATA = 0x935c
    private const val TAG_GDAL_METADATA = 0xa480
    private const val TAG_GDAL_NO_DATA = 0xa481

    private val tagNameMap = hashMapOf(
        TAG_X_POSITION to "X Position",
        TAG_Y_POSITION to "Y Position",
        TAG_T4_OPTIONS to "T4 Options",
        TAG_T6_OPTIONS to "T6 Options",
        TAG_COLOR_MAP to "Color Map",
        TAG_EXTRA_SAMPLES to "Extra Samples",
        TAG_SAMPLE_FORMAT to "Sample Format",
        TAG_RATING_PERCENT to "Rating Percent",
        SONY_RAW_FILE_TYPE to "Sony Raw File Type",
        SONY_TONE_CURVE to "Sony Tone Curve",
        TAG_MATTEING to "Matteing",
        TAG_SENSING_METHOD to "Sensing Method (0x9217)",
        TAG_IMAGE_SOURCE_DATA to "Image Source Data",
        TAG_GDAL_METADATA to "GDAL Metadata",
        TAG_GDAL_NO_DATA to "GDAL No Data",
    ).apply {
        putAll(DngTags.tagNameMap)
        putAll(ExifGeoTiffTags.tagNameMap)
    }

    fun isDngTag(tag: Int) = DngTags.tags.contains(tag)

    fun isGeoTiffTag(tag: Int) = ExifGeoTiffTags.tags.contains(tag)

    fun getTagName(tag: Int): String? {
        return tagNameMap[tag]
    }
}