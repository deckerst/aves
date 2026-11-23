package deckers.thibault.aves.utils

import java.nio.ByteBuffer

fun ByteBuffer.toByteArray(): ByteArray {
    val bytes = ByteArray(remaining())
    get(bytes, 0, bytes.size)
    return bytes
}

fun Int.toHex(): String = "0x${byteArrayOf(shr(8).toByte(), toByte()).toHex()}"

fun Byte.toHex(): String = "%02x".format(this)

fun ByteArray.toHex(): String = joinToString(separator = "") { it.toHex() }

// Boyer-Moore algorithm for pattern searching
// Returns: an index of the first occurrence of the pattern or -1 if none is found.
fun ByteArray.indexOfBytes(pattern: ByteArray, start: Int = 0): Int {
    val n: Int = this.size
    val m: Int = pattern.size
    val badChar = Array(256) { 0 }
    var i = 0
    while (i < m) {
        badChar[pattern[i].toUByte().toInt()] = i
        i += 1
    }
    var j: Int = m - 1
    var s = start
    while (s <= (n - m)) {
        while (j >= 0 && pattern[j] == this[s + j]) {
            j -= 1
        }
        if (j < 0) return s
        s += Integer.max(1, j - badChar[this[s + j].toUByte().toInt()])
        j = m - 1
    }
    return -1
}
