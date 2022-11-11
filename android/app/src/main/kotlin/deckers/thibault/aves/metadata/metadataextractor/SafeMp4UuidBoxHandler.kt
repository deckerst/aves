package deckers.thibault.aves.metadata.metadataextractor

import com.drew.imaging.mp4.Mp4Handler
import com.drew.metadata.Metadata
import com.drew.metadata.mp4.Mp4Context
import com.drew.metadata.mp4.media.Mp4UuidBoxHandler
import deckers.thibault.aves.metadata.XMP

class SafeMp4UuidBoxHandler(metadata: Metadata) : Mp4UuidBoxHandler(metadata) {
    override fun processBox(type: String?, payload: ByteArray?, boxSize: Long, context: Mp4Context?): Mp4Handler<*> {
        if (payload != null && payload.size >= 16) {
            val payloadUuid = payload.copyOfRange(0, 16)
            if (payloadUuid.contentEquals(XMP.mp4Uuid)) {
                SafeXmpReader().extract(payload, 16, payload.size - 16, metadata, directory)
                return this
            }
        }
        return super.processBox(type, payload, boxSize, context)
    }
}