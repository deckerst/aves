package deckers.thibault.aves.utils

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

    // directory names, as shown when listing all metadata
    const val DIR_GPS = "GPS" // from metadata-extractor
    const val DIR_XMP = "XMP" // from metadata-extractor
    const val DIR_MEDIA = "Media"

    // interpret EXIF code to angle (0, 90, 180 or 270 degrees)
    @JvmStatic
    fun getRotationDegreesForExifCode(exifOrientation: Int): Int = when (exifOrientation) {
        ExifInterface.ORIENTATION_ROTATE_90, ExifInterface.ORIENTATION_TRANSVERSE -> 90
        ExifInterface.ORIENTATION_ROTATE_180, ExifInterface.ORIENTATION_FLIP_VERTICAL -> 180
        ExifInterface.ORIENTATION_ROTATE_270, ExifInterface.ORIENTATION_TRANSPOSE -> 270
        else -> 0
    }

    // interpret EXIF code to whether the image is flipped
    @JvmStatic
    fun isFlippedForExifCode(exifOrientation: Int): Boolean = when (exifOrientation) {
        ExifInterface.ORIENTATION_FLIP_HORIZONTAL, ExifInterface.ORIENTATION_TRANSVERSE, ExifInterface.ORIENTATION_FLIP_VERTICAL, ExifInterface.ORIENTATION_TRANSPOSE -> true
        else -> false
    }

    // yyyyMMddTHHmmss(.sss)?(Z|+/-hhmm)?
    @JvmStatic
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
            timeZone = TimeZone.getTimeZone("GMT" + timeZoneMatcher.group().replace("Z".toRegex(), ""))
            dateString = timeZoneMatcher.replaceAll("")
        }

        val date: Date = try {
            val parser = SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.US)
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