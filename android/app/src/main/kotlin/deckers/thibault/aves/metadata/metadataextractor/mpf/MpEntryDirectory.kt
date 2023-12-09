package deckers.thibault.aves.metadata.metadataextractor.mpf

import com.drew.metadata.Directory
import com.drew.metadata.TagDescriptor
import deckers.thibault.aves.utils.MimeTypes

class MpEntryDirectory(val id: Int, val entry: MpEntry) : Directory() {
    private val descriptor = MpEntryDescriptor(this)

    init {
        setDescriptor(descriptor)
    }

    fun describe(): Map<String, String> {
        return HashMap<String, String>().apply {
            put("Flags", descriptor.getFlagsDescription(entry.flags))
            put("Format", descriptor.getFormatDescription(entry.format))
            put("Type", descriptor.getTypeDescription(entry.type))
            put("Size", "${entry.size} bytes")
            put("Offset", "${entry.dataOffset} bytes")
            put("Dependent Image 1 Entry Number", "${entry.dep1}")
            put("Dependent Image 2 Entry Number", "${entry.dep2}")
        }
    }

    override fun getName(): String {
        return "MPF Image #$id"
    }

    override fun getTagNameMap(): HashMap<Int, String> {
        return _tagNameMap
    }

    companion object {
        private val _tagNameMap = HashMap<Int, String>()
    }
}

class MpEntryDescriptor(directory: MpEntryDirectory?) : TagDescriptor<MpEntryDirectory>(directory) {
    fun getFlagsDescription(flags: Int): String {
        val flagStrings = ArrayList<String>().apply {
            if (flags and FLAG_REPRESENTATIVE != 0) add("representative image")
            if (flags and FLAG_DEPENDENT_CHILD != 0) add("dependent child image")
            if (flags and FLAG_DEPENDENT_PARENT != 0) add("dependent parent image")
        }
        return if (flagStrings.isEmpty()) "none" else flagStrings.joinToString(", ")
    }

    fun getFormatDescription(format: Int): String {
        return MpEntry.getMimeType(format) ?: "Unknown ($format)"
    }

    fun getTypeDescription(type: Int): String {
        return when (type) {
            0x030000 -> "Baseline MP Primary Image"
            0x010001 -> "Large Thumbnail (VGA equivalent)"
            0x010002 -> "Large Thumbnail (full HD equivalent)"
            0x020001 -> "Multi-frame Panorama"
            0x020002 -> "Multi-frame Disparity"
            0x020003 -> "Multi-angle"
            0x000000 -> "Undefined"
            else -> "Unknown ($type)"
        }
    }

    companion object {
        private const val FLAG_REPRESENTATIVE = 1 shl 2
        private const val FLAG_DEPENDENT_CHILD = 1 shl 3
        private const val FLAG_DEPENDENT_PARENT = 1 shl 4
    }
}

class MpEntry(val flags: Int, val format: Int, val type: Int, val size: Long, val dataOffset: Long, val dep1: Short, val dep2: Short) {
    companion object {
        fun getMimeType(format: Int): String? {
            return when (format) {
                0 -> MimeTypes.JPEG
                else -> null
            }
        }
    }
}
