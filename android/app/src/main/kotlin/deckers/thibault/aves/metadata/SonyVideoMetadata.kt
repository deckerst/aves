package deckers.thibault.aves.metadata

import java.math.BigInteger
import java.nio.charset.Charset
import java.util.*

object SonyVideoMetadata {
    const val PROF_UUID = "50524f46-21d2-4fce-bb88-695cfac9c740"
    const val USMT_UUID = "55534d54-21d2-4fce-bb88-695cfac9c740"

    fun parseUsmt(data: ByteArray): HashMap<String, String> {
        val dirMap = HashMap<String, String>()
        var bytes = data
        var size = BigInteger(bytes.copyOfRange(0, 4)).toInt()
        val box = String(bytes.copyOfRange(4, 8))
        if (box == "MTDT") {
            val blockCount = BigInteger(bytes.copyOfRange(8, 10)).toInt()
            bytes = bytes.copyOfRange(10, size)
            size -= 10

            for (i in 0 until blockCount) {
                // cf https://github.com/sonyxperiadev/MultimediaForAndroidLibrary
                // cf https://rubenlaguna.com/post/2007-02-25-how-to-read-title-in-sony-psp-mp4-files/

                val blockSize = BigInteger(bytes.copyOfRange(0, 2)).toInt()

                val blockType = BigInteger(bytes.copyOfRange(2, 6)).toInt()

                // ISO 639 language code written as 3 groups of 5 bits for each letter (ascii code - 0x60)
                // e.g. 0x55c4 -> 10101 01110 00100 -> 21 14 4 -> "und"
                val language = BigInteger(bytes.copyOfRange(6, 8)).toInt()
                val c1 = Character.toChars((language shr 10 and 0x1F) + 0x60)[0]
                val c2 = Character.toChars((language shr 5 and 0x1F) + 0x60)[0]
                val c3 = Character.toChars((language and 0x1F) + 0x60)[0]
                val languageString = "$c1$c2$c3"

                val encoding = BigInteger(bytes.copyOfRange(8, 10)).toInt()

                val payload = bytes.copyOfRange(10, blockSize)
                val payloadString = when (encoding) {
                    // 0x00: short array
                    0x00 -> {
                        payload
                            .asList()
                            .chunked(2)
                            .map { (h, l) -> ((h.toInt() shl 8) + l.toInt()).toShort() }
                            .joinToString()
                    }
                    // 0x01: string
                    0x01 -> String(payload, Charset.forName("UTF-16BE")).trim()
                    // 0x101: artwork/icon
                    else -> "0x${payload.joinToString("") { "%02x".format(it) }}"
                }

                val blockTypeString = when (blockType) {
                    0x01 -> "Title"
                    0x03 -> "Timestamp"
                    0x04 -> "Creator name"
                    0x0A -> "End of track"
                    else -> "0x${"%02x".format(blockType)}"
                }

                val prefix = if (blockCount > 1) "$i/" else ""
                dirMap["${prefix}Data"] = payloadString
                dirMap["${prefix}Language"] = languageString
                dirMap["${prefix}Type"] = blockTypeString

                bytes = bytes.copyOfRange(blockSize, bytes.size)
            }
        }
        return dirMap
    }
}