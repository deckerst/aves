package deckers.thibault.aves.model.provider

import android.content.Context
import android.net.Uri
import android.provider.MediaStore
import deckers.thibault.aves.model.SourceImageEntry

internal class ContentImageProvider : ImageProvider() {
    override suspend fun fetchSingle(context: Context, uri: Uri, mimeType: String?, callback: ImageOpCallback) {
        if (mimeType == null) {
            callback.onFailure(Exception("MIME type is null for uri=$uri"))
            return
        }

        val map = hashMapOf<String, Any?>(
            "uri" to uri.toString(),
            "sourceMimeType" to mimeType,
        )
        try {
            val cursor = context.contentResolver.query(uri, projection, null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                cursor.getColumnIndex(MediaStore.MediaColumns.SIZE).let { if (it != -1) map["sizeBytes"] = cursor.getLong(it) }
                cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME).let { if (it != -1) map["title"] = cursor.getString(it) }
                cursor.close()
            }
        } catch (e: Exception) {
            callback.onFailure(e)
            return
        }

        val entry = SourceImageEntry(map).fillPreCatalogMetadata(context)
        if (entry.isSized || entry.isSvg) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry has no size"))
        }
    }

    companion object {
        private val projection = arrayOf(
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.DISPLAY_NAME
        )
    }
}