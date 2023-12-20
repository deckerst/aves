package deckers.thibault.aves.metadata.metadataextractor.mpf

import com.drew.metadata.Directory
import com.drew.metadata.TagDescriptor

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
            if (flags and MpEntry.FLAG_REPRESENTATIVE != 0) add("representative image")
            if (flags and MpEntry.FLAG_DEPENDENT_CHILD != 0) add("dependent child image")
            if (flags and MpEntry.FLAG_DEPENDENT_PARENT != 0) add("dependent parent image")
        }
        return if (flagStrings.isEmpty()) "none" else flagStrings.joinToString(", ")
    }

    fun getFormatDescription(format: Int): String {
        return MpEntry.getMimeType(format) ?: "Unknown ($format)"
    }

    fun getTypeDescription(type: Int): String {
        return when (type) {
            MpEntry.TYPE_PRIMARY -> "Baseline MP Primary Image"
            MpEntry.TYPE_THUMBNAIL_VGA -> "Large Thumbnail (VGA equivalent)"
            MpEntry.TYPE_THUMBNAIL_FULL_HD -> "Large Thumbnail (full HD equivalent)"
            MpEntry.TYPE_PANORAMA -> "Multi-frame Panorama"
            MpEntry.TYPE_DISPARITY -> "Multi-frame Disparity"
            MpEntry.TYPE_MULTI_ANGLE -> "Multi-angle"
            MpEntry.TYPE_UNDEFINED -> "Undefined"
            else -> "Unknown ($type)"
        }
    }
}
