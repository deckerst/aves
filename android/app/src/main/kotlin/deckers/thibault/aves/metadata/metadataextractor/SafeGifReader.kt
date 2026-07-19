package deckers.thibault.aves.metadata.metadataextractor

import com.drew.lang.ByteArrayReader
import com.drew.lang.SequentialReader
import com.drew.metadata.Directory
import com.drew.metadata.ErrorDirectory
import com.drew.metadata.Metadata
import com.drew.metadata.MetadataException
import com.drew.metadata.StringValue
import com.drew.metadata.gif.GifAnimationDirectory
import com.drew.metadata.gif.GifCommentDirectory
import com.drew.metadata.gif.GifControlDirectory
import com.drew.metadata.gif.GifControlDirectory.DisposalMethod
import com.drew.metadata.gif.GifHeaderDirectory
import com.drew.metadata.gif.GifImageDirectory
import com.drew.metadata.icc.IccReader
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.util.Locale


// adapted from `metadata-extractor` v2.20.0 `GifReader` to prevent OOM from reading large XMP
// as of `metadata-extractor` v2.20.0, there is no way to customize the GIF reader
// without copying the whole `extract` function
class SafeGifReader {
    fun extract(reader: SequentialReader, metadata: Metadata) {
        reader.isMotorolaByteOrder = false

        val header: GifHeaderDirectory
        try {
            header = readGifHeader(reader)
            metadata.addDirectory(header)
        } catch (_: IOException) {
            metadata.addDirectory(ErrorDirectory("IOException processing GIF data"))
            return
        }

        if (header.hasErrors()) return

        try {
            // Skip over any global colour table if GlobalColorTable is present.
            var globalColorTableSize: Int? = null
            try {
                val hasGlobalColorTable = header.getBoolean(GifHeaderDirectory.TAG_HAS_GLOBAL_COLOR_TABLE)
                if (hasGlobalColorTable) {
                    globalColorTableSize = header.getInteger(GifHeaderDirectory.TAG_COLOR_TABLE_SIZE)
                }
            } catch (_: MetadataException) {
                // This exception should never occur here.
                metadata.addDirectory(ErrorDirectory("GIF did not had hasGlobalColorTable bit."))
            }
            if (globalColorTableSize != null) {
                // Colour table has R/G/B byte triplets
                reader.skip((3 * globalColorTableSize).toLong())
            }

            // After the header comes a sequence of blocks
            while (true) {
                val marker: Byte
                try {
                    marker = reader.int8
                } catch (_: IOException) {
                    return
                }

                when (marker) {
                    '!'.code.toByte() -> {
                        readGifExtensionBlock(reader, metadata)
                    }

                    ','.code.toByte() -> {
                        metadata.addDirectory(readImageBlock(reader))

                        // skip image data blocks
                        skipBlocks(reader)
                    }

                    ';'.code.toByte() -> {
                        // terminator
                        return
                    }

                    else -> {
                        // Anything other than these types is unexpected.
                        // GIF87a spec says to keep reading until a separator is found.
                        // GIF89a spec says file is corrupt.
                        metadata.addDirectory(ErrorDirectory("Unknown gif block marker found."))
                        return
                    }
                }
            }
        } catch (_: IOException) {
            metadata.addDirectory(ErrorDirectory("IOException processing GIF data"))
        }
    }

