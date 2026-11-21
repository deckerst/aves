package deckers.thibault.aves.utils

object TimeUtils {
    const val DAYS_PER_YEAR: Int = 365
    const val HOURS_PER_DAY: Int = 24
    const val MINUTES_PER_HOUR: Int = 60
    const val SECONDS_PER_MINUTE: Int = 60

    const val MINUTE_IN_MILLIS: Long = SECONDS_PER_MINUTE * 1000L
    const val DAY_IN_MILLIS: Long = HOURS_PER_DAY.toLong() * MINUTES_PER_HOUR * MINUTE_IN_MILLIS
    const val YEAR_IN_MILLIS: Long = DAYS_PER_YEAR.toLong() * DAY_IN_MILLIS
}