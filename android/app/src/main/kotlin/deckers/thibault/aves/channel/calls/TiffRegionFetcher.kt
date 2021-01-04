package deckers.thibault.aves.channel.calls

import android.content.Context
import android.graphics.Rect
import android.net.Uri
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import io.flutter.plugin.common.MethodChannel
import org.beyka.tiffbitmapfactory.DecodeArea
import org.beyka.tiffbitmapfactory.TiffBitmapFactory

class TiffRegionFetcher internal constructor(
    private val context: Context,
) {
    fun fetch(
        uri: Uri,
        sampleSize: Int,
        regionRect: Rect,
        page: Int = 0,
        result: MethodChannel.Result,
    ) {
        try {
            val fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
            if (fd == null) {
                result.error("getRegion-tiff-fd", "failed to get file descriptor for uri=$uri", null)
                return
            }
            val options = TiffBitmapFactory.Options().apply {
                inDirectoryNumber = page
                inSampleSize = sampleSize
                inDecodeArea = DecodeArea(regionRect.left, regionRect.top, regionRect.width(), regionRect.height())
            }
            val bitmap = TiffBitmapFactory.decodeFileDescriptor(fd, options)
            if (bitmap != null) {
                result.success(bitmap.getBytes(canHaveAlpha = true, recycle = true))
            } else {
                result.error("getRegion-tiff-null", "failed to decode region for uri=$uri page=$page regionRect=$regionRect", null)
            }
        } catch (e: Exception) {
            result.error("getRegion-tiff-read-exception", "failed to read from uri=$uri page=$page regionRect=$regionRect", e.message)
        }
    }
}
