package deckers.thibault.aves.utils

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import deckers.thibault.aves.metadata.Metadata.getExifCode
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.ByteArrayOutputStream

object BitmapUtils {
    private val LOG_TAG = LogUtils.createTag<BitmapUtils>()
    private const val INITIAL_BUFFER_SIZE = 2 shl 17 // 256kB

    // arbitrary size to detect buffer that may yield an OOM
    private const val BUFFER_SIZE_DANGER_THRESHOLD = 10 * (1 shl 20) // MB

    private val freeBaos = ArrayList<ByteArrayOutputStream>()
    private val mutex = Mutex()

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
            if (bufferSize > BUFFER_SIZE_DANGER_THRESHOLD) {
                val availHeapSize = Runtime.getRuntime().let { it.maxMemory() - (it.totalMemory() - it.freeMemory()) }
                if (bufferSize > availHeapSize) {
                    throw Exception("compressed bitmap to $bufferSize bytes, which cannot be allocated to a new byte array, with only $availHeapSize free bytes")
                }
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
