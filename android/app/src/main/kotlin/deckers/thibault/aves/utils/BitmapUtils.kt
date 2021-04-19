package deckers.thibault.aves.utils

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import deckers.thibault.aves.metadata.Metadata.getExifCode
import java.io.ByteArrayOutputStream

object BitmapUtils {
    private val LOG_TAG = LogUtils.createTag<BitmapUtils>()

    fun Bitmap.getBytes(canHaveAlpha: Boolean = false, quality: Int = 100, recycle: Boolean = true): ByteArray? {
        try {
            val stream = ByteArrayOutputStream()
            // we compress the bitmap because Flutter cannot decode the raw bytes
            // `Bitmap.CompressFormat.PNG` is slower than `JPEG`, but it allows transparency
            if (canHaveAlpha) {
                this.compress(Bitmap.CompressFormat.PNG, quality, stream)
            } else {
                this.compress(Bitmap.CompressFormat.JPEG, quality, stream)
            }
            if (recycle) this.recycle()
            return stream.toByteArray()
        } catch (e: IllegalStateException) {
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
        bitmap ?: return bitmap
        return TransformationUtils.centerCrop(getBitmapPool(context), bitmap, size, size)
    }

    fun getBitmapPool(context: Context) = Glide.get(context).bitmapPool
}