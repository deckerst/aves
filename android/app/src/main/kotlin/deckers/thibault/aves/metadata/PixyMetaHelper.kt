package deckers.thibault.aves.metadata

import android.content.Context
import android.net.Uri
import deckers.thibault.aves.metadata.Metadata.TYPE_COMMENT
import deckers.thibault.aves.metadata.Metadata.TYPE_EXIF
import deckers.thibault.aves.metadata.Metadata.TYPE_ICC_PROFILE
import deckers.thibault.aves.metadata.Metadata.TYPE_IPTC
import deckers.thibault.aves.metadata.Metadata.TYPE_JFIF
import deckers.thibault.aves.metadata.Metadata.TYPE_JPEG_ADOBE
import deckers.thibault.aves.metadata.Metadata.TYPE_JPEG_DUCKY
import deckers.thibault.aves.metadata.Metadata.TYPE_PHOTOSHOP_IRB
import deckers.thibault.aves.metadata.Metadata.TYPE_XMP
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import pixy.meta.meta.Metadata
import pixy.meta.meta.MetadataEntry
import pixy.meta.meta.MetadataType
import pixy.meta.meta.iptc.IPTC
import pixy.meta.meta.iptc.IPTCDataSet
import pixy.meta.meta.iptc.IPTCRecord
import pixy.meta.meta.jpeg.JPGMeta
import pixy.meta.meta.xmp.XMP
import pixy.meta.string.XMLUtils
import java.io.File
import java.io.InputStream
import java.io.OutputStream

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

    fun getIptc(input: InputStream): List<FieldMap>? {
        val iptc = Metadata.readMetadata(input)[MetadataType.IPTC] as IPTC? ?: return null

        val iptcDataList = ArrayList<FieldMap>()
        iptc.dataSets.forEach { dataSetEntry ->
            val tag = dataSetEntry.key
            val dataSets = dataSetEntry.value
            iptcDataList.add(
                hashMapOf(
                    "record" to tag.recordNumber,
                    "tag" to tag.tag,
                    "values" to dataSets.map { it.data }.toMutableList(),
                )
            )
        }
        return iptcDataList
    }

    fun setIptc(
        input: InputStream,
        output: OutputStream,
        iptcDataList: List<FieldMap>?,
    ) {
        val iptc = iptcDataList?.flatMap {
            val record = it["record"] as Int
            val tag = it["tag"] as Int
            val values = it["values"] as List<*>
            values.map { data -> IPTCDataSet(IPTCRecord.fromRecordNumber(record), tag, data as ByteArray) }
        } ?: ArrayList<IPTCDataSet>()
        Metadata.insertIPTC(input, output, iptc)
    }

    fun getXmp(input: InputStream): XMP? = Metadata.readMetadata(input)[MetadataType.XMP] as XMP?

    fun setXmp(
        input: InputStream,
        output: OutputStream,
        xmpString: String?,
        extendedXmpString: String?
    ) {
        if (extendedXmpString != null) {
            JPGMeta.insertXMP(input, output, xmpString, extendedXmpString)
        } else {
            Metadata.insertXMP(input, output, xmpString)
        }
    }

    fun XMP.xmpDocString(): String = XMLUtils.serializeToString(xmpDocument)

    fun XMP.extendedXmpDocString(): String = XMLUtils.serializeToString(extendedXmpDocument)

    fun copyIptcXmp(
        context: Context,
        sourceMimeType: String,
        sourceUri: Uri,
        targetMimeType: String,
        targetUri: Uri,
        editableFile: File,
    ) {
        var pixyIptc: IPTC? = null
        var pixyXmp: XMP? = null
        if (MimeTypes.canReadWithPixyMeta(sourceMimeType)) {
            StorageUtils.openInputStream(context, sourceUri)?.use { input ->
                val metadata = Metadata.readMetadata(input)
                if (MimeTypes.canEditIptc(targetMimeType)) {
                    pixyIptc = metadata[MetadataType.IPTC] as IPTC?
                }
                if (MimeTypes.canEditXmp(targetMimeType)) {
                    pixyXmp = metadata[MetadataType.XMP] as XMP?
                }
            }
        }
        if (pixyIptc != null || pixyXmp != null) {
            editableFile.outputStream().use { output ->
                if (pixyIptc != null) {
                    // reopen input to read from start
                    StorageUtils.openInputStream(context, targetUri)?.use { input ->
                        val iptcs = pixyIptc!!.dataSets.flatMap { it.value }
                        Metadata.insertIPTC(input, output, iptcs)
                    }
                }
                if (pixyXmp != null) {
                    // reopen input to read from start
                    StorageUtils.openInputStream(context, targetUri)?.use { input ->
                        val xmpString = pixyXmp!!.xmpDocString()
                        val extendedXmp = if (pixyXmp!!.hasExtendedXmp()) pixyXmp!!.extendedXmpDocString() else null
                        setXmp(input, output, xmpString, if (targetMimeType == MimeTypes.JPEG) extendedXmp else null)
                    }
                }
            }
        }
    }

    fun removeMetadata(input: InputStream, output: OutputStream, metadataTypes: Set<String>) {
        val types = metadataTypes.map(::toMetadataType).toTypedArray()
        Metadata.removeMetadata(input, output, *types)
    }

    private fun toMetadataType(typeString: String): MetadataType? = when (typeString) {
        TYPE_COMMENT -> MetadataType.COMMENT
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