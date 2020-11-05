package deckers.thibault.aves.channel.calls

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapRegionDecoder
import android.graphics.Rect
import android.net.Uri
import android.util.Log
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class RegionFetcher internal constructor(
    private val context: Context,
) {
    private var lastDecoderRef: Pair<Uri, BitmapRegionDecoder>? = null

    fun fetch(
        uri: Uri,
        mimeType: String,
        sampleSize: Int,
        rect: Rect,
        result: MethodChannel.Result,
    ) {
        val options = BitmapFactory.Options().apply {
            inSampleSize = sampleSize
        }

        var currentDecoderRef = lastDecoderRef
        if (currentDecoderRef != null && currentDecoderRef.first != uri) {
            currentDecoderRef.second.recycle()
            currentDecoderRef = null
        }

        try {
            if (currentDecoderRef == null) {
                val newDecoder = StorageUtils.openInputStream(context, uri).use { input ->
                    BitmapRegionDecoder.newInstance(input, false)
                }
                currentDecoderRef = Pair(uri, newDecoder)
            }
            val decoder = currentDecoderRef.second
            lastDecoderRef = currentDecoderRef

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
        } catch (e: Exception) {
            result.error("getRegion-read-exception", "failed to initialize region decoder for uri=$uri", e.message)
        }
    }
}