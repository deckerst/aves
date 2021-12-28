package deckers.thibault.aves.metadata

import com.drew.lang.Rational
import com.drew.lang.SequentialByteArrayReader
import com.drew.metadata.Directory
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.iptc.IptcReader
import com.drew.metadata.png.PngDirectory
import java.text.SimpleDateFormat
import java.util.*

object MetadataExtractorHelper {
    const val PNG_ITXT_DIR_NAME = "PNG-iTXt"
    private const val PNG_TEXT_DIR_NAME = "PNG-tEXt"
    const val PNG_TIME_DIR_NAME = "PNG-tIME"
    private const val PNG_ZTXT_DIR_NAME = "PNG-zTXt"

    val PNG_LAST_MODIFICATION_TIME_FORMAT = SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.ROOT)

    // Pattern to extract profile name, length, and text data
    // of raw profiles (EXIF, IPTC, etc.) in PNG `zTXt` chunks
    // e.g. "iptc [...] 114 [...] 3842494d040400[...]"
    private val PNG_RAW_PROFILE_PATTERN = Regex("^\\n(.*?)\\n\\s*(\\d+)\\n(.*)", RegexOption.DOT_MATCHES_ALL)

    // extensions

    fun Directory.getSafeString(tag: Int, save: (value: String) -> Unit) {
        if (this.containsTag(tag)) save(this.getString(tag))
    }

    fun Directory.getSafeBoolean(tag: Int, save: (value: Boolean) -> Unit) {
        if (this.containsTag(tag)) save(this.getBoolean(tag))
    }

    fun Directory.getSafeInt(tag: Int, save: (value: Int) -> Unit) {
        if (this.containsTag(tag)) save(this.getInt(tag))
    }

    fun Directory.getSafeLong(tag: Int, save: (value: Long) -> Unit) {
        if (this.containsTag(tag)) save(this.getLong(tag))
    }

    fun Directory.getSafeRational(tag: Int, save: (value: Rational) -> Unit) {
        if (this.containsTag(tag)) save(this.getRational(tag))
    }

    fun Directory.getSafeDateMillis(tag: Int, save: (value: Long) -> Unit) {
        if (this.containsTag(tag)) {
            val date = this.getDate(tag, null, TimeZone.getDefault())
            if (date != null) save(date.time)
        }
    }

    // geotiff

    /*
    cf http://docs.opengeospatial.org/is/19-008r4/19-008r4.html#_underlying_tiff_requirements
    - One of ModelTiepointTag or ModelTransformationTag SHALL be included in an Image File Directory (IFD)
    - If the ModelTransformationTag is included in an IFD, then a ModelPixelScaleTag SHALL NOT be included
    - If the ModelPixelScaleTag is included in an IFD, then a ModelTiepointTag SHALL also be included.
     */
    fun ExifIFD0Directory.isGeoTiff(): Boolean {
        if (!this.containsTag(TiffTags.TAG_GEO_KEY_DIRECTORY)) return false

        val modelTiepoint = this.containsTag(TiffTags.TAG_MODEL_TIEPOINT)
        val modelTransformation = this.containsTag(TiffTags.TAG_MODEL_TRANSFORMATION)
        if (!modelTiepoint && !modelTransformation) return false

        val modelPixelScale = this.containsTag(TiffTags.TAG_MODEL_PIXEL_SCALE)
        if ((modelTransformation && modelPixelScale) || (modelPixelScale && !modelTiepoint)) return false

        return true
    }

    // PNG

    fun Directory.isPngTextDir(): Boolean = this is PngDirectory && setOf(PNG_ITXT_DIR_NAME, PNG_TEXT_DIR_NAME, PNG_ZTXT_DIR_NAME).contains(this.name)

    fun extractPngProfile(key: String, valueString: String): Iterable<Directory>? {
        when (key) {
            "Raw profile type iptc" -> {
                val match = PNG_RAW_PROFILE_PATTERN.matchEntire(valueString)
                if (match != null) {
                    val dataString = match.groupValues[3]
                    val hexString = dataString.replace(Regex("[\\r\\n]"), "")
                    val dataBytes = hexStringToByteArray(hexString)
                    if (dataBytes != null) {
                        val start = dataBytes.indexOf(Metadata.IPTC_MARKER_BYTE)
                        if (start != -1) {
                            val segmentBytes = dataBytes.copyOfRange(fromIndex = start, toIndex = dataBytes.size)
                            val metadata = com.drew.metadata.Metadata()
                            IptcReader().extract(SequentialByteArrayReader(segmentBytes), metadata, segmentBytes.size.toLong())
                            return metadata.directories
                        }
                    }
                }
            }
        }
        return null
    }

    // convenience methods

    private fun hexStringToByteArray(hexString: String): ByteArray? {
        if (hexString.length % 2 != 0) return null

        val dataBytes = ByteArray(hexString.length / 2)
        var i = 0
        while (i < hexString.length) {
            dataBytes[i / 2] = hexString.substring(i, i + 2).toByte(16)
            i += 2
        }
        return dataBytes
    }
}