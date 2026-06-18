package deckers.thibault.aves.utils

import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.os.Build
import android.util.Half
import androidx.annotation.RequiresApi
import java.nio.ByteBuffer
import java.nio.ByteOrder


object BitmapConversion {

    private const val MAX_2_BITS_FLOAT = 0x3.toFloat()
    const val MAX_8_BITS_FLOAT = 0xff.toFloat()
    private const val MAX_10_BITS_FLOAT = 0x3ff.toFloat()

    // bytes per pixel with different bitmap config
    private const val BPP_ALPHA_8 = 1
    private const val BPP_RGB_565 = 2
    private const val BPP_ARGB_8888 = 4
    private const val BPP_RGBA_1010102 = 4
    private const val BPP_RGBA_F16 = 8
    private const val BPP_DART_RGBA_FLOAT32 = 16

    const val CONFIG_ANDROID_ALPHA_8 = 0
    const val CONFIG_ANDROID_RGB_565 = 1
    const val CONFIG_ANDROID_ARGB_8888 = 2
    const val CONFIG_ANDROID_RGBA_F16 = 3
    const val CONFIG_ANDROID_RGBA_1010102 = 4
    const val CONFIG_DART_RGBA_FLOAT32 = 5

    fun toCustomConfig(config: Bitmap.Config?): Int {
        return when (config) {
            Bitmap.Config.ALPHA_8 -> CONFIG_ANDROID_ALPHA_8
            Bitmap.Config.RGB_565 -> CONFIG_ANDROID_RGB_565
            Bitmap.Config.ARGB_8888 -> CONFIG_ANDROID_ARGB_8888
            else -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && config == Bitmap.Config.RGBA_F16) {
                    CONFIG_ANDROID_RGBA_F16
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && config == Bitmap.Config.RGBA_1010102) {
                    CONFIG_ANDROID_RGBA_1010102
                } else {
                    // default
                    CONFIG_ANDROID_ARGB_8888
                }
            }
        }
    }

    fun getBytePerPixel(config: Int): Int {
        return when (config) {
            CONFIG_ANDROID_ALPHA_8 -> BPP_ALPHA_8
            CONFIG_ANDROID_RGB_565 -> BPP_RGB_565
            CONFIG_ANDROID_ARGB_8888 -> BPP_ARGB_8888
            CONFIG_ANDROID_RGBA_F16 -> BPP_RGBA_F16
            CONFIG_ANDROID_RGBA_1010102 -> BPP_RGBA_1010102
            CONFIG_DART_RGBA_FLOAT32 -> BPP_DART_RGBA_FLOAT32
            else -> BPP_ARGB_8888
        }
    }

    // convert bytes, without reallocation:
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromArgb8888ToArgb8888(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size
    ): ByteArray {
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

        return bytes
    }

    // convert bytes, without reallocation:
    // - from config ARGB_8888 to RGBA_1010102,
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromArgb8888ToRgba1010102(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size,
    ): ByteArray {
        // unpacking from ARGB_8888 and packing to RGBA_1010102
        // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
        for (i in start..<end step BPP_ARGB_8888) {
            // mask with `0xff` to yield values in [0, 255], instead of [-128, 127]
            val iA = bytes[i + 3].toInt() and 0xff
            val iB = bytes[i + 2].toInt() and 0xff
            val iG = bytes[i + 1].toInt() and 0xff
            val iR = bytes[i].toInt() and 0xff

            // components as floats in sRGB
            val srgbFloats = connector.transform(iR / MAX_8_BITS_FLOAT, iG / MAX_8_BITS_FLOAT, iB / MAX_8_BITS_FLOAT)
            val srgbR = (srgbFloats[0] * MAX_10_BITS_FLOAT + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * MAX_10_BITS_FLOAT + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * MAX_10_BITS_FLOAT + 0.5f).toInt()
            val iA2 = (iA / MAX_8_BITS_FLOAT * MAX_2_BITS_FLOAT + 0.5f).toInt()

            // packing to RGBA_1010102
            // stored as [3,2,1,0] -> [AABBBBBB BBBBGGGG GGGGGGRR RRRRRRRR]
            bytes[i + 3] = (((iA2 and 0x3) shl 6) or ((srgbB and 0x3f0) shr 4)).toByte()
            bytes[i + 2] = (((srgbB and 0x00f) shl 4) or ((srgbG and 0x3c0) shr 6)).toByte()
            bytes[i + 1] = (((srgbG and 0x03f) shl 2) or ((srgbR and 0x300) shr 8)).toByte()
            bytes[i] = (srgbR and 0x0ff).toByte()
        }

        return bytes
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun fromArgb8888ToDartRgbaFloat32(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size,
        gainmapPixelTransformer: PixelTransformer?
    ): ByteArray {
        val size = BPP_DART_RGBA_FLOAT32 / BPP_ARGB_8888
        val dstByteBuffer = ByteBuffer.allocate(end * size + BitmapUtils.RAW_BYTES_TRAILER_LENGTH)
        // match byte order expected on the Dart side
        dstByteBuffer.order(ByteOrder.LITTLE_ENDIAN)

        // unpacking from ARGB_8888 and packing to RGBA_1010102
        // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
        for (i in start..<end step BPP_ARGB_8888) {
            // mask with `0xff` to yield values in [0, 255], instead of [-128, 127]
            val iA = bytes[i + 3].toInt() and 0xff
            val iB = bytes[i + 2].toInt() and 0xff
            val iG = bytes[i + 1].toInt() and 0xff
            val iR = bytes[i].toInt() and 0xff

            // components as floats in sRGB
            var srgbFloats = connector.transform(iR / MAX_8_BITS_FLOAT, iG / MAX_8_BITS_FLOAT, iB / MAX_8_BITS_FLOAT)
            if (gainmapPixelTransformer != null) {
                val pixelIndex = i / BPP_ARGB_8888
                srgbFloats = gainmapPixelTransformer(pixelIndex, srgbFloats)
            }

            val fR = srgbFloats[0]
            val fG = srgbFloats[1]
            val fB = srgbFloats[2]
            val fA = iA / MAX_8_BITS_FLOAT

            // packing to RGBA_FLOAT32
            dstByteBuffer.putFloat(fR)
            dstByteBuffer.putFloat(fG)
            dstByteBuffer.putFloat(fB)
            dstByteBuffer.putFloat(fA)
        }

        return dstByteBuffer.array()
    }

    // convert bytes, without reallocation:
    // - from config RGBA_F16 to ARGB_8888,
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromRgbaf16ToArgb8888(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size
    ): ByteArray {
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
            val srgbR = (srgbFloats[0] * MAX_8_BITS_FLOAT + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * MAX_8_BITS_FLOAT + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * MAX_8_BITS_FLOAT + 0.5f).toInt()
            val alpha = (hA.toFloat() * MAX_8_BITS_FLOAT + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            val dstI = i / indexDivider
            bytes[dstI + 3] = alpha.toByte()
            bytes[dstI + 2] = srgbB.toByte()
            bytes[dstI + 1] = srgbG.toByte()
            bytes[dstI] = srgbR.toByte()
        }

        // truncate as it takes fewer bytes
        val newConfigByteCount = end / indexDivider
        return bytes.sliceArray(0..<newConfigByteCount + BitmapUtils.RAW_BYTES_TRAILER_LENGTH)
    }

    // convert bytes, without reallocation:
    // - from config RGBA_1010102 to ARGB_8888,
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromRgba1010102ToArgb8888(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size
    ): ByteArray {
        val alphaFactor = MAX_8_BITS_FLOAT / MAX_2_BITS_FLOAT

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
            val srgbR = (srgbFloats[0] * MAX_8_BITS_FLOAT + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * MAX_8_BITS_FLOAT + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * MAX_8_BITS_FLOAT + 0.5f).toInt()
            val alpha = (iA * alphaFactor + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            bytes[i + 3] = alpha.toByte()
            bytes[i + 2] = srgbB.toByte()
            bytes[i + 1] = srgbG.toByte()
            bytes[i] = srgbR.toByte()
        }

        return bytes
    }
}