    @Throws(IOException::class)
    private fun readGifHeader(reader: SequentialReader): GifHeaderDirectory {
        // FILE HEADER
        //
        // 3 - signature: "GIF"
        // 3 - version: either "87a" or "89a"
        //
        // LOGICAL SCREEN DESCRIPTOR
        //
        // 2 - pixel width
        // 2 - pixel height
        // 1 - screen and color map information flags (0 is LSB)
        //       0-2  Size of the global color table
        //       3    Color table sort flag (89a only)
        //       4-6  Color resolution
        //       7    Global color table flag
        // 1 - background color index
        // 1 - pixel aspect ratio

        val headerDirectory = GifHeaderDirectory()

        val signature = reader.getString(3)

        if (signature != "GIF") {
            headerDirectory.addError("Invalid GIF file signature")
            return headerDirectory
        }

        val version = reader.getString(3)

        if (version != GIF_87A_VERSION_IDENTIFIER && version != GIF_89A_VERSION_IDENTIFIER) {
            headerDirectory.addError("Unexpected GIF version")
            return headerDirectory
        }

        headerDirectory.setString(GifHeaderDirectory.TAG_GIF_FORMAT_VERSION, version)

        // LOGICAL SCREEN DESCRIPTOR
        headerDirectory.setInt(GifHeaderDirectory.TAG_IMAGE_WIDTH, reader.uInt16)
        headerDirectory.setInt(GifHeaderDirectory.TAG_IMAGE_HEIGHT, reader.uInt16)

        val flags = reader.uInt8

        // First three bits = (BPP - 1)
        val colorTableSize = 1 shl ((flags.toInt() and 7) + 1)
        val bitsPerPixel = ((flags.toInt() and 0x70) shr 4) + 1
        val hasGlobalColorTable = (flags.toInt() shr 7) != 0

        headerDirectory.setInt(GifHeaderDirectory.TAG_COLOR_TABLE_SIZE, colorTableSize)

        if (version == GIF_89A_VERSION_IDENTIFIER) {
            val isColorTableSorted = (flags.toInt() and 8) != 0
            headerDirectory.setBoolean(GifHeaderDirectory.TAG_IS_COLOR_TABLE_SORTED, isColorTableSorted)
        }

        headerDirectory.setInt(GifHeaderDirectory.TAG_BITS_PER_PIXEL, bitsPerPixel)
        headerDirectory.setBoolean(GifHeaderDirectory.TAG_HAS_GLOBAL_COLOR_TABLE, hasGlobalColorTable)

        headerDirectory.setInt(GifHeaderDirectory.TAG_BACKGROUND_COLOR_INDEX, reader.uInt8.toInt())

        val aspectRatioByte = reader.uInt8.toInt()
        if (aspectRatioByte != 0) {
            val pixelAspectRatio = ((aspectRatioByte + 15.0) / 64.0).toFloat()
            headerDirectory.setFloat(GifHeaderDirectory.TAG_PIXEL_ASPECT_RATIO, pixelAspectRatio)
        }

        return headerDirectory
    }

    @Throws(IOException::class)
    private fun readGifExtensionBlock(reader: SequentialReader, metadata: Metadata) {
        val extensionLabel = reader.int8
        val blockSizeBytes = reader.uInt8
        val blockStartPos = reader.position

        when (extensionLabel) {
            0x01.toByte() -> {
                val plainTextBlock = readPlainTextBlock(reader, blockSizeBytes.toInt())
                if (plainTextBlock != null) metadata.addDirectory<Directory?>(plainTextBlock)
            }

            0xf9.toByte() -> metadata.addDirectory<GifControlDirectory?>(readControlBlock(reader))
            0xfe.toByte() -> metadata.addDirectory<GifCommentDirectory?>(readCommentBlock(reader, blockSizeBytes.toInt()))
            0xff.toByte() -> readApplicationExtensionBlock(reader, blockSizeBytes.toInt(), metadata)
            else -> metadata.addDirectory<ErrorDirectory?>(ErrorDirectory(String.format("Unsupported GIF extension block with type 0x%02X.", extensionLabel)))
        }

        val skipCount = blockStartPos + blockSizeBytes - reader.position
        if (skipCount > 0) reader.skip(skipCount)
    }

    @Throws(IOException::class)
    private fun readPlainTextBlock(reader: SequentialReader, blockSizeBytes: Int): Directory? {
        // It seems this extension is deprecated. If somebody finds an image with this in it, could implement here.
        // Just skip the entire block for now.

        if (blockSizeBytes != 12) return ErrorDirectory(String.format(Locale.ROOT, "Invalid GIF plain text block size. Expected 12, got %d.", blockSizeBytes))

        // skip 'blockSizeBytes' bytes
        reader.skip(12)

        // keep reading and skipping until a 0 byte is reached
        skipBlocks(reader)

        return null
    }

    @Throws(IOException::class)
    private fun readCommentBlock(reader: SequentialReader, blockSizeBytes: Int): GifCommentDirectory {
        val buffer = gatherBytes(reader, blockSizeBytes)
        return GifCommentDirectory(StringValue(buffer, Charsets.US_ASCII))
    }

    @Throws(IOException::class)
    private fun readApplicationExtensionBlock(reader: SequentialReader, blockSizeBytes: Int, metadata: Metadata) {
        if (blockSizeBytes != 11) {
            metadata.addDirectory<ErrorDirectory?>(ErrorDirectory(String.format(Locale.ROOT, "Invalid GIF application extension block size. Expected 11, got %d.", blockSizeBytes)))
            return
        }

        val extensionType = reader.getString(blockSizeBytes, Charsets.UTF_8)

        if (extensionType == "XMP DataXMP") {
            // XMP data extension
            val xmpBytes = gatherBytes(reader)
            val xmpLengh = xmpBytes.size - 257 // Exclude the "magic trailer", see XMP Specification Part 3, 1.1.2 GIF
            if (xmpLengh > 0) {
                // Only extract valid blocks
                SafeXmpReader().extract(xmpBytes, 0, xmpBytes.size - 257, metadata, null)
            }
        } else if (extensionType == "ICCRGBG1012") {
            // ICC profile extension
            val iccBytes = gatherBytes(reader, (reader.byte.toInt()) and 0xff)
            if (iccBytes.isNotEmpty()) IccReader().extract(ByteArrayReader(iccBytes), metadata)
        } else if (extensionType == "NETSCAPE2.0") {
            reader.skip(2)
            // Netscape's animated GIF extension
            // Iteration count (0 means infinite)
            val iterationCount = reader.uInt16
            // Skip terminator
            reader.skip(1)
            val animationDirectory = GifAnimationDirectory()
            animationDirectory.setInt(GifAnimationDirectory.TAG_ITERATION_COUNT, iterationCount)
            metadata.addDirectory<GifAnimationDirectory?>(animationDirectory)
        } else {
            skipBlocks(reader)
        }
    }

