package deckers.thibault.aves.metadata.metadataextractor

import com.drew.lang.SequentialReader
import com.drew.metadata.Metadata
import com.drew.metadata.photoshop.PsdHeaderDirectory
import java.io.IOException

// adapted from `PsdReader` to prevent OOM from reading large XMP
// as of `metadata-extractor` v2.18.0, there is no way to customize the Photoshop reader
// without copying the whole `extract` function
class SafePsdReader {
    fun extract(reader: SequentialReader, metadata: Metadata) {
        val directory = PsdHeaderDirectory()
        metadata.addDirectory(directory)

        // FILE HEADER SECTION

        try {
            val signature = reader.int32
            if (signature != 0x38425053) // "8BPS"
            {
                directory.addError("Invalid PSD file signature")
                return
            }

            val version = reader.uInt16
            if (version != 1 && version != 2) {
                directory.addError("Invalid PSD file version (must be 1 or 2)")
                return
            }

            // 6 reserved bytes are skipped here.  They should be zero.
            reader.skip(6)

            val channelCount = reader.uInt16
            directory.setInt(PsdHeaderDirectory.TAG_CHANNEL_COUNT, channelCount)

            // even though this is probably an unsigned int, the max height in practice is 300,000
            val imageHeight = reader.int32
            directory.setInt(PsdHeaderDirectory.TAG_IMAGE_HEIGHT, imageHeight)

            // even though this is probably an unsigned int, the max width in practice is 300,000
            val imageWidth = reader.int32
            directory.setInt(PsdHeaderDirectory.TAG_IMAGE_WIDTH, imageWidth)

            val bitsPerChannel = reader.uInt16
            directory.setInt(PsdHeaderDirectory.TAG_BITS_PER_CHANNEL, bitsPerChannel)

            val colorMode = reader.uInt16
            directory.setInt(PsdHeaderDirectory.TAG_COLOR_MODE, colorMode)
        } catch (e: IOException) {
            directory.addError("Unable to read PSD header")
            return
        }

        // COLOR MODE DATA SECTION

        try {
            val sectionLength = reader.uInt32

            /*
             * Only indexed color and duotone (see the mode field in the File header section) have color mode data.
             * For all other modes, this section is just the 4-byte length field, which is set to zero.
             *
             * Indexed color images: length is 768; color data contains the color table for the image,
             *                       in non-interleaved order.
             * Duotone images: color data contains the duotone specification (the format of which is not documented).
             *                 Other applications that read Photoshop files can treat a duotone image as a gray	image,
             *                 and just preserve the contents of the duotone information when reading and writing the
             *                 file.
             */
            reader.skip(sectionLength)
        } catch (e: IOException) {
            return
        }

        // IMAGE RESOURCES SECTION

        try {
            val sectionLength = reader.uInt32

            assert(sectionLength <= Int.MAX_VALUE)

            SafePhotoshopReader().extract(reader, sectionLength.toInt(), metadata)
        } catch (e: IOException) {
            // ignore
        }

        // LAYER AND MASK INFORMATION SECTION (skipped)

        // IMAGE DATA SECTION (skipped)
    }
}