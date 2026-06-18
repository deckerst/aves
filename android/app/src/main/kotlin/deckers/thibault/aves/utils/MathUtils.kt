package deckers.thibault.aves.utils

import kotlin.math.log2
import kotlin.math.pow
import kotlin.math.roundToLong

object MathUtils {
    fun highestPowerOf2(x: Int): Int = highestPowerOf2(x.toDouble())
    fun highestPowerOf2(x: Double): Int = if (x < 1) 0 else 2.toDouble().pow(log2(x).toInt()).toInt()

    fun Double.round(decimals: Int): Double {
        val multiplier = 10.0.pow(decimals)
        return (this * multiplier).roundToLong() / multiplier
    }
}