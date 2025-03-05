package deckers.thibault.aves.utils

import java.nio.ByteBuffer

fun ByteBuffer.toByteArray(): ByteArray {
    val bytes = ByteArray(remaining())
    get(bytes, 0, bytes.size)
    return bytes
}

fun Int.toHex(): String = "0x${byteArrayOf(shr(8).toByte(), toByte()).toHex()}"

fun ByteArray.toHex(): String = joinToString(separator = "") { it.toHex() }

fun Byte.toHex(): String = "%02x".format(this)