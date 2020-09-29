package deckers.thibault.aves.utils

import androidx.exifinterface.media.ExifInterface
import java.text.DateFormat
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

object MetadataHelper {
    // interpret EXIF code to angle (0, 90, 180 or 270 degrees)
    @JvmStatic
    fun getOrientationDegreesForExifCode(exifOrientation: Int): Int = when (exifOrientation) {
        ExifInterface.ORIENTATION_ROTATE_180 -> 180
        ExifInterface.ORIENTATION_ROTATE_90 -> 90
        ExifInterface.ORIENTATION_ROTATE_270 -> 270
        else -> 0 // all other orientations (regular, flipped...) default to an angle of 0 degree
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