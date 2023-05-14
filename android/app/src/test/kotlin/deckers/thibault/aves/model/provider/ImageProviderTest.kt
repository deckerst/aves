package deckers.thibault.aves.model.provider

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.LocalDate
import java.time.Month
import java.util.TimeZone

class ImageProviderTest {
    @Test
    fun imageProvider_CorrectEmailSimple_ReturnsTrue() {
        val date = LocalDate.of(1990, Month.FEBRUARY, 11).toEpochDay()
        assertEquals(ImageProvider.getTimeZoneString(TimeZone.getTimeZone("Europe/Paris"), date), "+01:00")
        assertEquals(ImageProvider.getTimeZoneString(TimeZone.getTimeZone("UTC"), date), "+00:00")
        assertEquals(ImageProvider.getTimeZoneString(TimeZone.getTimeZone("Asia/Kolkata"), date), "+05:30")
        assertEquals(ImageProvider.getTimeZoneString(TimeZone.getTimeZone("America/Chicago"), date), "-06:00")
    }
}
