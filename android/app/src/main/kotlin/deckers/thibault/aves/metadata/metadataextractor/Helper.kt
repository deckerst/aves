package deckers.thibault.aves.metadata.metadataextractor

import android.util.Log
import com.drew.imaging.FileType
import com.drew.imaging.FileTypeDetector
import com.drew.imaging.ImageMetadataReader
import com.drew.imaging.ImageProcessingException
import com.drew.imaging.jpeg.JpegMetadataReader
import com.drew.imaging.jpeg.JpegSegmentMetadataReader
import com.drew.imaging.mp4.Mp4Reader
import com.drew.imaging.tiff.TiffProcessingException
import com.drew.imaging.tiff.TiffReader
import com.drew.lang.ByteArrayReader
import com.drew.lang.RandomAccessStreamReader
import com.drew.lang.Rational
import com.drew.lang.SequentialByteArrayReader
import com.drew.metadata.Directory
import com.drew.metadata.StringValue
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifReader
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.file.FileTypeDirectory
import com.drew.metadata.iptc.IptcReader
import com.drew.metadata.png.PngDirectory
import com.drew.metadata.xmp.XmpReader
import deckers.thibault.aves.metadata.ExifGeoTiffTags
import deckers.thibault.aves.metadata.GeoTiffKeys
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.metadataextractor.mpf.MpfReader
import deckers.thibault.aves.utils.LogUtils
import java.io.BufferedInputStream
import java.io.IOException
import java.io.InputStream
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.GregorianCalendar
import java.util.Locale
import java.util.TimeZone
import java.util.regex.Pattern

object Helper {
    private val LOG_TAG = LogUtils.createTag<Helper>()

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

    // providing the stream length is risky, as it may crash if it is incorrect
    private const val safeReadStreamLength = -1L

    fun readMimeType(input: InputStream): String? {
        val bufferedInputStream = if (input is BufferedInputStream) input else BufferedInputStream(input)
        return FileTypeDetector.detectFileType(bufferedInputStream).mimeType
    }

    @Throws(IOException::class, ImageProcessingException::class)
    fun safeRead(input: InputStream): com.drew.metadata.Metadata {
        val inputStream = if (input is BufferedInputStream) input else BufferedInputStream(input)
        val fileType = FileTypeDetector.detectFileType(inputStream)

        val metadata = when (fileType) {
            FileType.Jpeg -> safeReadJpeg(inputStream)
            FileType.Mp4 -> safeReadMp4(inputStream)
            FileType.Png -> safeReadPng(inputStream)
            FileType.Psd -> safeReadPsd(inputStream)
            FileType.Tiff,
            FileType.Arw,
            FileType.Cr2,
            FileType.Nef,
            FileType.Orf,
            FileType.Rw2 -> safeReadTiff(inputStream)

            else -> ImageMetadataReader.readMetadata(inputStream, safeReadStreamLength, fileType)
        }

        metadata.addDirectory(FileTypeDirectory(fileType))
        return metadata
    }

    // Some JPEG, TIFF, MP4 (and other types?) contain XMP with a preposterous number of `DocumentAncestors`.
    // This bloated XMP is unsafely loaded in memory by Adobe's `XMPMetaParser.parseInputSource`
    // which easily yields OOM on Android, so we try to detect and strip extended XMP with a modified XMP reader.
    private fun safeReadJpeg(input: InputStream): com.drew.metadata.Metadata {
        val readers = ArrayList<JpegSegmentMetadataReader>().apply {
            addAll(JpegMetadataReader.ALL_READERS.filter { it !is XmpReader })
            add(SafeXmpReader())
            add(MpfReader())
        }

        val metadata = com.drew.metadata.Metadata()
        JpegMetadataReader.process(metadata, input, readers)
        return metadata
    }

    private fun safeReadPng(input: InputStream): com.drew.metadata.Metadata {
        return SafePngMetadataReader.readMetadata(input)
    }

    private fun safeReadPsd(input: InputStream): com.drew.metadata.Metadata {
        return SafePsdMetadataReader.readMetadata(input)
    }

    @Throws(IOException::class, TiffProcessingException::class)
    fun safeReadTiff(input: InputStream): com.drew.metadata.Metadata {
        val reader = RandomAccessStreamReader(input, RandomAccessStreamReader.DEFAULT_CHUNK_LENGTH, safeReadStreamLength)
        val metadata = com.drew.metadata.Metadata()
        val handler = SafeExifTiffHandler(metadata, null, 0)
        TiffReader().processTiff(reader, handler, 0)
        return metadata
    }

