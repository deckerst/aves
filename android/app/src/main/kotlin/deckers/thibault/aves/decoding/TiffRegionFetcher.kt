package deckers.thibault.aves.decoding

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Rect
import android.net.Uri
import deckers.thibault.aves.channel.streams.darttoplatform.ByteSink
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.MimeTypes
import org.beyka.tiffbitmapfactory.DecodeArea
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.ByteArrayInputStream

class TiffRegionFetcher internal constructor(
    private val context: Context,
) {
    suspend fun fetch(
        uri: Uri,
        page: Int,
        decoded: Boolean,
        sampleSize: Int,
        regionRect: Rect,
        result: ByteSink,
    ) {
        try {
            val pfd = context.contentResolver.openFileDescriptor(uri, "r")
            if (pfd == null) {
                result.error("fetch-fd", "failed to get file descriptor for uri=$uri", null)
                return
            }
            pfd.use {
                val fd = pfd.detachFd()
                val options = TiffBitmapFactory.Options().apply {
                    inDirectoryNumber = page
                    inSampleSize = sampleSize
                    inDecodeArea = DecodeArea(regionRect.left, regionRect.top, regionRect.width(), regionRect.height())
                }
                val bitmap: Bitmap? = TiffBitmapFactory.decodeFileDescriptor(fd, options)
                val bytes = BitmapUtils.getBytes(bitmap, recycle = true, decoded = decoded, MimeTypes.TIFF)
                if (bytes == null) {
                    result.error("fetch-null", "failed to decode region for uri=$uri page=$page regionRect=$regionRect", null)
                } else {
                    result.streamBytes(ByteArrayInputStream(bytes))
                }
            }
        } catch (e: Exception) {
            result.error("fetch-exception", "failed to read from uri=$uri page=$page regionRect=$regionRect", e.message)
        }
    }
}
