package deckers.thibault.aves.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.os.Build
import android.util.Half
import android.util.Log
import androidx.annotation.RequiresApi
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import deckers.thibault.aves.metadata.Metadata.getExifCode
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

object BitmapUtils {
    private val LOG_TAG = LogUtils.createTag<BitmapUtils>()
    private const val INITIAL_BUFFER_SIZE = 2 shl 17 // 256kB

    private val freeBaos = ArrayList<ByteArrayOutputStream>()
    private val mutex = Mutex()

    private const val INT_BYTE_SIZE = 4
    private const val MAX_2_BITS_FLOAT = 0x3.toFloat()
    private const val MAX_8_BITS_FLOAT = 0xff.toFloat()
    private const val MAX_10_BITS_FLOAT = 0x3ff.toFloat()

    private const val FORMAT_BYTE_ENCODED: Int = 0xCA
    private const val FORMAT_BYTE_DECODED: Byte = 0xFE.toByte()
    private const val RAW_BYTES_TRAILER_LENGTH = INT_BYTE_SIZE * 2 + 1

    // bytes per pixel with different bitmap config
    private const val BPP_ALPHA_8 = 1
    private const val BPP_RGB_565 = 2
    private const val BPP_ARGB_8888 = 4
    private const val BPP_RGBA_1010102 = 4
    private const val BPP_RGBA_F16 = 8

