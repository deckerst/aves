package deckers.thibault.aves.channel.calls

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapRegionDecoder
import android.graphics.Rect
import android.net.Uri
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class RegionFetcher internal constructor(
    private val activity: Activity,
    private val uri: Uri,
    private val mimeType: String,
    private val sampleSize: Int,
    private val rect: Rect,
    private val result: MethodChannel.Result,
) {

    fun fetch() {
        val options = BitmapFactory.Options().apply { inSampleSize = sampleSize }

        try {
            StorageUtils.openInputStream(activity, uri).use { input ->
                val decoder = BitmapRegionDecoder.newInstance(input, false)
                val data = decoder.decodeRegion(rect, options)?.let {
                    val stream = ByteArrayOutputStream()
                    // we compress the bitmap because Dart Image.memory cannot decode the raw bytes
                    // Bitmap.CompressFormat.PNG is slower than JPEG, but it allows transparency
                    if (MimeTypes.canHaveAlpha(mimeType)) {
                        it.compress(Bitmap.CompressFormat.PNG, 0, stream)
                    } else {
                        it.compress(Bitmap.CompressFormat.JPEG, 100, stream)
                    }
                    stream.toByteArray()
                }
                if (data != null) {
                    result.success(data)
                } else {
                    result.error("getRegion-null", "failed to decode region for uri=$uri rect=$rect", null)
                }
            }
        } catch (e: Exception) {
            result.error("getRegion-read-exception", "failed to get image from uri=$uri", e.message)
        }
    }
}