package deckers.thibault.aves.utils

import android.graphics.Bitmap
import java.io.OutputStream
import java.nio.ByteBuffer

object BmpWriter {
    private const val FILE_HEADER_SIZE = 14
    private const val INFO_HEADER_SIZE = 40
    private const val BYTE_PER_PIXEL = 3
    private val pad = ByteArray(3)

    // file header
    private val bfType = byteArrayOf('B'.code.toByte(), 'M'.code.toByte())
    private val bfReserved1 = intToWord(0)
    private val bfReserved2 = intToWord(0)
    private val bfOffBits = intToDWord(FILE_HEADER_SIZE + INFO_HEADER_SIZE)

    // info header
    private val biSize = intToDWord(INFO_HEADER_SIZE)
    private val biPlanes = intToWord(1)
    private val biBitCount = intToWord(BYTE_PER_PIXEL * 8)
    private val biCompression = intToDWord(0)
    private val biXPelsPerMeter = intToDWord(0)
    private val biYPelsPerMeter = intToDWord(0)
    private val biClrUsed = intToDWord(0)
    private val biClrImportant = intToDWord(0)

    // converts an int to a word (2-byte array)
    private fun intToWord(v: Int): ByteArray {
        val retValue = ByteArray(2)
        retValue[0] = (v and 0xFF).toByte()
        retValue[1] = (v shr 8 and 0xFF).toByte()
        return retValue
    }

    // converts an int to a double word (4-byte array)
    private fun intToDWord(v: Int): ByteArray {
        val retValue = ByteArray(4)
        retValue[0] = (v and 0xFF).toByte()
        retValue[1] = (v shr 8 and 0xFF).toByte()
        retValue[2] = (v shr 16 and 0xFF).toByte()
        retValue[3] = (v shr 24 and 0xFF).toByte()
        return retValue
    }

    fun writeRGB24(
        bitmap: Bitmap,
        outputStream: OutputStream
    ) {
        // init
        val biWidth = bitmap.width
        val biHeight = bitmap.height
        val padPerRow = (4 - (biWidth * BYTE_PER_PIXEL) % 4) % 4
        val biSizeImage = (biWidth * BYTE_PER_PIXEL + padPerRow) * biHeight
        val bfSize = FILE_HEADER_SIZE + INFO_HEADER_SIZE + biSizeImage
        val buffer = ByteBuffer.allocate(bfSize)
        val pixels = IntArray(biWidth * biHeight)
        bitmap.getPixels(pixels, 0, biWidth, 0, 0, biWidth, biHeight)

        // file header
        buffer.put(bfType)
        buffer.put(intToDWord(bfSize))
        buffer.put(bfReserved1)
        buffer.put(bfReserved2)
        buffer.put(bfOffBits)

        // info header
        buffer.put(biSize)
        buffer.put(intToDWord(biWidth))
        buffer.put(intToDWord(biHeight))
        buffer.put(biPlanes)
        buffer.put(biBitCount)
        buffer.put(biCompression)
        buffer.put(intToDWord(biSizeImage))
        buffer.put(biXPelsPerMeter)
        buffer.put(biYPelsPerMeter)
        buffer.put(biClrUsed)
        buffer.put(biClrImportant)

        // pixels
        val rgb = ByteArray(BYTE_PER_PIXEL)
        var value: Int
        var row = biHeight - 1
        while (row >= 0) {
            var column = 0
            while (column < biWidth) {
                /*
                    alpha: (value shr 24 and 0xFF).toByte()
                    red: (value shr 16 and 0xFF).toByte()
                    green: (value shr 8 and 0xFF).toByte()
                    blue: (value and 0xFF).toByte()
                 */
                value = pixels[row * biWidth + column]
                // blue: [0], green: [1], red: [2]
                rgb[0] = (value and 0xFF).toByte()
                rgb[1] = (value shr 8 and 0xFF).toByte()
                rgb[2] = (value shr 16 and 0xFF).toByte()
                buffer.put(rgb)
                column++
            }
            if (padPerRow > 0) {
                buffer.put(pad, 0, padPerRow)
            }
            row--
        }

        // write to output stream
        outputStream.write(buffer.array())
    }
}
