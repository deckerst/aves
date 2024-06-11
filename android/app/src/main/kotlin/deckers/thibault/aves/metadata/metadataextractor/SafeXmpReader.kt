package deckers.thibault.aves.metadata.metadataextractor

import android.util.Log
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta
import com.adobe.internal.xmp.XMPMetaFactory
import com.adobe.internal.xmp.impl.ByteBuffer
import com.adobe.internal.xmp.options.ParseOptions
import com.adobe.internal.xmp.properties.XMPPropertyInfo
import com.drew.imaging.jpeg.JpegSegmentType
import com.drew.lang.SequentialByteArrayReader
import com.drew.lang.SequentialReader
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.xmp.XmpDirectory
import com.drew.metadata.xmp.XmpReader
import deckers.thibault.aves.utils.LogUtils
import java.io.IOException
import java.util.Locale

class SafeXmpReader : XmpReader() {
    // adapted from `XmpReader` to detect and skip large extended XMP
    override fun readJpegSegments(segments: Iterable<ByteArray>, metadata: Metadata, segmentType: JpegSegmentType) {
        val preambleLength = XMP_JPEG_PREAMBLE.length
        val extensionPreambleLength = XMP_EXTENSION_JPEG_PREAMBLE.length
        var extendedXMPGUID: String? = null
        var extendedXMPBuffer: ByteArray? = null
        var loggedDanger = false

        for (segmentBytes in segments) {
            if (segmentBytes.size >= preambleLength) {
                if (XMP_JPEG_PREAMBLE.equals(String(segmentBytes, 0, preambleLength), ignoreCase = true) ||
                    "XMP".equals(String(segmentBytes, 0, 3), ignoreCase = true)
                ) {
                    val xmlBytes = ByteArray(segmentBytes.size - preambleLength)
                    System.arraycopy(segmentBytes, preambleLength, xmlBytes, 0, xmlBytes.size)
                    extract(xmlBytes, metadata)
                    extendedXMPGUID = getExtendedXMPGUID(metadata)
                    continue
                }
            }
            if (extendedXMPGUID != null && segmentBytes.size >= extensionPreambleLength &&
                XMP_EXTENSION_JPEG_PREAMBLE.equals(String(segmentBytes, 0, extensionPreambleLength), ignoreCase = true)
            ) {
                extendedXMPBuffer = processExtendedXMPChunk(metadata, segmentBytes, extendedXMPGUID, extendedXMPBuffer) { fullLength ->
                    if (!loggedDanger) {
                        logError(metadata, fullLength)
                        loggedDanger = true
                    }
                }
            }
        }

        extendedXMPBuffer?.let { xmpBytes ->
            val totalSize = xmpBytes.size
            if (totalSize > SEGMENT_TYPE_SIZE_DANGER_THRESHOLD) {
                logError(metadata, totalSize)
            } else {
                extract(xmpBytes, metadata)
            }
        }
    }

    // adapted from `XmpReader` to provide different parsing options
    // and to detect large XMP when extracted directly (e.g. from Photoshop reader)
    override fun extract(xmpBytes: ByteArray, offset: Int, length: Int, metadata: Metadata, parentDirectory: Directory?) {
        val totalSize = xmpBytes.size
        if (totalSize > SEGMENT_TYPE_SIZE_DANGER_THRESHOLD) {
            logError(metadata, totalSize)
            return
        }

        val directory = XmpDirectory()
        if (parentDirectory != null) directory.parent = parentDirectory

        try {
            val xmpMeta: XMPMeta = if (offset == 0 && length == totalSize) {
                XMPMetaFactory.parseFromBuffer(xmpBytes, PARSE_OPTIONS)
            } else {
                val buffer = ByteBuffer(xmpBytes, offset, length)
                XMPMetaFactory.parse(buffer.byteStream, PARSE_OPTIONS)
            }
            directory.xmpMeta = xmpMeta
        } catch (e: XMPException) {
            directory.addError("Error processing XMP data: " + e.message)
        }
        if (!directory.isEmpty) metadata.addDirectory(directory)
    }

