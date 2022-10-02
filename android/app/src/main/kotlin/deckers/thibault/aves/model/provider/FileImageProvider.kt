package deckers.thibault.aves.model.provider

import android.content.Context
import android.content.ContextWrapper
import android.net.Uri
import android.util.Log
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.LogUtils
import java.io.File

internal class FileImageProvider : ImageProvider() {
    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, callback: ImageOpCallback) {
        if (sourceMimeType == null) {
            callback.onFailure(Exception("MIME type is null for uri=$uri"))
            return
        }

        val entry = SourceEntry(uri, sourceMimeType)

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
            }
        }
        entry.fillPreCatalogMetadata(context)

        if (entry.isSized || entry.isSvg || entry.isVideo) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry has no size"))
        }
    }

    override suspend fun delete(contextWrapper: ContextWrapper, uri: Uri, path: String?, mimeType: String) {
        val file = File(File(uri.path!!).path)
        if (!file.exists()) return

        Log.d(LOG_TAG, "delete file at uri=$uri")
        if (file.delete()) return

        throw Exception("failed to delete entry with uri=$uri path=$path")
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaStoreImageProvider>()
    }
}