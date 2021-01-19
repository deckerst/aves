package deckers.thibault.aves.metadata

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils

object MultiTrackMedia {
    private val LOG_TAG = LogUtils.createTag(MultiTrackMedia::class.java)

    @RequiresApi(Build.VERSION_CODES.P)
    fun getImage(context: Context, uri: Uri, trackIndex: Int): Bitmap? {
        val imageIndex = trackIndexToImageIndex(context, uri, trackIndex) ?: return null

        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return null
        try {
            return retriever.getImageAtIndex(imageIndex)
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to extract image from uri=$uri trackIndex=$trackIndex imageIndex=$imageIndex", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
        return null
    }

    private fun trackIndexToImageIndex(context: Context, uri: Uri, trackIndex: Int): Int? {
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(context, uri, null)
            val trackCount = extractor.trackCount
            if (trackIndex < trackCount) {
                var imageIndex = 0
                for (i in 0 until trackIndex) {
                    val mimeType = extractor.getTrackFormat(i).getString(MediaFormat.KEY_MIME)
                    if (MimeTypes.isImage(mimeType)) imageIndex++
                }
                return imageIndex
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get image index for uri=$uri, trackIndex=$trackIndex", e)
        } finally {
            extractor.release()
        }
        return null
    }
}