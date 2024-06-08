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
        assertEquals("+01:00", ImageProvider.getTimeZoneString(TimeZone.getTimeZone("Europe/Paris"), date))
        assertEquals("+00:00", ImageProvider.getTimeZoneString(TimeZone.getTimeZone("UTC"), date))
        assertEquals("+05:30", ImageProvider.getTimeZoneString(TimeZone.getTimeZone("Asia/Kolkata"), date))
        assertEquals("-06:00", ImageProvider.getTimeZoneString(TimeZone.getTimeZone("America/Chicago"), date))
    }
}
