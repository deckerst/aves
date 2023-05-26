package deckers.thibault.aves.metadata.metadataextractor

import com.drew.imaging.mp4.Mp4Handler
import com.drew.metadata.Metadata
import com.drew.metadata.mp4.Mp4BoxHandler
import com.drew.metadata.mp4.Mp4BoxTypes
import com.drew.metadata.mp4.Mp4Context
import java.io.IOException

class SafeMp4BoxHandler(metadata: Metadata) : Mp4BoxHandler(metadata) {
    @Throws(IOException::class)
    override fun processBox(type: String, payload: ByteArray?, boxSize: Long, context: Mp4Context?): Mp4Handler<*>? {
        if (payload != null && type == Mp4BoxTypes.BOX_USER_DEFINED) {
            val userBoxHandler = SafeMp4UuidBoxHandler(metadata)
            userBoxHandler.processBox(type, payload, boxSize, context)
            return this
        }
        return super.processBox(type, payload, boxSize, context)
    }
}