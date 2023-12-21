package deckers.thibault.aves.metadata.metadataextractor.mpf

import android.util.Log
import com.drew.imaging.jpeg.JpegSegmentMetadataReader
import com.drew.imaging.jpeg.JpegSegmentType
import com.drew.lang.ByteArrayReader
import com.drew.lang.RandomAccessReader
import com.drew.metadata.Metadata
import com.drew.metadata.MetadataReader
import deckers.thibault.aves.utils.LogUtils

class MpfReader : JpegSegmentMetadataReader, MetadataReader {
    override fun getSegmentTypes(): Iterable<JpegSegmentType> {
        return listOf(JpegSegmentType.APP2)
    }

    override fun readJpegSegments(segments: Iterable<ByteArray>, metadata: Metadata, segmentType: JpegSegmentType) {
        for (segmentBytes in segments) {
            // Skip segments not starting with the required header
            if (segmentBytes.size >= PREAMBLE.length && PREAMBLE == String(segmentBytes, 0, PREAMBLE.length)) {
                extract(ByteArrayReader(segmentBytes), metadata)
            }
        }
    }

    override fun extract(reader: RandomAccessReader, metadata: Metadata) {
        val directory = MpfDirectory()
        metadata.addDirectory(directory)

        val baseOffset = 4

        // MP Format Identifier (4Byte)
        // MP header
        // - MP Endian (4Byte)
        val byteOrderIdentifier = reader.getInt16(baseOffset)
        if (byteOrderIdentifier.toInt() == 0x4d4d) { // "MM"
            reader.isMotorolaByteOrder = true
        } else if (byteOrderIdentifier.toInt() == 0x4949) { // "II"
            reader.isMotorolaByteOrder = false
        }
        // - Offset to First IFD (4Byte)
        val firstIfdOffset = reader.getInt32(baseOffset + 4)

        // [in primary image only] MP Index IFD:
        // - Count (2Byte)
        var offset = baseOffset + firstIfdOffset
        val tagCount = reader.getInt16(offset)
        offset += 2
        // - MP Index Fields (Overall Structure Info.)
        var imageCount = 0
        for (tag in 0..<tagCount) {
            when (val tagId = reader.getUInt16(offset)) {
                MpfDirectory.TAG_MPF_VERSION -> directory.setString(tagId, reader.getString(offset + 8, 4, Charsets.US_ASCII))
                MpfDirectory.TAG_NUMBER_OF_IMAGES -> {
                    imageCount = reader.getInt32(offset + 8)
                    directory.setInt(tagId, imageCount)
                }

                MpfDirectory.TAG_MP_ENTRY -> {
                    var mpEntryOffset = baseOffset + reader.getInt32(offset + 8)
                    for (index in 0..<imageCount) {
                        // individual image
                        val attribute = reader.getUInt32(mpEntryOffset)
                        val flags = (attribute shr 27 and 0x1f).toInt()
                        val format = (attribute shr 24 and 0x7).toInt()
                        val type = (attribute and 0xffffff).toInt()
                        val size = reader.getUInt32(mpEntryOffset + 4)
                        val dataOffset = reader.getUInt32(mpEntryOffset + 8)
                        val dep1 = reader.getInt16(mpEntryOffset + 12)
                        val dep2 = reader.getInt16(mpEntryOffset + 14)
                        metadata.addDirectory(MpEntryDirectory(index + 1, MpEntry(flags, format, type, size, dataOffset, dep1, dep2)))
                        mpEntryOffset += 16
                    }
                }

                else -> Log.d(LOG_TAG, "unknown tag=$tagId")
            }
            offset += 12
        }

        // - Offset of Next IFD (4Byte)
        // Value (MP Index IFD)

        // [in primary & other images] MP Attributes IFD:
        // - Count (2Byte)
        // - MP Attribute Fields (Details of Specific Image Usage)
        // - Offset of Next IFD
        // Value (MP Attribute IFD)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MpfReader>()
        private const val PREAMBLE = "MPF"
    }
}
