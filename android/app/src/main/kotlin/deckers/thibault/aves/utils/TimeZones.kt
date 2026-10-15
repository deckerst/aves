package deckers.thibault.aves.utils

import java.util.TimeZone
import java.util.regex.Pattern
import kotlin.math.absoluteValue
import kotlin.time.Clock

object TimeZones {
    val UTC: TimeZone = TimeZone.getTimeZone("UTC")

    val currentOffsetMinutes: Int = getOffsetMinutes(TimeZone.getDefault())

    fun getOffsetMinutes(timeZone: TimeZone): Int {
        val nowMillis = Clock.System.now().toEpochMilliseconds()
        return timeZone.getOffset(nowMillis) / 60000
    }

    private val offsetPattern = Pattern.compile("([+-])(\\d{1,2}):(\\d{2})$")

    fun parse(timeZoneOffset: String?): Int? {
        timeZoneOffset ?: return null

        val timeZoneOffsetMatcher = offsetPattern.matcher(timeZoneOffset)
        if (!timeZoneOffsetMatcher.find()) return null

        val sign = if (timeZoneOffsetMatcher.group(1) == "-") -1 else 1
        val hours = timeZoneOffsetMatcher.group(2)?.toIntOrNull()
        val minutes = timeZoneOffsetMatcher.group(3)?.toIntOrNull()
        if (hours == null || minutes == null) return null

        return sign * (hours * 60 + minutes)
    }

    fun format(timeZone: TimeZone, dateTimeMillis: Long): String {
        val offsetMillis = timeZone.getOffset(dateTimeMillis)
        val offsetMinutes = offsetMillis / 60000
        return format(offsetMinutes)
    }

    fun format(offsetMinutes: Int): String {
        val sign = if (offsetMinutes < 0) "-" else "+"
        val absOffsetInMinutes = offsetMinutes.absoluteValue
        val hours = "${absOffsetInMinutes / 60}".padStart(2, '0')
        val minutes = "${absOffsetInMinutes % 60}".padStart(2, '0')
        return "$sign$hours:$minutes"
    }
}