package deckers.thibault.aves.metadata.metadataextractor.mpf

import com.drew.metadata.Directory
import com.drew.metadata.TagDescriptor

class MpfDirectory : Directory() {
    init {
        setDescriptor(MpfDescriptor(this))
    }

    override fun getName(): String {
        return "MPF"
    }

    override fun getTagNameMap(): HashMap<Int, String> {
        return _tagNameMap
    }

    fun getNumberOfImages() = getInt(TAG_NUMBER_OF_IMAGES)

    companion object {
        const val TAG_MPF_VERSION = 0xb000
        const val TAG_NUMBER_OF_IMAGES = 0xb001
        const val TAG_MP_ENTRY = 0xb002
        private const val TAG_IMAGE_UID_LIST = 0xb003
        private const val TAG_TOTAL_FRAMES = 0xb004

        private val _tagNameMap = HashMap<Int, String>().apply {
            put(TAG_MPF_VERSION, "MPF Version")
            put(TAG_NUMBER_OF_IMAGES, "Number Of Images")
            put(TAG_MP_ENTRY, "MP Entry")
            put(TAG_IMAGE_UID_LIST, "Image UID List")
            put(TAG_TOTAL_FRAMES, "Total Frames")
        }
    }
}

class MpfDescriptor(directory: MpfDirectory?) : TagDescriptor<MpfDirectory>(directory)