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
    fun getImage(context: Context, uri: Uri, trackId: Int?): Bitmap? {
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return null
        try {
            return if (trackId != null) {
                val imageIndex = trackIdToImageIndex(context, uri, trackId) ?: return null
                retriever.getImageAtIndex(imageIndex)
            } else {
                retriever.primaryImage
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to extract image from uri=$uri trackId=$trackId", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
        return null
    }

    private fun trackIdToImageIndex(context: Context, uri: Uri, trackId: Int): Int? {
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(context, uri, null)
            val trackCount = extractor.trackCount
            var imageIndex = 0
            for (i in 0 until trackCount) {
                val trackFormat = extractor.getTrackFormat(i)
                if (trackId == trackFormat.getInteger(MediaFormat.KEY_TRACK_ID)) {
                    return imageIndex
                }
                if (MimeTypes.isImage(trackFormat.getString(MediaFormat.KEY_MIME))) {
                    imageIndex++
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get image index for uri=$uri, trackId=$trackId", e)
        } finally {
            extractor.release()
        }
        return null
    }
}