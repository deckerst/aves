package deckers.thibault.aves.model.provider

import android.content.Context
import android.net.Uri
import deckers.thibault.aves.model.SourceImageEntry
import java.io.File

internal class FileImageProvider : ImageProvider() {
    override suspend fun fetchSingle(context: Context, uri: Uri, mimeType: String?, callback: ImageOpCallback) {
        if (mimeType == null) {
            callback.onFailure(Exception("MIME type is null for uri=$uri"))
            return
        }

        val entry = SourceImageEntry(uri, mimeType)

        val path = uri.path
        if (path != null) {
            try {
                val file = File(path)
                if (file.exists()) {
                    entry.initFromFile(path, file.name, file.length(), file.lastModified() / 1000)
                }
            } catch (e: SecurityException) {
                callback.onFailure(e)
            }
        }
        entry.fillPreCatalogMetadata(context)

        if (entry.isSized || entry.isSvg) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry has no size"))
        }
    }
}