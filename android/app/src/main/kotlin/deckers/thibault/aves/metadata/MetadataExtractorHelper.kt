package deckers.thibault.aves.metadata

import android.util.Log
import com.drew.lang.ByteArrayReader
import com.drew.lang.Rational
import com.drew.lang.SequentialByteArrayReader
import com.drew.metadata.Directory
import com.drew.metadata.StringValue
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifReader
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.iptc.IptcReader
import com.drew.metadata.png.PngDirectory
import deckers.thibault.aves.utils.LogUtils
import java.text.SimpleDateFormat
import java.util.*

object MetadataExtractorHelper {
    private val LOG_TAG = LogUtils.createTag<MetadataExtractorHelper>()

    const val PNG_ITXT_DIR_NAME = "PNG-iTXt"
    private const val PNG_TEXT_DIR_NAME = "PNG-tEXt"
    const val PNG_TIME_DIR_NAME = "PNG-tIME"
    private const val PNG_ZTXT_DIR_NAME = "PNG-zTXt"
    private const val PNG_RAW_PROFILE_EXIF = "Raw profile type exif"
    private const val PNG_RAW_PROFILE_IPTC = "Raw profile type iptc"

    val PNG_LAST_MODIFICATION_TIME_FORMAT = SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.ROOT)

    // Pattern to extract profile name, length, and text data
    // of raw profiles (EXIF, IPTC, etc.) in PNG `zTXt` chunks
    // e.g. "iptc [...] 114 [...] 3842494d040400[...]"
    // e.g. "exif [...] 134 [...] 4578696600004949[...]"
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

    fun Directory.getSafeDateMillis(tag: Int, subSecond: String?): Long? {
        if (this.containsTag(tag)) {
            val date = this.getDate(tag, subSecond, TimeZone.getDefault())
            if (date != null) return date.time
        }
        return null
    }

    // time tag and sub-second tag are *not* in the same directory
    fun ExifSubIFDDirectory.getDateModifiedMillis(save: (value: Long) -> Unit) {
        val parent = parent
        if (parent is ExifIFD0Directory) {
            val subSecond = getString(ExifSubIFDDirectory.TAG_SUBSECOND_TIME)
            val dateMillis = parent.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME, subSecond)
            if (dateMillis != null) save(dateMillis)
        }
    }

    fun ExifSubIFDDirectory.getDateDigitizedMillis(save: (value: Long) -> Unit) {
        val subSecond = getString(ExifSubIFDDirectory.TAG_SUBSECOND_TIME_DIGITIZED)
        val dateMillis = this.getSafeDateMillis(ExifSubIFDDirectory.TAG_DATETIME_DIGITIZED, subSecond)
        if (dateMillis != null) save(dateMillis)
    }

    fun ExifSubIFDDirectory.getDateOriginalMillis(save: (value: Long) -> Unit) {
        val subSecond = getString(ExifSubIFDDirectory.TAG_SUBSECOND_TIME_ORIGINAL)
        val dateMillis = this.getSafeDateMillis(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL, subSecond)
        if (dateMillis != null) save(dateMillis)
    }

    // geotiff

    /*
    cf http://docs.opengeospatial.org/is/19-008r4/19-008r4.html#_underlying_tiff_requirements
    - One of ModelTiepointTag or ModelTransformationTag SHALL be included in an Image File Directory (IFD)
    - If the ModelTransformationTag is included in an IFD, then a ModelPixelScaleTag SHALL NOT be included
    - If the ModelPixelScaleTag is included in an IFD, then a ModelTiepointTag SHALL also be included.
     */
    fun ExifDirectoryBase.containsGeoTiffTags(): Boolean {
        if (!this.containsTag(ExifGeoTiffTags.TAG_GEO_KEY_DIRECTORY)) return false

        val modelTiePoints = this.containsTag(ExifGeoTiffTags.TAG_MODEL_TIE_POINT)
        val modelTransformation = this.containsTag(ExifGeoTiffTags.TAG_MODEL_TRANSFORMATION)
        if (!modelTiePoints && !modelTransformation) return false

        val modelPixelScale = this.containsTag(ExifGeoTiffTags.TAG_MODEL_PIXEL_SCALE)
        if ((modelTransformation && modelPixelScale) || (modelPixelScale && !modelTiePoints)) return false

        return true
    }

    // TODO TLAD use `GeoTiffDirectory` from the Java version of `metadata-extractor` when available
    // adapted from https://github.com/drewnoakes/metadata-extractor-dotnet/blob/master/MetadataExtractor/Formats/Exif/ExifTiffHandler.cs
    fun ExifIFD0Directory.extractGeoKeys(geoKeys: IntArray): HashMap<Int, Any?> {
        val fields = HashMap<Int, Any?>()
        if (geoKeys.size < 4) return fields

        var i = 0
        val directoryVersion = geoKeys[i++]
        val revision = geoKeys[i++]
        val minorRevision = geoKeys[i++]
        val numberOfKeys = geoKeys[i++]

        fields[GeoTiffKeys.GEOTIFF_VERSION] = "$directoryVersion.$revision.$minorRevision"

        for (j in 0 until numberOfKeys) {
            val keyId = geoKeys[i++]
            val tiffTagLocation = geoKeys[i++]
            val valueCount = geoKeys[i++]
            val valueOffset = geoKeys[i++]

            try {
                if (tiffTagLocation == 0) {
                    fields[keyId] = valueOffset
                } else {
                    val sourceValue = getObject(tiffTagLocation)
                    if (sourceValue is StringValue) {
                        if (valueOffset + valueCount <= sourceValue.bytes.size) {
                            fields[keyId] = String(sourceValue.bytes, valueOffset, valueCount).trimEnd('|')
                        } else {
                            Log.w(LOG_TAG, "GeoTIFF key $keyId with offset $valueOffset and count $valueCount extends beyond length of source value (${sourceValue.bytes.size})")
                        }
                    } else if (sourceValue.javaClass.isArray) {
                        val sourceArray = sourceValue as DoubleArray
                        if (valueOffset + valueCount <= sourceArray.size) {
                            fields[keyId] = sourceArray.copyOfRange(valueOffset, valueOffset + valueCount)
                        } else {
                            Log.w(LOG_TAG, "GeoTIFF key $keyId with offset $valueOffset and count $valueCount extends beyond length of source value (${sourceArray.size})")
                        }
                    } else {
                        Log.w(LOG_TAG, "GeoTIFF key $keyId references tag $tiffTagLocation which has unsupported type of ${sourceValue?.javaClass}")
                    }
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to extract GeoTiff fields from keys", e)
            }
        }

        return fields
    }

    // PNG

    fun Directory.isPngTextDir(): Boolean = this is PngDirectory && setOf(PNG_ITXT_DIR_NAME, PNG_TEXT_DIR_NAME, PNG_ZTXT_DIR_NAME).contains(this.name)

    fun extractPngProfile(key: String, valueString: String): Iterable<Directory>? {
        if (key == PNG_RAW_PROFILE_EXIF || key == PNG_RAW_PROFILE_IPTC) {
            val match = PNG_RAW_PROFILE_PATTERN.matchEntire(valueString)
            if (match != null) {
                val dataString = match.groupValues[3]
                val hexString = dataString.replace(Regex("[\\r\\n]"), "")
                val dataBytes = hexString.decodeHex()
                if (dataBytes != null) {
                    val metadata = com.drew.metadata.Metadata()
                    when (key) {
                        PNG_RAW_PROFILE_EXIF -> {
                            if (ExifReader.startsWithJpegExifPreamble(dataBytes)) {
                                ExifReader().extract(ByteArrayReader(dataBytes), metadata, ExifReader.JPEG_SEGMENT_PREAMBLE.length)
                            }
                        }
                        PNG_RAW_PROFILE_IPTC -> {
                            val start = dataBytes.indexOf(Metadata.IPTC_MARKER_BYTE)
                            if (start != -1) {
                                val segmentBytes = dataBytes.copyOfRange(fromIndex = start, toIndex = dataBytes.size)
                                IptcReader().extract(SequentialByteArrayReader(segmentBytes), metadata, segmentBytes.size.toLong())
                            }
                        }
                    }
                    return metadata.directories
                }
            }
        }
        return null
    }

    // convenience methods

    private fun String.decodeHex(): ByteArray? {
        if (length % 2 != 0) return null

        try {
            val byteIterator = chunkedSequence(2)
                .map { it.toInt(16).toByte() }
                .iterator()

            return ByteArray(length / 2) { byteIterator.next() }
        } catch (e: NumberFormatException) {
            Log.w(LOG_TAG, "failed to decode hex string=$this", e)
        }
        return null
    }
}