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
    // - keep config ARGB_8888,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromArgb8888ToArgb8888(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size
    ): ByteArray {
        val srcBpp = BPP_ARGB_8888
        val srcMax = MAX_8_BITS_FLOAT
        val dstMax = MAX_8_BITS_FLOAT

        // unpacking from ARGB_8888 and packing to ARGB_8888
        // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
        for (i in start..<end step srcBpp) {
            val (iR, iG, iB, _) = unpackArgb8888(bytes, i)

            // components as floats in destination color space
            val dstSpaceFloats = connector.transform(iR / srcMax, iG / srcMax, iB / srcMax)
            val dstSpaceR = (dstSpaceFloats[0] * dstMax + 0.5f).toInt()
            val dstSpaceG = (dstSpaceFloats[1] * dstMax + 0.5f).toInt()
            val dstSpaceB = (dstSpaceFloats[2] * dstMax + 0.5f).toInt()

            // keep alpha as it is, in `bytes[i + 3]`
            bytes[i + 2] = dstSpaceB.toByte()
            bytes[i + 1] = dstSpaceG.toByte()
            bytes[i] = dstSpaceR.toByte()
        }

        return bytes
    }

    // convert bytes, without reallocation:
    // - from config ARGB_8888 to RGBA_1010102,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromArgb8888ToRgba1010102(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size,
    ): ByteArray {
        val srcBpp = BPP_ARGB_8888
        val srcMax = MAX_8_BITS_FLOAT
        val dstMax = MAX_10_BITS_FLOAT

        val alphaFactor = MAX_2_BITS_FLOAT / srcMax

        // unpacking from ARGB_8888 and packing to RGBA_1010102
        // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
        for (i in start..<end step srcBpp) {
            val (iR, iG, iB, iA) = unpackArgb8888(bytes, i)

            // components as floats in destination color space
            val dstSpaceFloats = connector.transform(iR / srcMax, iG / srcMax, iB / srcMax)
            val dstSpaceR = (dstSpaceFloats[0] * dstMax + 0.5f).toInt()
            val dstSpaceG = (dstSpaceFloats[1] * dstMax + 0.5f).toInt()
            val dstSpaceB = (dstSpaceFloats[2] * dstMax + 0.5f).toInt()
            val iA2 = (iA * alphaFactor + 0.5f).toInt()

            // packing to RGBA_1010102
            // stored as [3,2,1,0] -> [AABBBBBB BBBBGGGG GGGGGGRR RRRRRRRR]
            bytes[i + 3] = (((iA2 and 0x3) shl 6) or ((dstSpaceB and 0x3f0) shr 4)).toByte()
            bytes[i + 2] = (((dstSpaceB and 0x00f) shl 4) or ((dstSpaceG and 0x3c0) shr 6)).toByte()
            bytes[i + 1] = (((dstSpaceG and 0x03f) shl 2) or ((dstSpaceR and 0x300) shr 8)).toByte()
            bytes[i] = (dstSpaceR and 0x0ff).toByte()
        }

        return bytes
    }

    // convert bytes, with reallocation:
    // - from config ARGB_8888 to Dart `PixelFormat.rgbaFloat32`,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromArgb8888ToDartRgbaFloat32(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size,
        gainmapPixelTransformer: PixelTransformer?
    ): ByteArray {
        val srcBpp = BPP_ARGB_8888
        val srcMax = MAX_8_BITS_FLOAT
        val dstByteBuffer = buildDartRgbaFloat32Buffer(start, end, srcBpp)

        // unpacking from ARGB_8888 and packing to RGBA_1010102
        // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
        for (i in start..<end step srcBpp) {
            val (iR, iG, iB, iA) = unpackArgb8888(bytes, i)

            // components as floats in destination color space
            var dstSpaceFloats = connector.transform(iR / srcMax, iG / srcMax, iB / srcMax)
            if (gainmapPixelTransformer != null) {
                val pixelIndex = (i - start) / srcBpp
                dstSpaceFloats = gainmapPixelTransformer(pixelIndex, dstSpaceFloats)
            }

            // packing to Dart `PixelFormat.rgbaFloat32`
            dstByteBuffer.putFloat(dstSpaceFloats[0]) // red
            dstByteBuffer.putFloat(dstSpaceFloats[1]) // green
            dstByteBuffer.putFloat(dstSpaceFloats[2]) // blue
            dstByteBuffer.putFloat(iA / srcMax) // alpha
        }

        return dstByteBuffer.array()
    }

    // convert bytes, without reallocation:
    // - from config RGBA_F16 to ARGB_8888,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromRgbaf16ToArgb8888(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size
    ): ByteArray {
        val srcBpp = BPP_RGBA_F16
        val dstBpp = BPP_ARGB_8888
        val dstMax = MAX_8_BITS_FLOAT

        val indexDivider = srcBpp / dstBpp
        for (i in start..<end step srcBpp) {
            val (hR, hG, hB, hA) = unpackRgbaf16(bytes, i)

            // components as floats in destination color space
            val dstSpaceFloats = connector.transform(hR.toFloat(), hG.toFloat(), hB.toFloat())
            val dstSpaceR = (dstSpaceFloats[0] * dstMax + 0.5f).toInt()
            val dstSpaceG = (dstSpaceFloats[1] * dstMax + 0.5f).toInt()
            val dstSpaceB = (dstSpaceFloats[2] * dstMax + 0.5f).toInt()
            val alpha = (hA.toFloat() * dstMax + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            val dstI = i / indexDivider
            bytes[dstI + 3] = alpha.toByte()
            bytes[dstI + 2] = dstSpaceB.toByte()
            bytes[dstI + 1] = dstSpaceG.toByte()
            bytes[dstI] = dstSpaceR.toByte()
        }

        // truncate as it takes fewer bytes
        val newConfigByteCount = end / indexDivider
        return bytes.sliceArray(0..<newConfigByteCount + BitmapUtils.RAW_BYTES_TRAILER_LENGTH)
    }

    // convert bytes, with reallocation:
    // - from config RGBA_F16 to Dart `PixelFormat.rgbaFloat32`,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromRgbaf16ToDartRgbaFloat32(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size,
    ): ByteArray {
        val srcBpp = BPP_RGBA_F16
        val dstByteBuffer = buildDartRgbaFloat32Buffer(start, end, srcBpp)

        for (i in start..<end step srcBpp) {
            val (hR, hG, hB, hA) = unpackRgbaf16(bytes, i)

            val dstSpaceFloats = connector.transform(hR.toFloat(), hG.toFloat(), hB.toFloat())
            dstByteBuffer.putFloat(dstSpaceFloats[0]) // red
            dstByteBuffer.putFloat(dstSpaceFloats[1]) // green
            dstByteBuffer.putFloat(dstSpaceFloats[2]) // blue
            dstByteBuffer.putFloat(hA.toFloat()) // alpha
        }

        return dstByteBuffer.array()
    }

    // convert bytes, without reallocation:
    // - from config RGBA_1010102 to ARGB_8888,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromRgba1010102ToArgb8888(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size
    ): ByteArray {
        val srcBpp = BPP_RGBA_1010102
        val srcMax = MAX_10_BITS_FLOAT
        val dstMax = MAX_8_BITS_FLOAT

        val alphaFactor = dstMax / MAX_2_BITS_FLOAT

        for (i in start..<end step srcBpp) {
            val (iR, iG, iB, iA) = unpackRrba1010102(bytes, i)

            // components as floats in destination color space
            val dstSpaceFloats = connector.transform(iR / srcMax, iG / srcMax, iB / srcMax)
            val dstSpaceR = (dstSpaceFloats[0] * dstMax + 0.5f).toInt()
            val dstSpaceG = (dstSpaceFloats[1] * dstMax + 0.5f).toInt()
            val dstSpaceB = (dstSpaceFloats[2] * dstMax + 0.5f).toInt()
            val dstAlpha = (iA * alphaFactor + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            bytes[i + 3] = dstAlpha.toByte()
            bytes[i + 2] = dstSpaceB.toByte()
            bytes[i + 1] = dstSpaceG.toByte()
            bytes[i] = dstSpaceR.toByte()
        }

        return bytes
    }

    // convert bytes, with reallocation:
    // - from config RGBA_1010102 to Dart `PixelFormat.rgbaFloat32`,
    // - convert color space.
    @RequiresApi(Build.VERSION_CODES.O)
    fun fromRgba1010102ToDartRgbaFloat32(
        bytes: ByteArray,
        connector: ColorSpace.Connector,
        start: Int = 0,
        end: Int = bytes.size,
    ): ByteArray {
        val srcBpp = BPP_RGBA_1010102
        val srcMax = MAX_10_BITS_FLOAT
        val dstByteBuffer = buildDartRgbaFloat32Buffer(start, end, srcBpp)

        for (i in start..<end step srcBpp) {
            val (iR, iG, iB, iA) = unpackRrba1010102(bytes, i)

            // components as floats in destination color space
            val dstSpaceFloats = connector.transform(iR / srcMax, iG / srcMax, iB / srcMax)
            dstByteBuffer.putFloat(dstSpaceFloats[0]) // red
            dstByteBuffer.putFloat(dstSpaceFloats[1]) // green
            dstByteBuffer.putFloat(dstSpaceFloats[2]) // blue
            dstByteBuffer.putFloat(iA / MAX_2_BITS_FLOAT) // alpha
        }

        return dstByteBuffer.array()
    }

    private fun buildDartRgbaFloat32Buffer(start: Int, end: Int, srcBpp: Int): ByteBuffer {
        val pixelCount = (end - start) / srcBpp
        val dstByteBuffer = ByteBuffer.allocate(pixelCount * BPP_DART_RGBA_FLOAT32 + BitmapUtils.RAW_BYTES_TRAILER_LENGTH)
        // match byte order expected on the Dart side
        dstByteBuffer.order(ByteOrder.LITTLE_ENDIAN)
        return dstByteBuffer
    }

    // unpacking from ARGB_8888
    // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
    private fun unpackArgb8888(bytes: ByteArray, i: Int): RgbaInt {
        // mask with `0xff` to yield values in [0, 255], instead of [-128, 127]
        return RgbaInt(
            a = bytes[i + 3].toInt() and 0xff,
            b = bytes[i + 2].toInt() and 0xff,
            g = bytes[i + 1].toInt() and 0xff,
            r = bytes[i].toInt() and 0xff,
        )
    }

    // unpacking from RGBA_1010102
    // stored as [3,2,1,0] -> [AABBBBBB BBBBGGGG GGGGGGRR RRRRRRRR]
    private fun unpackRrba1010102(bytes: ByteArray, i: Int): RgbaInt {
        val i3 = bytes[i + 3].toInt()
        val i2 = bytes[i + 2].toInt()
        val i1 = bytes[i + 1].toInt()
        val i0 = bytes[i].toInt()

        return RgbaInt(
            a = ((i3 and 0xc0) shr 6),
            b = ((i3 and 0x3f) shl 4) or ((i2 and 0xf0) shr 4),
            g = ((i2 and 0x0f) shl 6) or ((i1 and 0xfc) shr 2),
            r = ((i1 and 0x03) shl 8) or (i0 and 0xff),
        )
    }

    // unpacking from RGBA_F16
    // stored as [7,6,5,4,3,2,1,0] -> [AAAAAAAA AAAAAAAA BBBBBBBB BBBBBBBB GGGGGGGG GGGGGGGG RRRRRRRR RRRRRRRR]
    @RequiresApi(Build.VERSION_CODES.O)
    private fun unpackRgbaf16(bytes: ByteArray, i: Int): RgbaHalf {
        return RgbaHalf(
            a = Half((((bytes[i + 7].toInt() and 0xff) shl 8) or (bytes[i + 6].toInt() and 0xff)).toShort()),
            b = Half((((bytes[i + 5].toInt() and 0xff) shl 8) or (bytes[i + 4].toInt() and 0xff)).toShort()),
            g = Half((((bytes[i + 3].toInt() and 0xff) shl 8) or (bytes[i + 2].toInt() and 0xff)).toShort()),
            r = Half((((bytes[i + 1].toInt() and 0xff) shl 8) or (bytes[i].toInt() and 0xff)).toShort()),
        )
    }

    data class RgbaInt(val r: Int, val g: Int, val b: Int, val a: Int)
    data class RgbaHalf(val r: Half, val g: Half, val b: Half, val a: Half)
}