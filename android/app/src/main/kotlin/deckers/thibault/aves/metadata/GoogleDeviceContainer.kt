package deckers.thibault.aves.metadata

import android.content.Context
import android.net.Uri
import com.adobe.internal.xmp.XMPMeta
import deckers.thibault.aves.metadata.XMP.countPropPathArrayItems
import deckers.thibault.aves.metadata.XMP.getSafeStructField
import deckers.thibault.aves.utils.indexOfBytes
import java.io.DataInputStream

class GoogleDeviceContainer {
    private val jfifSignature = byteArrayOf(0xFF.toByte(), 0xD8.toByte(), 0xFF.toByte(), 0xE0.toByte(), 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01)

    private val items: MutableList<GoogleDeviceContainerItem> = ArrayList()
    private val offsets: MutableList<Int> = ArrayList()

    fun findItems(xmpMeta: XMPMeta) {
        val containerDirectoryPath = listOf(XMP.GDEVICE_CONTAINER_PROP_NAME, XMP.GDEVICE_CONTAINER_DIRECTORY_PROP_NAME)
        val count = xmpMeta.countPropPathArrayItems(containerDirectoryPath)
        for (i in 1 until count + 1) {
            val mimeType = xmpMeta.getSafeStructField(containerDirectoryPath + listOf(i, XMP.GDEVICE_CONTAINER_ITEM_MIME_PROP_NAME))?.value
            val length = xmpMeta.getSafeStructField(containerDirectoryPath + listOf(i, XMP.GDEVICE_CONTAINER_ITEM_LENGTH_PROP_NAME))?.value?.toLongOrNull()
            val dataUri = xmpMeta.getSafeStructField(containerDirectoryPath + listOf(i, XMP.GDEVICE_CONTAINER_ITEM_DATA_URI_PROP_NAME))?.value
            if (mimeType != null && length != null && dataUri != null) {
                items.add(
                    GoogleDeviceContainerItem(
                        mimeType = mimeType,
                        length = length,
                        dataUri = dataUri,
                    )
                )
            } else throw Exception("failed to extract Google device container item at index=$i with mimeType=$mimeType, length=$length, dataUri=$dataUri")
        }
    }

    fun findOffsets(context: Context, uri: Uri, mimeType: String, sizeBytes: Long) {
        Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
            val bytes = ByteArray(sizeBytes.toInt())
            DataInputStream(input).use {
                it.readFully(bytes)
            }

            var start = 0
            while (start < sizeBytes) {
                val offset = bytes.indexOfBytes(jfifSignature, start)
                if (offset != -1 && offset >= start) {
                    start = offset + jfifSignature.size
                    offsets.add(offset)
                } else {
                    start = sizeBytes.toInt()
                }
            }
        }

        // fix first offset as it may refer to included thumbnail instead of primary image
        while (offsets.size < items.size) {
            offsets.add(0, 0)
        }
        offsets[0] = 0
    }

    fun itemIndex(dataUri: String) = items.indexOfFirst { it.dataUri == dataUri }

    private fun item(index: Int): GoogleDeviceContainerItem? {
        return if (0 <= index && index < items.size) {
            items[index]
        } else null
    }

    fun itemStartOffset(index: Int): Long? {
        return if (0 <= index && index < offsets.size) {
            offsets[index].toLong()
        } else null
    }

    fun itemLength(index: Int): Long? {
        val lengthByMeta = item(index)?.length ?: return null
        return if (lengthByMeta != 0L) lengthByMeta else itemStartOffset(index + 1)
    }

    fun itemMimeType(index: Int) = item(index)?.mimeType
}

class GoogleDeviceContainerItem(val mimeType: String, val length: Long, val dataUri: String)
