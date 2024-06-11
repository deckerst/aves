package deckers.thibault.aves.utils

import kotlin.math.log2
import kotlin.math.pow

object MathUtils {
    fun highestPowerOf2(x: Int): Int = highestPowerOf2(x.toDouble())
    fun highestPowerOf2(x: Double): Int = if (x < 1) 0 else 2.toDouble().pow(log2(x).toInt()).toInt()
}