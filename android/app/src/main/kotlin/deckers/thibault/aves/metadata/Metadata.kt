package deckers.thibault.aves.metadata

import androidx.exifinterface.media.ExifInterface
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

object Metadata {
    // Pattern to extract latitude & longitude from a video location tag (cf ISO 6709)
    // Examples:
    // "+37.5090+127.0243/" (Samsung)
    // "+51.3328-000.7053+113.474/" (Apple)
    val VIDEO_LOCATION_PATTERN: Pattern = Pattern.compile("([+-][.0-9]+)([+-][.0-9]+).*")

    // cf https://github.com/google/spatial-media
    const val SPHERICAL_VIDEO_V1_UUID = "ffcc8263-f855-4a93-8814-587a02521fdd"

    // directory names, as shown when listing all metadata
    const val DIR_GPS = "GPS" // from metadata-extractor
    const val DIR_XMP = "XMP" // from metadata-extractor
    const val DIR_MEDIA = "Media"

    // interpret EXIF code to angle (0, 90, 180 or 270 degrees)
    fun getRotationDegreesForExifCode(exifOrientation: Int): Int = when (exifOrientation) {
        ExifInterface.ORIENTATION_ROTATE_90, ExifInterface.ORIENTATION_TRANSVERSE -> 90
        ExifInterface.ORIENTATION_ROTATE_180, ExifInterface.ORIENTATION_FLIP_VERTICAL -> 180
        ExifInterface.ORIENTATION_ROTATE_270, ExifInterface.ORIENTATION_TRANSPOSE -> 270
        else -> 0
    }

    // interpret EXIF code to whether the image is flipped
    fun isFlippedForExifCode(exifOrientation: Int): Boolean = when (exifOrientation) {
        ExifInterface.ORIENTATION_FLIP_HORIZONTAL, ExifInterface.ORIENTATION_TRANSVERSE, ExifInterface.ORIENTATION_FLIP_VERTICAL, ExifInterface.ORIENTATION_TRANSPOSE -> true
        else -> false
    }

    fun getExifCode(rotationDegrees: Int, isFlipped: Boolean): Int {
        return when (rotationDegrees) {
            90 -> if (isFlipped) ExifInterface.ORIENTATION_TRANSVERSE else ExifInterface.ORIENTATION_ROTATE_90
            180 -> if (isFlipped) ExifInterface.ORIENTATION_FLIP_VERTICAL else ExifInterface.ORIENTATION_ROTATE_180
            270 -> if (isFlipped) ExifInterface.ORIENTATION_TRANSPOSE else ExifInterface.ORIENTATION_ROTATE_270
            else -> if (isFlipped) ExifInterface.ORIENTATION_FLIP_HORIZONTAL else ExifInterface.ORIENTATION_NORMAL
        }
    }

    // not sure which standards are used for the different video formats,
    // but looks like some form of ISO 8601 `basic format`:
    // yyyyMMddTHHmmss(.sss)?(Z|+/-hhmm)?
    fun parseVideoMetadataDate(metadataDate: String?): Long {
        var dateString = metadataDate ?: return 0

        // optional sub-second
        var subSecond: String? = null
        val subSecondMatcher = Pattern.compile("(\\d{6})(\\.\\d+)").matcher(dateString)
        if (subSecondMatcher.find()) {
            subSecond = subSecondMatcher.group(2)?.substring(1)
            dateString = subSecondMatcher.replaceAll("$1")
        }

        // optional time zone
        var timeZone: TimeZone? = null
        val timeZoneMatcher = Pattern.compile("(Z|[+-]\\d{4})$").matcher(dateString)
        if (timeZoneMatcher.find()) {
            timeZone = TimeZone.getTimeZone("GMT${timeZoneMatcher.group().replace("Z".toRegex(), "")}")
            dateString = timeZoneMatcher.replaceAll("")
        }

        val date: Date = try {
            val parser = SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.ROOT)
            parser.timeZone = timeZone ?: TimeZone.getTimeZone("GMT")
            parser.parse(dateString)
        } catch (e: ParseException) {
            // ignore
            null
        } ?: return 0

        var dateMillis = date.time
        if (subSecond != null) {
            try {
                val millis = (".$subSecond".toDouble() * 1000).toInt()
                if (millis in 0..999) {
                    dateMillis += millis.toLong()
                }
            } catch (e: NumberFormatException) {
                // ignore
            }
        }
        return dateMillis
    }
}