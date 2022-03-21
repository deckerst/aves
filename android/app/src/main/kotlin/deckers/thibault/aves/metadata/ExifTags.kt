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
    Photoshop
    https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
    https://www.adobe.io/content/dam/udp/en/open/standards/tiff/TIFFphotoshop.pdf
     */

    // ImageSourceData
    // Tag = 37724 (935C.H)
    // Type = UNDEFINED
    private const val TAG_IMAGE_SOURCE_DATA = 0x935c

    private val tagNameMap = hashMapOf(
        TAG_X_POSITION to "X Position",
        TAG_Y_POSITION to "Y Position",
        TAG_COLOR_MAP to "Color Map",
        TAG_EXTRA_SAMPLES to "Extra Samples",
        TAG_SAMPLE_FORMAT to "Sample Format",
        TAG_RATING_PERCENT to "Rating Percent",
        // SGI
        TAG_MATTEING to "Matteing",
        // Photoshop
        TAG_IMAGE_SOURCE_DATA to "Image Source Data",
    ).apply {
        putAll(DngTags.tagNameMap)
        putAll(GeoTiffTags.tagNameMap)
    }

    fun isDngTag(tag: Int) = DngTags.tags.contains(tag)

    fun isGeoTiffTag(tag: Int) = GeoTiffTags.tags.contains(tag)

    fun getTagName(tag: Int): String? {
        return tagNameMap[tag]
    }
}