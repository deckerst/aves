package deckers.thibault.aves.utils

import android.app.ActivityManager
import android.app.Service
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import deckers.thibault.aves.utils.UriUtils.tryParseId

object ContextUtils {
    private val LOG_TAG = LogUtils.createTag<ContextUtils>()

    fun Context.resourceUri(resourceId: Int): Uri = with(resources) {
        Uri.Builder()
            .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
            .authority(getResourcePackageName(resourceId))
            .appendPath(getResourceTypeName(resourceId))
            .appendPath(getResourceEntryName(resourceId))
            .build()
    }

    fun Context.isMyServiceRunning(serviceClass: Class<out Service>): Boolean {
        val am = this.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
        am ?: return false
        @Suppress("deprecation")
        return am.getRunningServices(Integer.MAX_VALUE).any { it.service.className == serviceClass.name }
    }

    fun Context.queryContentResolverProp(uri: Uri, mimeType: String, prop: String): Any? {
        var contentUri: Uri = uri
        if (StorageUtils.isMediaStoreContentUri(uri)) {
            uri.tryParseId()?.let { id ->
                contentUri = when {
                    MimeTypes.isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    MimeTypes.isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    else -> uri
                }
                contentUri = StorageUtils.getOriginalUri(this, contentUri)
            }
        }

        // throws SQLiteException when the requested prop is not a known column
        val cursor = contentResolver.query(contentUri, arrayOf(prop), null, null, null)
        if (cursor == null || !cursor.moveToFirst()) {
            throw Exception("failed to get cursor for contentUri=$contentUri")
        }

        var value: Any? = null
        try {
            value = when (cursor.getType(0)) {
                Cursor.FIELD_TYPE_NULL -> null
                Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(0)
                Cursor.FIELD_TYPE_FLOAT -> cursor.getFloat(0)
                Cursor.FIELD_TYPE_STRING -> cursor.getString(0)
                Cursor.FIELD_TYPE_BLOB -> cursor.getBlob(0)
                else -> null
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get value for contentUri=$contentUri key=$prop", e)
        }
        cursor.close()
        return value
    }
}
