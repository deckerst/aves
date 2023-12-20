package deckers.thibault.aves.metadata.metadataextractor.mpf

import deckers.thibault.aves.utils.MimeTypes

class MpEntry(val flags: Int, val format: Int, val type: Int, val size: Long, val dataOffset: Long, val dep1: Short, val dep2: Short) {
    val mimeType: String?
        get() = getMimeType(format)

    val isThumbnail: Boolean
        get() = when (type) {
            TYPE_THUMBNAIL_VGA, TYPE_THUMBNAIL_FULL_HD -> true
            else -> false
        }

    companion object {
        const val FLAG_REPRESENTATIVE = 1 shl 2
        const val FLAG_DEPENDENT_CHILD = 1 shl 3
        const val FLAG_DEPENDENT_PARENT = 1 shl 4

        const val TYPE_PRIMARY = 0x030000
        const val TYPE_THUMBNAIL_VGA = 0x010001
        const val TYPE_THUMBNAIL_FULL_HD = 0x010002
        const val TYPE_PANORAMA = 0x020001
        const val TYPE_DISPARITY = 0x020002
        const val TYPE_MULTI_ANGLE = 0x020003
        const val TYPE_UNDEFINED = 0x000000

        fun getMimeType(format: Int): String? {
            return when (format) {
                0 -> MimeTypes.JPEG
                else -> null
            }
        }
    }
}
