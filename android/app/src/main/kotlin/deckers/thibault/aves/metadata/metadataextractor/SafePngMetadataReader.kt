package deckers.thibault.aves.metadata.metadataextractor

import android.util.Log
import com.drew.imaging.png.*
import com.drew.imaging.tiff.TiffProcessingException
import com.drew.imaging.tiff.TiffReader
import com.drew.lang.*
import com.drew.lang.annotations.NotNull
import com.drew.metadata.ErrorDirectory
import com.drew.metadata.Metadata
import com.drew.metadata.StringValue
import com.drew.metadata.exif.ExifTiffHandler
import com.drew.metadata.icc.IccReader
import com.drew.metadata.png.PngChromaticitiesDirectory
import com.drew.metadata.png.PngDirectory
import com.drew.metadata.xmp.XmpReader
import deckers.thibault.aves.utils.LogUtils
import java.io.ByteArrayInputStream
import java.io.IOException
import java.io.InputStream
import java.util.zip.InflaterInputStream
import java.util.zip.ZipException

// adapted from `PngMetadataReader` to prevent reading OOM from large chunks
// as of `metadata-extractor` v2.18.0, there is no way to customize the reader
// without copying `desiredChunkTypes` and the whole `processChunk` function
object SafePngMetadataReader {
    private val LOG_TAG = LogUtils.createTag<SafePngMetadataReader>()

    // arbitrary size to detect chunks that may yield an OOM
    private const val chunkSizeDangerThreshold = SafeXmpReader.segmentTypeSizeDangerThreshold

    private val latin1Encoding = Charsets.ISO_8859_1
    private val desiredChunkTypes: Set<PngChunkType> = hashSetOf(
        PngChunkType.IHDR,
        PngChunkType.PLTE,
        PngChunkType.tRNS,
        PngChunkType.cHRM,
        PngChunkType.sRGB,
        PngChunkType.gAMA,
        PngChunkType.iCCP,
        PngChunkType.bKGD,
        PngChunkType.tEXt,
        PngChunkType.zTXt,
        PngChunkType.iTXt,
        PngChunkType.tIME,
        PngChunkType.pHYs,
        PngChunkType.sBIT,
        PngChunkType.eXIf,
    )

    @Throws(IOException::class, PngProcessingException::class)
    fun readMetadata(inputStream: InputStream): Metadata {
        val chunks = PngChunkReader().extract(StreamReader(inputStream), desiredChunkTypes)
        val metadata = Metadata()
        for (chunk in chunks) {
            try {
                processChunk(metadata, chunk)
            } catch (e: Exception) {
                metadata.addDirectory(ErrorDirectory("Exception reading PNG chunk: " + e.message))
            }
        }
        return metadata
    }

