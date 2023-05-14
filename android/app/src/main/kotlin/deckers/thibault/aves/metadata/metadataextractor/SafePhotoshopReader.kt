package deckers.thibault.aves.metadata.metadataextractor

import com.drew.imaging.ImageProcessingException
import com.drew.lang.ByteArrayReader
import com.drew.lang.SequentialByteArrayReader
import com.drew.lang.SequentialReader
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.exif.ExifReader
import com.drew.metadata.icc.IccReader
import com.drew.metadata.iptc.IptcReader
import com.drew.metadata.photoshop.PhotoshopDirectory
import com.drew.metadata.photoshop.PhotoshopReader
import java.util.Arrays

// adapted from `PhotoshopReader` to prevent OOM from reading large XMP
// as of `metadata-extractor` v2.18.0, there is no way to customize the Photoshop reader
// without copying the whole `extract` function
class SafePhotoshopReader : PhotoshopReader() {
    override fun extract(reader: SequentialReader, length: Int, metadata: Metadata, parentDirectory: Directory?) {
        val directory = PhotoshopDirectory()
        metadata.addDirectory(directory)

        if (parentDirectory != null) {
            directory.parent = parentDirectory
        }

        // Data contains a sequence of Image Resource Blocks (IRBs):
        //
        // 4 bytes - Signature; mostly "8BIM" but "PHUT", "AgHg" and "DCSR" are also found
        // 2 bytes - Resource identifier
        // String  - Pascal string, padded to make length even
        // 4 bytes - Size of resource data which follows
        // Data    - The resource data, padded to make size even
        //
        // http://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577409_pgfId-1037504

        var pos = 0
        var clippingPathCount = 0
        while (pos < length) {
            try {
                // 4 bytes for the signature ("8BIM", "PHUT", etc.)
                val signature = reader.getString(4)
                pos += 4

                // 2 bytes for the resource identifier (tag type).
                val tagType = reader.uInt16 // segment type
                pos += 2

                // A variable number of bytes holding a pascal string (two leading bytes for length).
                var descriptionLength = reader.uInt8.toInt()
                pos += 1
                // Some basic bounds checking
                if (descriptionLength < 0 || descriptionLength + pos > length) {
                    throw ImageProcessingException("Invalid string length")
                }

                // Get name (important for paths)
                val description = StringBuilder()
                descriptionLength += pos
                // Loop through each byte and append to string
                while (pos < descriptionLength) {
                    description.append(Char(reader.uInt8.toUShort()))
                    pos++
                }

                // The number of bytes is padded with a trailing zero, if needed, to make the size even.
                if (pos % 2 != 0) {
                    reader.skip(1)
                    pos++
                }

                // 4 bytes for the size of the resource data that follows.
                val byteCount = reader.int32
                pos += 4
                // The resource data.
                var tagBytes = reader.getBytes(byteCount)
                pos += byteCount
                // The number of bytes is padded with a trailing zero, if needed, to make the size even.
                if (pos % 2 != 0) {
                    reader.skip(1)
                    pos++
                }

                if (signature == "8BIM") {
                    when (tagType) {
                        PhotoshopDirectory.TAG_IPTC -> IptcReader().extract(SequentialByteArrayReader(tagBytes), metadata, tagBytes.size.toLong(), directory)
                        PhotoshopDirectory.TAG_ICC_PROFILE_BYTES -> IccReader().extract(ByteArrayReader(tagBytes), metadata, directory)
                        PhotoshopDirectory.TAG_EXIF_DATA_1,
                        PhotoshopDirectory.TAG_EXIF_DATA_3 -> ExifReader().extract(ByteArrayReader(tagBytes), metadata, 0, directory)

                        PhotoshopDirectory.TAG_XMP_DATA -> SafeXmpReader().extract(tagBytes, metadata, directory)
                        in 0x07D0..0x0BB6 -> {
                            clippingPathCount++
                            tagBytes = Arrays.copyOf(tagBytes, tagBytes.size + description.length + 1)
                            // Append description(name) to end of byte array with 1 byte before the description representing the length
                            for (i in tagBytes.size - description.length - 1 until tagBytes.size) {
                                if (i % (tagBytes.size - description.length - 1 + description.length) == 0) tagBytes[i] = description.length.toByte() else tagBytes[i] = description[i - (tagBytes.size - description.length - 1)].code.toByte()
                            }
//                            PhotoshopDirectory._tagNameMap[0x07CF + clippingPathCount] = "Path Info $clippingPathCount"
                            directory.setByteArray(0x07CF + clippingPathCount, tagBytes)
                        }

                        else -> directory.setByteArray(tagType, tagBytes)
                    }
//                    if (tagType in 0x0fa0..0x1387) {
//                        PhotoshopDirectory._tagNameMap[tagType] = String.format("Plug-in %d Data", tagType - 0x0fa0 + 1)
//                    }
                }
            } catch (ex: Exception) {
                directory.addError(ex.message)
                return
            }
        }
    }
}