package deckers.thibault.aves.metadata

import java.math.BigInteger
import java.nio.charset.Charset
import java.util.*

class QuickTimeMetadataBlock(val type: String, val value: String, val language: String)

object QuickTimeMetadata {
    // QuickTime Profile Tags
    // cf https://exiftool.org/TagNames/QuickTime.html#Profile
    const val PROF_UUID = "50524f46-21d2-4fce-bb88-695cfac9c740"

    // QuickTime UserMedia Tags
    // cf https://exiftool.org/TagNames/QuickTime.html#UserMedia
    const val USMT_UUID = "55534d54-21d2-4fce-bb88-695cfac9c740"

    private const val METADATA_BOX_ID = "MTDT"

    fun parseUuidUsmt(data: ByteArray): List<QuickTimeMetadataBlock> {
        val blocks = ArrayList<QuickTimeMetadataBlock>()
        val boxHeader = BoxHeader(data)
        if (boxHeader.boxType == METADATA_BOX_ID) {
            blocks.addAll(parseQuicktimeMtdtBox(boxHeader, data))
        }
        return blocks
    }

    private fun parseQuicktimeMtdtBox(boxHeader: BoxHeader, data: ByteArray): List<QuickTimeMetadataBlock> {
        val blocks = ArrayList<QuickTimeMetadataBlock>()
        var bytes = data
        val blockCount = BigInteger(bytes.copyOfRange(8, 10)).toInt()
        bytes = bytes.copyOfRange(10, boxHeader.boxDataSize)

        for (i in 0 until blockCount) {
            val blockSize = BigInteger(bytes.copyOfRange(0, 2)).toInt()
            val blockType = BigInteger(bytes.copyOfRange(2, 6)).toInt()
            val language = parseLanguage(bytes.copyOfRange(6, 8))
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
                0x03 -> "Creation Time"
                0x04 -> "Software"
                0x0A -> "Track property"
                0x0B -> "Time zone"
                0x0C -> "Modification Time"
                else -> "0x${"%02x".format(blockType)}"
            }

            blocks.add(
                QuickTimeMetadataBlock(
                    type = blockTypeString,
                    value = payloadString,
                    language = language,
                )
            )
            bytes = bytes.copyOfRange(blockSize, bytes.size)
        }

        return blocks
    }

    // ISO 639 language code written as 3 groups of 5 bits for each letter (ascii code - 0x60)
    // e.g. 0x55c4 -> 10101 01110 00100 -> 21 14 4 -> "und"
    private fun parseLanguage(bytes: ByteArray): String {
        val i = BigInteger(bytes).toInt()
        val c1 = Character.toChars((i shr 10 and 0x1F) + 0x60)[0]
        val c2 = Character.toChars((i shr 5 and 0x1F) + 0x60)[0]
        val c3 = Character.toChars((i and 0x1F) + 0x60)[0]
        return "$c1$c2$c3"
    }
}

class BoxHeader(bytes: ByteArray) {
    var boxDataSize: Int = 0
    var boxType: String

    init {
        boxDataSize = BigInteger(bytes.copyOfRange(0, 4)).toInt()
        boxType = String(bytes.copyOfRange(4, 8))
    }
}