package deckers.thibault.aves.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.graphics.createBitmap
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

    // arbitrary size to detect buffer that may yield an OOM
    private const val BUFFER_SIZE_DANGER_THRESHOLD = 3 * (1 shl 20) // MB

    private val freeBaos = ArrayList<ByteArrayOutputStream>()
    private val mutex = Mutex()

    const val ARGB_8888_BYTE_SIZE = 4
    private const val RGBA_1010102_BYTE_SIZE = 4

    suspend fun Bitmap.getBytes(canHaveAlpha: Boolean = false, quality: Int = 100, recycle: Boolean): ByteArray? {
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
            // the Bitmap raw bytes are not decodable by Flutter
            // we need to format them (compress, or add a BMP header) before sending them
            // `Bitmap.CompressFormat.PNG` is slower than `JPEG`, but it allows transparency
            // the BMP format allows an alpha channel, but Android decoding seems to ignore it
            if (canHaveAlpha && hasAlpha()) {
                this.compress(Bitmap.CompressFormat.PNG, quality, stream)
            } else {
                this.compress(Bitmap.CompressFormat.JPEG, quality, stream)
            }
            if (recycle) this.recycle()

            val bufferSize = stream.size()
            if (bufferSize > BUFFER_SIZE_DANGER_THRESHOLD && !MemoryUtils.canAllocate(bufferSize)) {
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

    // On some devices, RGBA_1010102 config can be displayed directly from the hardware buffer,
    // but the native image decoder cannot convert RGBA_1010102 to another config like ARGB_8888,
    // so we manually check the config and convert the pixels as a fallback mechanism.
    fun tryPixelFormatConversion(bitmap: Bitmap): Bitmap? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && bitmap.config == Bitmap.Config.RGBA_1010102) {
            val byteCount = bitmap.byteCount
            if (MemoryUtils.canAllocate(byteCount)) {
                val bytes = ByteBuffer.allocate(byteCount).apply {
                    bitmap.copyPixelsToBuffer(this)
                    rewind()
                }.array()
                val srcColorSpace = bitmap.colorSpace
                if (srcColorSpace != null) {
                    val dstColorSpace = ColorSpace.get(ColorSpace.Named.SRGB)
                    val connector = ColorSpace.connect(srcColorSpace, dstColorSpace)
                    rgba1010102toArgb8888(bytes, connector)

                    val hasAlpha = false
                    return createBitmap(
                        bitmap.width,
                        bitmap.height,
                        Bitmap.Config.ARGB_8888,
                        hasAlpha = hasAlpha,
                        colorSpace = dstColorSpace,
                    ).apply {
                        copyPixelsFromBuffer(ByteBuffer.wrap(bytes))
                    }
                }
            }
        }
        return null
    }

    // convert bytes, without reallocation:
    // - from config RGBA_1010102 to ARGB_8888,
    // - from original color space to sRGB.
    @RequiresApi(Build.VERSION_CODES.O)
    private fun rgba1010102toArgb8888(bytes: ByteArray, connector: ColorSpace.Connector) {
        val max10Bits = 0x3ff.toFloat()
        val dstAlpha = 0xff.toByte()

        val byteCount = bytes.size
        for (i in 0..<byteCount step RGBA_1010102_BYTE_SIZE) {
            val i3 = bytes[i + 3].toInt()
            val i2 = bytes[i + 2].toInt()
            val i1 = bytes[i + 1].toInt()
            val i0 = bytes[i].toInt()

            // unpacking from RGBA_1010102
            // stored as [3,2,1,0] -> [AABBBBBB BBBBGGGG GGGGGGRR RRRRRRRR]
//            val iA = ((i3 and 0xc0) shr 6)
            val iB = ((i3 and 0x3f) shl 4) or ((i2 and 0xf0) shr 4)
            val iG = ((i2 and 0x0f) shl 6) or ((i1 and 0xfc) shr 2)
            val iR = ((i1 and 0x03) shl 8) or ((i0 and 0xff) shr 0)

            // components as floats in sRGB
            val srgbFloats = connector.transform(iR / max10Bits, iG / max10Bits, iB / max10Bits)
            val srgbR = (srgbFloats[0] * 255.0f + 0.5f).toInt()
            val srgbG = (srgbFloats[1] * 255.0f + 0.5f).toInt()
            val srgbB = (srgbFloats[2] * 255.0f + 0.5f).toInt()

            // packing to ARGB_8888
            // stored as [3,2,1,0] -> [AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR]
            bytes[i + 3] = dstAlpha
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
