package deckers.thibault.aves.metadata.metadataextractor
import com.drew.imaging.png.PngChunkType
import com.drew.metadata.png.PngDirectory

class PngActlDirectory : PngDirectory(chunkType) {
    override fun getTagNameMap(): HashMap<Int, String> {
        return tagNames
    }

    companion object {
        val chunkType = PngChunkType("acTL")

        // tags should be distinct from those already defined in `PngDirectory`
        const val TAG_NUM_FRAMES = 101
        const val TAG_NUM_PLAYS = 102

        private val tagNames = hashMapOf(
            TAG_NUM_FRAMES to "Number Of Frames",
            TAG_NUM_PLAYS to "Number Of Plays",
        )
    }
}
