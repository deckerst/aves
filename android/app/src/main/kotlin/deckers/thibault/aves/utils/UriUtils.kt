package deckers.thibault.aves.utils

import android.content.ContentResolver
import android.content.ContentUris
import android.net.Uri
import android.util.Log

object UriUtils {
    private val LOG_TAG = LogUtils.createTag<UriUtils>()
    private const val SCHEME_GEO = "geo"

    fun Uri.tryParseId(): Long? {
        try {
            return ContentUris.parseId(this)
        } catch (_: Exception) {
            Log.w(LOG_TAG, "failed to parse ID from contentUri=$this")
        }
        return null
    }

    val Uri.isContentScheme: Boolean
        get() = ContentResolver.SCHEME_CONTENT.equals(scheme, ignoreCase = true)

    val Uri.isFileScheme: Boolean
        get() = ContentResolver.SCHEME_FILE.equals(scheme, ignoreCase = true)

    val Uri.isGeoScheme: Boolean
        get() = SCHEME_GEO.equals(scheme, ignoreCase = true)
}