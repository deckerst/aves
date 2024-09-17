package deckers.thibault.aves.model.provider

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.net.Uri
import android.util.Log
import android.webkit.MimeTypeMap
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.LogUtils
import java.io.File

internal class FileImageProvider : ImageProvider() {
    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, allowUnsized: Boolean, callback: ImageOpCallback) {
        var mimeType = sourceMimeType

        if (mimeType == null) {
            var extension = MimeTypeMap.getFileExtensionFromUrl(uri.toString())
            if (extension.isEmpty()) {
                uri.path?.let { path ->
                    val lastDotIndex = path.lastIndexOf('.')
                    if (lastDotIndex >= 0) {
                        extension = path.substring(lastDotIndex + 1)
                    }
                }
            }
            if (extension.isNotEmpty()) {
                mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            }
        }
        if (mimeType == null) {
            callback.onFailure(Exception("MIME type was not provided and cannot be guessed from extension of uri=$uri"))
            return
        }

        val entry = SourceEntry(SourceEntry.ORIGIN_FILE, uri, mimeType)

        val path = uri.path
        if (path != null) {
            try {
                val file = File(path)
                if (file.exists()) {
                    entry.initFromFile(
                        path = path,
                        title = file.name,
                        sizeBytes = file.length(),
                        dateModifiedSecs = file.lastModified() / 1000,
                    )
                }
            } catch (e: SecurityException) {
                callback.onFailure(e)
                return
            }
        }
        entry.fillPreCatalogMetadata(context, safe = false)

        if (allowUnsized || entry.isSized || entry.isSvg || entry.isVideo) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry has no size"))
        }
    }

    override suspend fun delete(contextWrapper: ContextWrapper, uri: Uri, path: String?, mimeType: String) {
        path ?: throw Exception("failed to delete file because path is null")

        val file = File(path)
        if (file.exists()) {
            Log.d(LOG_TAG, "delete file at path=$path")
            if (!file.delete()) {
                throw Exception("failed to delete entry with uri=$uri path=$path")
            }
        }
    }

    override suspend fun renameSingle(
        activity: Activity,
        mimeType: String,
        oldMediaUri: Uri,
        oldPath: String,
        newFile: File,
    ): FieldMap {
        Log.d(LOG_TAG, "rename file at path=$oldPath")
        val renamed = File(oldPath).renameTo(newFile)
        if (!renamed) {
            throw Exception("failed to rename file at path=$oldPath")
        }

        return hashMapOf(
            "uri" to Uri.fromFile(newFile).toString(),
            "path" to newFile.path,
            "dateModifiedSecs" to newFile.lastModified() / 1000,
        )
    }

    override fun scanPostMetadataEdit(context: Context, path: String, uri: Uri, mimeType: String, newFields: FieldMap, callback: ImageOpCallback) {
        try {
            val file = File(path)
            if (file.exists()) {
                newFields["dateModifiedSecs"] = file.lastModified() / 1000
                newFields["sizeBytes"] = file.length()
            }
            callback.onSuccess(newFields)
        } catch (e: SecurityException) {
            callback.onFailure(e)
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaStoreImageProvider>()
    }
}