    @Throws(IOException::class)
    private fun readControlBlock(reader: SequentialReader): GifControlDirectory {
        val directory = GifControlDirectory()

        val packedFields = reader.uInt8
        directory.setObject(GifControlDirectory.TAG_DISPOSAL_METHOD, DisposalMethod.typeOf((packedFields.toInt() shr 2) and 7))
        directory.setBoolean(GifControlDirectory.TAG_USER_INPUT_FLAG, (packedFields.toInt() and 2) shr 1 == 1)
        directory.setBoolean(GifControlDirectory.TAG_TRANSPARENT_COLOR_FLAG, (packedFields.toInt() and 1) == 1)
        directory.setInt(GifControlDirectory.TAG_DELAY, reader.uInt16)
        directory.setInt(GifControlDirectory.TAG_TRANSPARENT_COLOR_INDEX, reader.uInt8.toInt())

        // skip 0x0 block terminator
        reader.skip(1)

        return directory
    }

    @Throws(IOException::class)
    private fun readImageBlock(reader: SequentialReader): GifImageDirectory {
        val imageDirectory = GifImageDirectory()

        imageDirectory.setInt(GifImageDirectory.TAG_LEFT, reader.uInt16)
        imageDirectory.setInt(GifImageDirectory.TAG_TOP, reader.uInt16)
        imageDirectory.setInt(GifImageDirectory.TAG_WIDTH, reader.uInt16)
        imageDirectory.setInt(GifImageDirectory.TAG_HEIGHT, reader.uInt16)

        val flags = reader.byte
        val hasColorTable = (flags.toInt() shr 7) != 0
        val isInterlaced = (flags.toInt() and 0x40) != 0

        imageDirectory.setBoolean(GifImageDirectory.TAG_HAS_LOCAL_COLOUR_TABLE, hasColorTable)
        imageDirectory.setBoolean(GifImageDirectory.TAG_IS_INTERLACED, isInterlaced)

        if (hasColorTable) {
            val isColorTableSorted = (flags.toInt() and 0x20) != 0
            imageDirectory.setBoolean(GifImageDirectory.TAG_IS_COLOR_TABLE_SORTED, isColorTableSorted)

            val bitsPerPixel = (flags.toInt() and 0x7) + 1
            imageDirectory.setInt(GifImageDirectory.TAG_LOCAL_COLOUR_TABLE_BITS_PER_PIXEL, bitsPerPixel)

            // skip color table
            reader.skip((3 * (2 shl (flags.toInt() and 0x7))).toLong())
        }

        // skip "LZW Minimum Code Size" byte
        reader.byte

        return imageDirectory
    }

    @Throws(IOException::class)
    private fun gatherBytes(reader: SequentialReader): ByteArray {
        val bytes = ByteArrayOutputStream()
        val buffer = ByteArray(257)

        while (true) {
            val b = reader.byte
            if (b.toInt() == 0) return bytes.toByteArray()

            val bInt = b.toInt() and 0xFF

            buffer[0] = b
            reader.getBytes(buffer, 1, bInt)
            bytes.write(buffer, 0, bInt + 1)
        }
    }

    @Throws(IOException::class)
    private fun gatherBytes(reader: SequentialReader, firstLength: Int): ByteArray {
        val buffer = ByteArrayOutputStream()

        var length = firstLength

        while (length > 0) {
            buffer.write(reader.getBytes(length), 0, length)

            length = reader.byte.toInt() and 0xff
        }

        return buffer.toByteArray()
    }

    @Throws(IOException::class)
    private fun skipBlocks(reader: SequentialReader) {
        while (true) {
            val length = reader.uInt8

            if (length.toInt() == 0) return

            reader.skip(length.toLong())
        }
    }


    companion object {
        const val GIF_87A_VERSION_IDENTIFIER: String = "87a"
        const val GIF_89A_VERSION_IDENTIFIER: String = "89a"
    }
}