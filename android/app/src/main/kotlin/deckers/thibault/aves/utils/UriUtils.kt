package deckers.thibault.aves.utils

import android.content.ContentUris
import android.net.Uri
import android.util.Log

object UriUtils {
    private val LOG_TAG = LogUtils.createTag(UriUtils::class.java)

    fun Uri.tryParseId(): Long? {
        try {
            return ContentUris.parseId(this)
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to parse ID from contentUri=$this")
        }
        return null
    }
}