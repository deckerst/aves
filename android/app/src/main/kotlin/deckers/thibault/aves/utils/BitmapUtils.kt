package deckers.thibault.aves.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.os.Build
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import deckers.thibault.aves.metadata.Metadata.getExifCode
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

object BitmapUtils {
    private val LOG_TAG = LogUtils.createTag<BitmapUtils>()
    private const val INITIAL_BUFFER_SIZE = 256 * (1 shl 10) // KiB

    private val freeBaos = ArrayList<ByteArrayOutputStream>()
    private val mutex = Mutex()

    const val INT_BYTE_SIZE = 4

    private const val FORMAT_BYTE_ENCODED: Int = 0xCA
    val FORMAT_BYTE_ENCODED_AS_BYTES: ByteArray = ByteArray(1) { _ -> FORMAT_BYTE_ENCODED.toByte() }
    private const val FORMAT_BYTE_DECODED: Byte = 0xFE.toByte()
    const val RAW_BYTES_TRAILER_LENGTH = INT_BYTE_SIZE * 3 + 1

    fun Bitmap.describe(): String {
        return "{${
            arrayListOf(
                "${width}x${height}",
                "bytes=$byteCount",
                "config=$config",
            ).apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) add("cs=${colorSpace}")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) add("hasGainmap=${hasGainmap()}")
            }.joinToString(",")
        }}"
    }

    fun getExpectedImageSize(pixelCount: Long, config: Bitmap.Config?): Long {
        return pixelCount * BitmapConversion.getBytePerPixel(BitmapConversion.toCustomConfig(config))
    }

    const val BYTE_TRAILER_LENGTH = 1

    suspend fun getBytes(bitmap: Bitmap?, recycle: Boolean, decoded: Boolean, applyGainmap: Boolean, mimeType: String?): ByteArray? {
        return if (decoded) {
            getRawBytes(bitmap, recycle = recycle, applyGainmap = applyGainmap)
        } else {
            val encodedBytes = getEncodedBytes(bitmap, canHaveAlpha = MimeTypes.canHaveAlpha(mimeType), recycle = recycle)
            if ((encodedBytes?.size ?: 0) <= BYTE_TRAILER_LENGTH) {
                // fallback when the bitmap cannot directly be compressed to JPEG/PNG
                getRawBytes(bitmap, recycle = recycle, applyGainmap = applyGainmap)
            } else {
                encodedBytes
            }
        }
    }

    private fun getRawBytes(bitmap: Bitmap?, recycle: Boolean, applyGainmap: Boolean): ByteArray? {
        bitmap ?: return null

        val byteCount = bitmap.byteCount
        val byteBufferSize = byteCount + RAW_BYTES_TRAILER_LENGTH
        if (!MemoryUtils.canAllocate(byteBufferSize)) {
            throw Exception("bitmap buffer is $byteCount bytes, which cannot be allocated to a new byte array")
        }

        val width = bitmap.width
        val height = bitmap.height

        val sourceConfig = BitmapConversion.toCustomConfig(bitmap.config)
        var targetConfig = BitmapConversion.CONFIG_ANDROID_ARGB_8888

        try {
            // `ByteBuffer` initial order is always `BIG_ENDIAN`
            var bytes = ByteBuffer.allocate(byteBufferSize).apply {
                bitmap.copyPixelsToBuffer(this)
            }.array()

            // convert pixel format and color space, if necessary
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                bitmap.colorSpace?.let { srcColorSpace ->
                    val dstColorSpace = ColorSpace.get(ColorSpace.Named.SRGB)
                    val connector = ColorSpace.connect(srcColorSpace, dstColorSpace)

                    when (sourceConfig) {
                        BitmapConversion.CONFIG_ANDROID_ARGB_8888 -> {
                            val gainmapPixelTransformer = if (applyGainmap
                                && Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE
                            ) {
                                GainmapUtils.getGainmapPixelTransformer(bitmap)
                            } else null

                            if (gainmapPixelTransformer != null) {
                                targetConfig = BitmapConversion.CONFIG_DART_RGBA_FLOAT32
                                bytes = BitmapConversion.fromArgb8888ToDartRgbaFloat32(
                                    bytes,
                                    connector,
                                    end = byteCount,
                                    gainmapPixelTransformer = gainmapPixelTransformer
                                )
                            } else if (srcColorSpace != dstColorSpace) {
                                bytes = BitmapConversion.fromArgb8888ToArgb8888(bytes, connector, end = byteCount)
                            }
                        }

                        BitmapConversion.CONFIG_ANDROID_RGBA_F16 -> {
                            bytes = BitmapConversion.fromRgbaf16ToArgb8888(bytes, connector, end = byteCount)
                        }

                        BitmapConversion.CONFIG_ANDROID_RGBA_1010102 -> {
                            bytes = BitmapConversion.fromRgba1010102ToArgb8888(bytes, connector, end = byteCount)
                        }
                    }
                }
            }

            // do not access bitmap after recycling
            if (recycle) bitmap.recycle()

            // append bitmap size for use by the caller to interpret the raw bytes
            val trailerOffset = bytes.size - RAW_BYTES_TRAILER_LENGTH
            bytes = ByteBuffer.wrap(bytes).apply {
                position(trailerOffset)
                putInt(width)
                putInt(height)
                putInt(targetConfig)
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