    private fun getBytePerPixel(config: Bitmap.Config?): Int {
        return when (config) {
            Bitmap.Config.ALPHA_8 -> BPP_ALPHA_8
            Bitmap.Config.RGB_565 -> BPP_RGB_565
            Bitmap.Config.ARGB_8888 -> BPP_ARGB_8888
            else -> {
                return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && config == Bitmap.Config.RGBA_F16) {
                    BPP_RGBA_F16
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && config == Bitmap.Config.RGBA_1010102) {
                    BPP_RGBA_1010102
                } else {
                    // default
                    BPP_ARGB_8888
                }
            }
        }
    }

    fun getExpectedImageSize(pixelCount: Long, config: Bitmap.Config?): Long {
        return pixelCount * getBytePerPixel(config)
    }

    suspend fun getBytes(bitmap: Bitmap?, recycle: Boolean, decoded: Boolean, mimeType: String?): ByteArray? {
        return if (decoded) {
            getRawBytes(bitmap, recycle = recycle)
        } else {
            getEncodedBytes(bitmap, canHaveAlpha = MimeTypes.canHaveAlpha(mimeType), recycle = recycle)
        }
    }

    private fun getRawBytes(bitmap: Bitmap?, recycle: Boolean): ByteArray? {
        bitmap ?: return null

        val byteCount = bitmap.byteCount
        val width = bitmap.width
        val height = bitmap.height
        val config = bitmap.config
        val colorSpace = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) bitmap.colorSpace else null

        if (!MemoryUtils.canAllocate(byteCount)) {
            throw Exception("bitmap buffer is $byteCount bytes, which cannot be allocated to a new byte array")
        }

        try {
            // `ByteBuffer` initial order is always `BIG_ENDIAN`
            var bytes = ByteBuffer.allocate(byteCount + RAW_BYTES_TRAILER_LENGTH).apply {
                bitmap.copyPixelsToBuffer(this)
            }.array()

            // do not access bitmap after recycling
            if (recycle) bitmap.recycle()

            // convert pixel format and color space, if necessary
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                colorSpace?.let { srcColorSpace ->
                    val dstColorSpace = ColorSpace.get(ColorSpace.Named.SRGB)
                    val connector = ColorSpace.connect(srcColorSpace, dstColorSpace)
                    if (config == Bitmap.Config.ARGB_8888) {
                        if (srcColorSpace != dstColorSpace) {
                            argb8888ToArgb8888(bytes, connector, end = byteCount)
                        }
                    } else if (config == Bitmap.Config.RGBA_F16) {
                        rgbaf16ToArgb8888(bytes, connector, end = byteCount)
                        val newConfigByteCount = byteCount / (BPP_RGBA_F16 / BPP_ARGB_8888)
                        bytes = bytes.sliceArray(0..<newConfigByteCount + RAW_BYTES_TRAILER_LENGTH)
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && config == Bitmap.Config.RGBA_1010102) {
                        rgba1010102ToArgb8888(bytes, connector, end = byteCount)
                    }
                }
            }

            // append bitmap size for use by the caller to interpret the raw bytes
            val trailerOffset = bytes.size - RAW_BYTES_TRAILER_LENGTH
            bytes = ByteBuffer.wrap(bytes).apply {
                position(trailerOffset)
                putInt(width)
                putInt(height)
                // trailer byte to indicate whether the returned bytes are decoded/encoded
                put(FORMAT_BYTE_DECODED)
            }.array()

            return bytes
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to get bytes from bitmap", e)
        }
        return null
    }

    private suspend fun getEncodedBytes(bitmap: Bitmap?, canHaveAlpha: Boolean = false, quality: Int = 100, recycle: Boolean): ByteArray? {
        bitmap ?: return null

        val stream: ByteArrayOutputStream
        mutex.withLock {
            // this method is called a lot, so we try and reuse output streams
            // to reduce inner array allocations, and make the GC run less frequently
            stream = if (freeBaos.isNotEmpty()) {
                freeBaos.removeAt(0)
            } else {
                ByteArrayOutputStream(INITIAL_BUFFER_SIZE)
            }
        }
        try {
            // `Bitmap.CompressFormat.PNG` is slower than `JPEG`, but it allows transparency
            // the BMP format allows an alpha channel, but Android decoding seems to ignore it
            if (canHaveAlpha && bitmap.hasAlpha()) {
                bitmap.compress(Bitmap.CompressFormat.PNG, quality, stream)
            } else {
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
            }
            if (recycle) bitmap.recycle()

            // trailer byte to indicate whether the returned bytes are decoded/encoded
            stream.write(FORMAT_BYTE_ENCODED)

            val bufferSize = stream.size()
            if (!MemoryUtils.canAllocate(bufferSize)) {
                throw Exception("bitmap compressed to $bufferSize bytes, which cannot be allocated to a new byte array")
            }

            val byteArray = stream.toByteArray()
            stream.reset()
            mutex.withLock {
                freeBaos.add(stream)
            }
            return byteArray
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to get bytes from bitmap", e)
        }
        return null
    }

    // convert bytes, without reallocation:
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    private fun argb8888ToArgb8888(bytes: ByteArray, connector: ColorSpace.Connector, start: Int = 0, end: Int = bytes.size) {
        // unpacking from ARGB_8888 and packing to ARGB_8888
        // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
        for (i in start..<end step BPP_ARGB_8888) {
            // mask with `0xff` to yield values in [0, 255], instead of [-128, 127]
            val iB = bytes[i + 2].toInt() and 0xff
            val iG = bytes[i + 1].toInt() and 0xff
            val iR = bytes[i].toInt() and 0xff

            // components as floats in sRGB
            val srgbFloats = connector.transform(iR / MAX_8_BITS_FLOAT, iG / MAX_8_BITS_FLOAT, iB / MAX_8_BITS_FLOAT)
            val srgbR = (srgbFloats[0] * 255.0f + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * 255.0f + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * 255.0f + 0.5f).toInt()

            // keep alpha as it is, in `bytes[i + 3]`
            bytes[i + 2] = srgbB.toByte()
            bytes[i + 1] = srgbG.toByte()
            bytes[i] = srgbR.toByte()
        }
    }

    // convert bytes, without reallocation:
    // - from config RGBA_F16 to ARGB_8888,
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    private fun rgbaf16ToArgb8888(bytes: ByteArray, connector: ColorSpace.Connector, start: Int = 0, end: Int = bytes.size) {
        val indexDivider = BPP_RGBA_F16 / BPP_ARGB_8888
        for (i in start..<end step BPP_RGBA_F16) {
            // unpacking from RGBA_F16
            // stored as [7,6,5,4,3,2,1,0] -> [AAAAAAAA AAAAAAAA BBBBBBBB BBBBBBBB GGGGGGGG GGGGGGGG RRRRRRRR RRRRRRRR]
            val i7 = bytes[i + 7].toInt()
            val i6 = bytes[i + 6].toInt()
            val i5 = bytes[i + 5].toInt()
            val i4 = bytes[i + 4].toInt()
            val i3 = bytes[i + 3].toInt()
            val i2 = bytes[i + 2].toInt()
            val i1 = bytes[i + 1].toInt()
            val i0 = bytes[i].toInt()

            val hA = Half((((i7 and 0xff) shl 8) or (i6 and 0xff)).toShort())
            val hB = Half((((i5 and 0xff) shl 8) or (i4 and 0xff)).toShort())
            val hG = Half((((i3 and 0xff) shl 8) or (i2 and 0xff)).toShort())
            val hR = Half((((i1 and 0xff) shl 8) or (i0 and 0xff)).toShort())

            // components as floats in sRGB
            val srgbFloats = connector.transform(hR.toFloat(), hG.toFloat(), hB.toFloat())
            val srgbR = (srgbFloats[0] * 255.0f + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * 255.0f + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * 255.0f + 0.5f).toInt()
            val alpha = (hA.toFloat() * 255.0f + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            val dstI = i / indexDivider
            bytes[dstI + 3] = alpha.toByte()
            bytes[dstI + 2] = srgbB.toByte()
            bytes[dstI + 1] = srgbG.toByte()
            bytes[dstI] = srgbR.toByte()
        }
    }

    // convert bytes, without reallocation:
    // - from config RGBA_1010102 to ARGB_8888,
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    private fun rgba1010102ToArgb8888(bytes: ByteArray, connector: ColorSpace.Connector, start: Int = 0, end: Int = bytes.size) {
        val alphaFactor = 255.0f / MAX_2_BITS_FLOAT

        for (i in start..<end step BPP_RGBA_1010102) {
            // unpacking from RGBA_1010102
            // stored as [3,2,1,0] -> [AABBBBBB BBBBGGGG GGGGGGRR RRRRRRRR]
            val i3 = bytes[i + 3].toInt()
            val i2 = bytes[i + 2].toInt()
            val i1 = bytes[i + 1].toInt()
            val i0 = bytes[i].toInt()

            val iA = ((i3 and 0xc0) shr 6)
            val iB = ((i3 and 0x3f) shl 4) or ((i2 and 0xf0) shr 4)
            val iG = ((i2 and 0x0f) shl 6) or ((i1 and 0xfc) shr 2)
            val iR = ((i1 and 0x03) shl 8) or ((i0 and 0xff) shr 0)

            // components as floats in sRGB
            val srgbFloats = connector.transform(iR / MAX_10_BITS_FLOAT, iG / MAX_10_BITS_FLOAT, iB / MAX_10_BITS_FLOAT)
            val srgbR = (srgbFloats[0] * 255.0f + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * 255.0f + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * 255.0f + 0.5f).toInt()
            val alpha = (iA * alphaFactor + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            bytes[i + 3] = alpha.toByte()
            bytes[i + 2] = srgbB.toByte()
            bytes[i + 1] = srgbG.toByte()
            bytes[i] = srgbR.toByte()
        }
    }

    fun applyExifOrientation(context: Context, bitmap: Bitmap?, rotationDegrees: Int?, isFlipped: Boolean?): Bitmap? {
        if (bitmap == null || rotationDegrees == null || isFlipped == null) return bitmap
        if (rotationDegrees == 0 && !isFlipped) return bitmap
        val exifOrientation = getExifCode(rotationDegrees, isFlipped)
        return TransformationUtils.rotateImageExif(getBitmapPool(context), bitmap, exifOrientation)
    }

    fun centerSquareCrop(context: Context, bitmap: Bitmap?, size: Int): Bitmap? {
        bitmap ?: return null
        return TransformationUtils.centerCrop(getBitmapPool(context), bitmap, size, size)
    }

    fun getBitmapPool(context: Context) = Glide.get(context).bitmapPool
}