    // adapted from `XmpReader` because original is private
    private fun getExtendedXMPGUID(metadata: Metadata): String? {
        val xmpDirectories = metadata.getDirectoriesOfType(XmpDirectory::class.java)
        for (directory in xmpDirectories) {
            val xmpMeta = directory.xmpMeta
            try {
                val itr = xmpMeta.iterator(SCHEMA_XMP_NOTES, null, null) ?: continue
                while (itr.hasNext()) {
                    val pi = itr.next() as XMPPropertyInfo?
                    if (ATTRIBUTE_EXTENDED_XMP == pi!!.path) {
                        return pi.value
                    }
                }
            } catch (e: XMPException) {
                // Fail silently here: we had a reading issue, not a decoding issue.
            }
        }
        return null
    }

    // adapted from `XmpReader` to prevent large allocation
    private fun processExtendedXMPChunk(metadata: Metadata, segmentBytes: ByteArray, extendedXMPGUID: String, extendedXMPBufferIn: ByteArray?, onDangerSize: (fullLength: Int) -> Unit): ByteArray? {
        var extendedXMPBuffer: ByteArray? = extendedXMPBufferIn
        val extensionPreambleLength = XMP_EXTENSION_JPEG_PREAMBLE.length
        val segmentLength = segmentBytes.size
        val totalOffset = extensionPreambleLength + EXTENDED_XMP_GUID_LENGTH + EXTENDED_XMP_INT_LENGTH + EXTENDED_XMP_INT_LENGTH
        if (segmentLength >= totalOffset) {
            try {
                val reader: SequentialReader = SequentialByteArrayReader(segmentBytes)
                reader.skip(extensionPreambleLength.toLong())
                val segmentGUID = reader.getString(EXTENDED_XMP_GUID_LENGTH)
                if (extendedXMPGUID == segmentGUID) {
                    val fullLength = reader.uInt32.toInt()
                    val chunkOffset = reader.uInt32.toInt()
                    if (extendedXMPBuffer == null) {
                        // TLAD insert start
                        if (fullLength > SEGMENT_TYPE_SIZE_DANGER_THRESHOLD) {
                            onDangerSize(fullLength)
                            return null
                        }
                        // TLAD insert end
                        extendedXMPBuffer = ByteArray(fullLength)
                    }
                    if (extendedXMPBuffer.size == fullLength) {
                        System.arraycopy(segmentBytes, totalOffset, extendedXMPBuffer, chunkOffset, segmentLength - totalOffset)
                    } else {
                        val directory = XmpDirectory()
                        directory.addError(String.format(Locale.ROOT, "Inconsistent length for the Extended XMP buffer: %d instead of %d", fullLength, extendedXMPBuffer.size))
                        metadata.addDirectory(directory)
                    }
                }
            } catch (ex: IOException) {
                val directory = XmpDirectory()
                directory.addError(ex.message)
                metadata.addDirectory(directory)
            }
        }
        return extendedXMPBuffer
    }

    private fun logError(metadata: Metadata, size: Int) {
        val error = "Extended XMP is too large, with a size of $size B"
        Log.w(LOG_TAG, error)
        metadata.addDirectory(XmpDirectory().apply {
            addError(error)
        })
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<SafeXmpReader>()

        // arbitrary size to detect extended XMP that may yield an OOM
        const val SEGMENT_TYPE_SIZE_DANGER_THRESHOLD = 3 * (1 shl 20) // MB

        // tighter node limits for faster loading
        val PARSE_OPTIONS: ParseOptions = ParseOptions().setXMPNodesToLimit(
            mapOf(
                "photoshop:DocumentAncestors" to 200,
                "xmpMM:History" to 200,
            )
        )

        private const val XMP_JPEG_PREAMBLE = "http://ns.adobe.com/xap/1.0/\u0000"
        private const val XMP_EXTENSION_JPEG_PREAMBLE = "http://ns.adobe.com/xmp/extension/\u0000"
        private const val SCHEMA_XMP_NOTES = "http://ns.adobe.com/xmp/note/"
        private const val ATTRIBUTE_EXTENDED_XMP = "xmpNote:HasExtendedXMP"
        private const val EXTENDED_XMP_GUID_LENGTH = 32
        private const val EXTENDED_XMP_INT_LENGTH = 4
    }
}