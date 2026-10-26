package deckers.thibault.aves.model.provider

import android.content.Context
import android.net.Uri
import android.provider.MediaStore
import android.provider.OpenableColumns
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper
import deckers.thibault.aves.model.EntryFields
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.SourceEntry

open class UnknownContentProvider : ImageProvider() {
    open val reliableProviderMimeType: Boolean
        get() = false

    override fun fetchSingle(
        context: Context,
        sourceMimeType: String?,
        uri: Uri,
        allowUnsized: Boolean,
        callback: ImageOpCallback,
    ) {
        var mimeType = sourceMimeType
        if (sourceMimeType == null || !reliableProviderMimeType) {
            // source MIME type may be incorrect, so we get a second opinion if possible
            mimeType = MetadataExtractorHelper.readMimeType(
                context = context,
                mimeType = sourceMimeType,
                uri = uri,
                path = null,
                sizeBytes = null,
            )
        }

        val fields: FieldMap = hashMapOf(
            EntryFields.ORIGIN to SourceEntry.ORIGIN_UNKNOWN_CONTENT,
            EntryFields.URI to uri.toString(),
            EntryFields.SOURCE_MIME_TYPE to mimeType,
        )
        try {
            // some providers do not provide the mandatory `OpenableColumns`
            // and the query fails when compiling a projection specifying them
            // e.g. `content://mms/part/[id]` on Android KitKat
            val cursor = context.contentResolver.query(uri, null, null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME).let { if (it != -1) fields[EntryFields.TITLE] = cursor.getString(it) }
                cursor.getColumnIndex(OpenableColumns.SIZE).let { if (it != -1) fields[EntryFields.SIZE_BYTES] = cursor.getLong(it) }
                cursor.getColumnIndex(MediaStore.MediaColumns.DATA).let { if (it != -1) fields[EntryFields.PATH] = cursor.getString(it) }
                // mime type fallback if it was not provided and not found via `metadata-extractor`
                if (mimeType == null) {
                    cursor.getColumnIndex(MediaStore.MediaColumns.MIME_TYPE).let { if (it != -1) fields[EntryFields.SOURCE_MIME_TYPE] = cursor.getString(it) }
                }
                cursor.close()
            }
        } catch (e: Exception) {
            callback.onFailure(Exception("failed to query content", e))
            return
        }

        if (fields[EntryFields.SOURCE_MIME_TYPE] == null) {
            callback.onFailure(Exception("failed to find MIME type for uri=$uri"))
            return
        }

        val entry = SourceEntry(fields).fillPreCatalogMetadata(context)
        if (allowUnsized || entry.isSized || entry.isSvg || entry.isVideo) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry is not sized, for fields=$fields"))
        }
    }
}