    @Throws(PngProcessingException::class, IOException::class)
    private fun processChunk(@NotNull metadata: Metadata, @NotNull chunk: PngChunk) {
        val chunkType = chunk.type
        val bytes = chunk.bytes

        // TLAD insert start
        if (bytes.size > chunkSizeDangerThreshold) {
            Log.w(LOG_TAG, "PNG chunk $chunkType is too large, with a size of ${bytes.size} B")
            return
        }
        // TLAD insert end

        if (chunkType == PngChunkType.IHDR) {
            val header = PngHeader(bytes)
            val directory = PngDirectory(PngChunkType.IHDR)
            directory.setInt(PngDirectory.TAG_IMAGE_WIDTH, header.imageWidth)
            directory.setInt(PngDirectory.TAG_IMAGE_HEIGHT, header.imageHeight)
            directory.setInt(PngDirectory.TAG_BITS_PER_SAMPLE, header.bitsPerSample.toInt())
            directory.setInt(PngDirectory.TAG_COLOR_TYPE, header.colorType.numericValue)
            directory.setInt(PngDirectory.TAG_COMPRESSION_TYPE, header.compressionType.toInt() and 0xFF) // make sure it's unsigned
            directory.setInt(PngDirectory.TAG_FILTER_METHOD, header.filterMethod.toInt())
            directory.setInt(PngDirectory.TAG_INTERLACE_METHOD, header.interlaceMethod.toInt())
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.PLTE) {
            val directory = PngDirectory(PngChunkType.PLTE)
            directory.setInt(PngDirectory.TAG_PALETTE_SIZE, bytes.size / 3)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.tRNS) {
            val directory = PngDirectory(PngChunkType.tRNS)
            directory.setInt(PngDirectory.TAG_PALETTE_HAS_TRANSPARENCY, 1)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.sRGB) {
            val srgbRenderingIntent = bytes[0].toInt()
            val directory = PngDirectory(PngChunkType.sRGB)
            directory.setInt(PngDirectory.TAG_SRGB_RENDERING_INTENT, srgbRenderingIntent)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.cHRM) {
            val chromaticities = PngChromaticities(bytes)
            val directory = PngChromaticitiesDirectory()
            directory.setInt(PngChromaticitiesDirectory.TAG_WHITE_POINT_X, chromaticities.whitePointX)
            directory.setInt(PngChromaticitiesDirectory.TAG_WHITE_POINT_Y, chromaticities.whitePointY)
            directory.setInt(PngChromaticitiesDirectory.TAG_RED_X, chromaticities.redX)
            directory.setInt(PngChromaticitiesDirectory.TAG_RED_Y, chromaticities.redY)
            directory.setInt(PngChromaticitiesDirectory.TAG_GREEN_X, chromaticities.greenX)
            directory.setInt(PngChromaticitiesDirectory.TAG_GREEN_Y, chromaticities.greenY)
            directory.setInt(PngChromaticitiesDirectory.TAG_BLUE_X, chromaticities.blueX)
            directory.setInt(PngChromaticitiesDirectory.TAG_BLUE_Y, chromaticities.blueY)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.gAMA) {
            val gammaInt = ByteConvert.toInt32BigEndian(bytes)
            SequentialByteArrayReader(bytes).int32
            val directory = PngDirectory(PngChunkType.gAMA)
            directory.setDouble(PngDirectory.TAG_GAMMA, gammaInt / 100000.0)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.iCCP) {
            val reader: SequentialReader = SequentialByteArrayReader(bytes)

            // Profile Name is 1-79 bytes, followed by the 1 byte null character
            val profileNameBytes = reader.getNullTerminatedBytes(79 + 1)
            val directory = PngDirectory(PngChunkType.iCCP)
            directory.setStringValue(PngDirectory.TAG_ICC_PROFILE_NAME, StringValue(profileNameBytes, latin1Encoding))
            val compressionMethod = reader.int8
            // Only compression method allowed by the spec is zero: deflate
            if (compressionMethod.toInt() == 0) {
                // bytes left for compressed text is:
                // total bytes length - (profilenamebytes length + null byte + compression method byte)
                val bytesLeft = bytes.size - (profileNameBytes.size + 1 + 1)
                val compressedProfile = reader.getBytes(bytesLeft)
                try {
                    val inflateStream = InflaterInputStream(ByteArrayInputStream(compressedProfile))
                    IccReader().extract(RandomAccessStreamReader(inflateStream), metadata, directory)
                    inflateStream.close()
                } catch (zex: ZipException) {
                    directory.addError(String.format("Exception decompressing PNG iCCP chunk : %s", zex.message))
                    metadata.addDirectory(directory)
                }
            } else {
                directory.addError("Invalid compression method value")
            }
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.bKGD) {
            val directory = PngDirectory(PngChunkType.bKGD)
            directory.setByteArray(PngDirectory.TAG_BACKGROUND_COLOR, bytes)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.tEXt) {
            val reader: SequentialReader = SequentialByteArrayReader(bytes)

            // Keyword is 1-79 bytes, followed by the 1 byte null character
            val keywordsv = reader.getNullTerminatedStringValue(79 + 1, latin1Encoding)
            val keyword = keywordsv.toString()

            // bytes left for text is:
            // total bytes length - (Keyword length + null byte)
            val bytesLeft = bytes.size - (keywordsv.bytes.size + 1)
            val value = reader.getNullTerminatedStringValue(bytesLeft, latin1Encoding)
            val textPairs: MutableList<KeyValuePair> = ArrayList()
            textPairs.add(KeyValuePair(keyword, value))
            val directory = PngDirectory(PngChunkType.tEXt)
            directory.setObject(PngDirectory.TAG_TEXTUAL_DATA, textPairs)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.zTXt) {
            val reader: SequentialReader = SequentialByteArrayReader(bytes)

            // Keyword is 1-79 bytes, followed by the 1 byte null character
            val keywordsv = reader.getNullTerminatedStringValue(79 + 1, latin1Encoding)
            val keyword = keywordsv.toString()
            val compressionMethod = reader.int8

            // bytes left for compressed text is:
            // total bytes length - (Keyword length + null byte + compression method byte)
            val bytesLeft = bytes.size - (keywordsv.bytes.size + 1 + 1)
            var textBytes: ByteArray? = null
            if (compressionMethod.toInt() == 0) {
                try {
                    textBytes = StreamUtil.readAllBytes(InflaterInputStream(ByteArrayInputStream(bytes, bytes.size - bytesLeft, bytesLeft)))
                } catch (zex: ZipException) {
                    val directory = PngDirectory(PngChunkType.zTXt)
                    directory.addError(String.format("Exception decompressing PNG zTXt chunk with keyword \"%s\": %s", keyword, zex.message))
                    metadata.addDirectory(directory)
                }
            } else {
                val directory = PngDirectory(PngChunkType.zTXt)
                directory.addError("Invalid compression method value")
                metadata.addDirectory(directory)
            }
            if (textBytes != null) {
                if (keyword == "XML:com.adobe.xmp") {
                    // NOTE in testing images, the XMP has parsed successfully, but we are not extracting tags from it as necessary
                    XmpReader().extract(textBytes, metadata)
                } else {
                    val textPairs: MutableList<KeyValuePair> = ArrayList()
                    textPairs.add(KeyValuePair(keyword, StringValue(textBytes, latin1Encoding)))
                    val directory = PngDirectory(PngChunkType.zTXt)
                    directory.setObject(PngDirectory.TAG_TEXTUAL_DATA, textPairs)
                    metadata.addDirectory(directory)
                }
            }
        } else if (chunkType == PngChunkType.iTXt) {
            val reader: SequentialReader = SequentialByteArrayReader(bytes)

            // Keyword is 1-79 bytes, followed by the 1 byte null character
            val keywordsv = reader.getNullTerminatedStringValue(79 + 1, latin1Encoding)
            val keyword = keywordsv.toString()
            val compressionFlag = reader.int8
            val compressionMethod = reader.int8
            // TODO we currently ignore languageTagBytes and translatedKeywordBytes
            val languageTagBytes = reader.getNullTerminatedBytes(bytes.size)
            val translatedKeywordBytes = reader.getNullTerminatedBytes(bytes.size)

            // bytes left for compressed text is:
            // total bytes length - (Keyword length + null byte + comp flag byte + comp method byte + lang length + null byte + translated length + null byte)
            val bytesLeft = bytes.size - (keywordsv.bytes.size + 1 + 1 + 1 + languageTagBytes.size + 1 + translatedKeywordBytes.size + 1)
            var textBytes: ByteArray? = null
            if (compressionFlag.toInt() == 0) {
                textBytes = reader.getNullTerminatedBytes(bytesLeft)
            } else if (compressionFlag.toInt() == 1) {
                if (compressionMethod.toInt() == 0) {
                    try {
                        textBytes = StreamUtil.readAllBytes(InflaterInputStream(ByteArrayInputStream(bytes, bytes.size - bytesLeft, bytesLeft)))
                    } catch (zex: ZipException) {
                        val directory = PngDirectory(PngChunkType.iTXt)
                        directory.addError(String.format("Exception decompressing PNG iTXt chunk with keyword \"%s\": %s", keyword, zex.message))
                        metadata.addDirectory(directory)
                    }
                } else {
                    val directory = PngDirectory(PngChunkType.iTXt)
                    directory.addError("Invalid compression method value")
                    metadata.addDirectory(directory)
                }
            } else {
                val directory = PngDirectory(PngChunkType.iTXt)
                directory.addError("Invalid compression flag value")
                metadata.addDirectory(directory)
            }
            if (textBytes != null) {
                if (keyword == "XML:com.adobe.xmp") {
                    // NOTE in testing images, the XMP has parsed successfully, but we are not extracting tags from it as necessary
                    XmpReader().extract(textBytes, metadata)
                } else {
                    val textPairs: MutableList<KeyValuePair> = ArrayList()
                    textPairs.add(KeyValuePair(keyword, StringValue(textBytes, latin1Encoding)))
                    val directory = PngDirectory(PngChunkType.iTXt)
                    directory.setObject(PngDirectory.TAG_TEXTUAL_DATA, textPairs)
                    metadata.addDirectory(directory)
                }
            }
        } else if (chunkType == PngChunkType.tIME) {
            val reader = SequentialByteArrayReader(bytes)
            val year = reader.uInt16
            val month = reader.uInt8.toInt()
            val day = reader.uInt8.toInt()
            val hour = reader.uInt8.toInt()
            val minute = reader.uInt8.toInt()
            val second = reader.uInt8.toInt()
            val directory = PngDirectory(PngChunkType.tIME)
            if (DateUtil.isValidDate(year, month - 1, day) && DateUtil.isValidTime(hour, minute, second)) {
                val dateString = String.format("%04d:%02d:%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
                directory.setString(PngDirectory.TAG_LAST_MODIFICATION_TIME, dateString)
            } else {
                directory.addError(
                    String.format(
                        "PNG tIME data describes an invalid date/time: year=%d month=%d day=%d hour=%d minute=%d second=%d",
                        year, month, day, hour, minute, second
                    )
                )
            }
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.pHYs) {
            val reader = SequentialByteArrayReader(bytes)
            val pixelsPerUnitX = reader.int32
            val pixelsPerUnitY = reader.int32
            val unitSpecifier = reader.int8
            val directory = PngDirectory(PngChunkType.pHYs)
            directory.setInt(PngDirectory.TAG_PIXELS_PER_UNIT_X, pixelsPerUnitX)
            directory.setInt(PngDirectory.TAG_PIXELS_PER_UNIT_Y, pixelsPerUnitY)
            directory.setInt(PngDirectory.TAG_UNIT_SPECIFIER, unitSpecifier.toInt())
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.sBIT) {
            val directory = PngDirectory(PngChunkType.sBIT)
            directory.setByteArray(PngDirectory.TAG_SIGNIFICANT_BITS, bytes)
            metadata.addDirectory(directory)
        } else if (chunkType == PngChunkType.eXIf) {
            try {
                val handler = ExifTiffHandler(metadata, null)
                TiffReader().processTiff(ByteArrayReader(bytes), handler, 0)
            } catch (ex: TiffProcessingException) {
                val directory = PngDirectory(PngChunkType.eXIf)
                directory.addError(ex.message)
                metadata.addDirectory(directory)
            } catch (ex: IOException) {
                val directory = PngDirectory(PngChunkType.eXIf)
                directory.addError(ex.message)
                metadata.addDirectory(directory)
            }
        }
    }
}