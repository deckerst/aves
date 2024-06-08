package deckers.thibault.aves.utils

import deckers.thibault.aves.utils.MathUtils.highestPowerOf2
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class MathUtilsTest {
    @Test
    fun mathUtils_highestPowerOf2() {
        assertEquals(1024, highestPowerOf2(1024))
        assertEquals(32, highestPowerOf2(42))
        assertEquals(0, highestPowerOf2(0))
        assertEquals(0, highestPowerOf2(-42))
        assertEquals(0, highestPowerOf2(.5))
        assertEquals(1, highestPowerOf2(1.5))
    }
}
