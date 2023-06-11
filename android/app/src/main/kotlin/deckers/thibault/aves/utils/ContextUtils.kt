package deckers.thibault.aves.utils

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

    fun Context.queryContentPropValue(uri: Uri, mimeType: String, column: String): Any? {
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

        var value: Any? = null
        try {
            val cursor = contentResolver.query(contentUri, arrayOf(column), null, null, null)
            if (cursor == null || !cursor.moveToFirst()) {
                Log.w(LOG_TAG, "failed to get cursor for contentUri=$contentUri column=$column")
            } else {
                value = when (cursor.getType(0)) {
                    Cursor.FIELD_TYPE_NULL -> null
                    Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(0)
                    Cursor.FIELD_TYPE_FLOAT -> cursor.getFloat(0)
                    Cursor.FIELD_TYPE_STRING -> cursor.getString(0)
                    Cursor.FIELD_TYPE_BLOB -> cursor.getBlob(0)
                    else -> null
                }
                cursor.close()
            }
        } catch (e: Exception) {
            // throws SQLiteException/IllegalArgumentException when the requested prop is not a known column
            Log.w(LOG_TAG, "failed to get value for contentUri=$contentUri column=$column", e)
        }
        return value
    }
}
