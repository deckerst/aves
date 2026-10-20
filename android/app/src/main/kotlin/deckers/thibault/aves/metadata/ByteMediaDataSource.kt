package deckers.thibault.aves.metadata

import android.media.MediaDataSource

class ByteMediaDataSource(val bytes: ByteArray) : MediaDataSource() {
    override fun getSize(): Long {
        return bytes.size.toLong()
    }

    override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
        if (position >= bytes.size.toLong()) return -1

        var effectiveSize = size
        if (position + size.toLong() > bytes.size.toLong()) {
            effectiveSize = (bytes.size.toLong() - position).toInt()
        }

        System.arraycopy(bytes, position.toInt(), buffer, offset, effectiveSize)
        return effectiveSize
    }

    override fun close() {
        // nothing
    }
}