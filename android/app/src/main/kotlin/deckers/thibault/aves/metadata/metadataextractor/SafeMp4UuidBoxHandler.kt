package deckers.thibault.aves.metadata.metadataextractor

import com.drew.imaging.mp4.Mp4Handler
import com.drew.metadata.Metadata
import com.drew.metadata.mp4.Mp4Context
import com.drew.metadata.mp4.media.Mp4UuidBoxHandler
import com.drew.metadata.xmp.XmpReader

class SafeMp4UuidBoxHandler(metadata: Metadata) : Mp4UuidBoxHandler(metadata) {
    override fun processBox(type: String?, payload: ByteArray?, boxSize: Long, context: Mp4Context?): Mp4Handler<*> {
        if (payload != null && payload.size >= 16) {
            val payloadUuid = payload.copyOfRange(0, 16)
            if (payloadUuid.contentEquals(xmpUuid)) {
                SafeXmpReader().extract(payload, 16, payload.size - 16, metadata, directory)
                return this
            }
        }
        return super.processBox(type, payload, boxSize, context)
    }

    companion object {
        val xmpUuid = byteArrayOf(0xbe.toByte(), 0x7a, 0xcf.toByte(), 0xcb.toByte(), 0x97.toByte(), 0xa9.toByte(), 0x42, 0xe8.toByte(), 0x9c.toByte(), 0x71, 0x99.toByte(), 0x94.toByte(), 0x91.toByte(), 0xe3.toByte(), 0xaf.toByte(), 0xac.toByte())
    }
}