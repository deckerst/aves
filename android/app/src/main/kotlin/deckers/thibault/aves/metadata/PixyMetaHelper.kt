package deckers.thibault.aves.metadata

import deckers.thibault.aves.metadata.Metadata.TYPE_EXIF
import deckers.thibault.aves.metadata.Metadata.TYPE_ICC_PROFILE
import deckers.thibault.aves.metadata.Metadata.TYPE_IPTC
import deckers.thibault.aves.metadata.Metadata.TYPE_JFIF
import deckers.thibault.aves.metadata.Metadata.TYPE_JPEG_ADOBE
import deckers.thibault.aves.metadata.Metadata.TYPE_JPEG_DUCKY
import deckers.thibault.aves.metadata.Metadata.TYPE_PHOTOSHOP_IRB
import deckers.thibault.aves.metadata.Metadata.TYPE_XMP
import pixy.meta.meta.Metadata
import pixy.meta.meta.MetadataEntry
import pixy.meta.meta.MetadataType
import pixy.meta.meta.jpeg.JPGMeta
import pixy.meta.meta.xmp.XMP
import pixy.meta.string.XMLUtils
import java.io.InputStream
import java.io.OutputStream
import java.util.*

object PixyMetaHelper {
    fun describe(input: InputStream): HashMap<String, String> {
        val metadataMap = HashMap<String, String>()

        fun fetch(parents: String, entries: Iterable<MetadataEntry>) {
            for (entry in entries) {
                metadataMap["$parents ${entry.key}"] = entry.value
                if (entry.isMetadataEntryGroup) {
                    fetch("$parents ${entry.key} /", entry.metadataEntries)
                }
            }
        }

        val metadataByType = Metadata.readMetadata(input)
        for ((type, metadata) in metadataByType.entries) {
            if (type == MetadataType.XMP) {
                val xmp = metadataByType[MetadataType.XMP] as XMP?
                if (xmp != null) {
                    metadataMap["XMP"] = xmp.xmpDocString()
                    if (xmp.hasExtendedXmp()) {
                        metadataMap["XMP extended"] = xmp.extendedXmpDocString()
                    }
                }
            } else {
                fetch("$type /", metadata)
            }
        }

        return metadataMap
    }

    fun getXmp(input: InputStream): XMP? = Metadata.readMetadata(input)[MetadataType.XMP] as XMP?

    fun setXmp(input: InputStream, output: OutputStream, xmpString: String, extendedXmpString: String?) {
        if (extendedXmpString != null) {
            JPGMeta.insertXMP(input, output, xmpString, extendedXmpString)
        } else {
            Metadata.insertXMP(input, output, xmpString)
        }
    }

    fun XMP.xmpDocString(): String = XMLUtils.serializeToString(xmpDocument)

    fun XMP.extendedXmpDocString(): String = XMLUtils.serializeToString(extendedXmpDocument)

    fun removeMetadata(input: InputStream, output: OutputStream, metadataTypes: Set<String>) {
        val types = metadataTypes.map(::toMetadataType).toTypedArray()
        Metadata.removeMetadata(input, output, *types)
    }

    private fun toMetadataType(typeString: String): MetadataType? = when (typeString) {
        TYPE_EXIF -> MetadataType.EXIF
        TYPE_ICC_PROFILE -> MetadataType.ICC_PROFILE
        TYPE_IPTC -> MetadataType.IPTC
        TYPE_JFIF -> MetadataType.JPG_JFIF
        TYPE_JPEG_ADOBE -> MetadataType.JPG_ADOBE
        TYPE_JPEG_DUCKY -> MetadataType.JPG_DUCKY
        TYPE_PHOTOSHOP_IRB -> MetadataType.PHOTOSHOP_IRB
        TYPE_XMP -> MetadataType.XMP
        else -> null
    }
}