    private fun safeReadMp4(input: InputStream): com.drew.metadata.Metadata {
        val metadata = com.drew.metadata.Metadata()
        Mp4Reader.extract(input, SafeMp4BoxHandler(metadata))
        return metadata
    }

    // extensions

    fun Directory.getSafeString(tag: Int, acceptBlank: Boolean = true, save: (value: String) -> Unit) {
        if (this.containsTag(tag)) {
            val string = this.getString(tag)
            if (acceptBlank || string.isNotBlank()) {
                save(string)
            }
        }
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
            val date = this.getDatePlus(tag, subSecond, TimeZone.getDefault())
            if (date != null) return date.time
        }
        return null
    }

    // This seems to cover all known Exif and Xmp date strings
    // Note that "    :  :     :  :  " is a valid date string according to the Exif spec (which means 'unknown date'): http://www.awaresystems.be/imaging/tiff/tifftags/privateifd/exif/datetimeoriginal.html
    private val dateFormats = arrayOf(
        "yyyy:MM:dd HH:mm:ss",
        "yyyy:MM:dd HH:mm",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd HH:mm",
        "yyyy.MM.dd HH:mm:ss",
        "yyyy.MM.dd HH:mm",
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm",
        "yyyy-MM-dd",
        "yyyy-MM",
        "yyyyMMdd",  // as used in IPTC data
        "yyyy"
    ).map { SimpleDateFormat(it, Locale.ROOT) }.toTypedArray()
    private val subsecondPattern = Pattern.compile("(\\d\\d:\\d\\d:\\d\\d)(\\.\\d+)")
    private val timeZonePattern = Pattern.compile("(Z|[+-]\\d\\d:\\d\\d|[+-]\\d\\d\\d\\d)$")
    private val calendar: Calendar = GregorianCalendar()
    private const val PARSED_DATE_YEAR_MAX = 10000

    // adapted from `metadata-extractor` v2.18.0 `Directory.getDate()`
    // to also parse dates written as timestamps
    private fun Directory.getDatePlus(tagType: Int, subSecond: String?, timeZone: TimeZone?): Date? {
        var effectiveSubSecond = subSecond
        var effectiveTimeZone = timeZone
        val o = this.getObject(tagType)
        if (o is Date) return o

        var date: Date? = null
        if (o is String || o is StringValue) {
            var dateString = o.toString()

            // if the date string has subsecond information, it supersedes the subsecond parameter
            val subsecondMatcher = subsecondPattern.matcher(dateString)
            if (subsecondMatcher.find()) {
                effectiveSubSecond = subsecondMatcher.group(2)?.substring(1)
                dateString = subsecondMatcher.replaceAll("$1")
            }

            // if the date string has time zone information, it supersedes the timeZone parameter
            val timeZoneMatcher = timeZonePattern.matcher(dateString)
            if (timeZoneMatcher.find()) {
                effectiveTimeZone = TimeZone.getTimeZone("GMT" + timeZoneMatcher.group().replace("Z".toRegex(), ""))
                dateString = timeZoneMatcher.replaceAll("")
            }
            for (dateFormat in dateFormats) {
                try {
                    dateFormat.timeZone = effectiveTimeZone ?: TimeZone.getTimeZone("GMT") // don't interpret zone time
                    val parsed = dateFormat.parse(dateString)
                    if (parsed != null) {
                        calendar.time = parsed
                        if (calendar.get(Calendar.YEAR) < PARSED_DATE_YEAR_MAX) {
                            date = parsed
                            break
                        }
                    }
                } catch (ex: ParseException) {
                    // simply try the next pattern
                }
            }
            if (date == null) {
                val dateLong = dateString.toLongOrNull()
                if (dateLong != null) {
                    val epochTimeMillis = when (dateLong) {
                        in 0..99999999999 -> dateLong * 1000 // seconds
                        in 100000000000..99999999999999 -> dateLong // millis
                        in 100000000000000..9999999999999999 -> dateLong / 1000 // micros
                        else -> dateLong / 1000000 // nanos
                    }
                    date = Date(epochTimeMillis)
                }
            }
        }
        if (date == null) return null

        if (effectiveSubSecond != null) {
            try {
                val millisecond = (".$effectiveSubSecond".toDouble() * 1000).toInt()
                if (millisecond in 0..999) {
                    val calendar = Calendar.getInstance()
                    calendar.time = date
                    calendar[Calendar.MILLISECOND] = millisecond
                    return calendar.time
                }
            } catch (e: NumberFormatException) {
                // ignore
            }
        }
        return date
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