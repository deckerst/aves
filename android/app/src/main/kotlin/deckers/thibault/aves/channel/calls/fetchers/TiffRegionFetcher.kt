package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Rect
import android.net.Uri
import deckers.thibault.aves.utils.BitmapUtils.getDecodedBytes
import io.flutter.plugin.common.MethodChannel
import org.beyka.tiffbitmapfactory.DecodeArea
import org.beyka.tiffbitmapfactory.TiffBitmapFactory

class TiffRegionFetcher internal constructor(
    private val context: Context,
) {
    fun fetch(
        uri: Uri,
        page: Int,
        sampleSize: Int,
        regionRect: Rect,
        result: MethodChannel.Result,
    ) {
        try {
            val pfd = context.contentResolver.openFileDescriptor(uri, "r")
            if (pfd == null) {
                result.error("getRegion-tiff-fd", "failed to get file descriptor for uri=$uri", null)
                return
            }
            pfd.use {
                val fd = pfd.detachFd()
                val options = TiffBitmapFactory.Options().apply {
                    inDirectoryNumber = page
                    inSampleSize = sampleSize
                    inDecodeArea = DecodeArea(regionRect.left, regionRect.top, regionRect.width(), regionRect.height())
                }
                val bitmap = TiffBitmapFactory.decodeFileDescriptor(fd, options)
                val bytes = bitmap?.getDecodedBytes(recycle = true)
                if (bytes != null) {
                    result.success(bytes)
                } else {
                    result.error("getRegion-tiff-null", "failed to decode region for uri=$uri page=$page regionRect=$regionRect", null)
                }
            }
        } catch (e: Exception) {
            result.error("getRegion-tiff-read-exception", "failed to read from uri=$uri page=$page regionRect=$regionRect", e.message)
        }
    }
}
