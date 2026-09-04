package deckers.thibault.aves.model.provider

import android.content.Context
import android.net.Uri
import android.util.Log
import android.webkit.MimeTypeMap
import deckers.thibault.aves.model.EntryFields
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.FileUtils
import deckers.thibault.aves.utils.FileUtils.getFileSize
import deckers.thibault.aves.utils.LogUtils
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

internal class FileImageProvider : ImageProvider() {
    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, allowUnsized: Boolean, callback: ImageOpCallback) {
        var mimeType = sourceMimeType
        val path = uri.path

        if (mimeType == null) {
            // try to guess by file extension
            var extension = MimeTypeMap.getFileExtensionFromUrl(uri.toString())
            if (extension.isEmpty() && path != null) {
                val lastDotIndex = path.lastIndexOf('.')
                if (lastDotIndex >= 0) {
                    extension = path.substring(lastDotIndex + 1)
                }
            }
            if (extension.isNotEmpty()) {
                mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            }
        }

        if (mimeType == null) {
            // try to guess by file preview read
            var sizeBytes: Long? = null
            try {
                path?.let { sizeBytes = getFileSize(it) }
            } catch (e: SecurityException) {
                callback.onFailure(e)
                return
            }
            mimeType = detectMimeType(context, uri, mimeType = null, sizeBytes)
        }

        if (mimeType == null) {
            callback.onFailure(Exception("MIME type was not provided and cannot be guessed from extension or preview of uri=$uri"))
            return
        }

        val entry = SourceEntry(SourceEntry.ORIGIN_FILE, uri, mimeType)

        if (path != null) {
            try {
                val file = File(path)
                if (file.exists()) {
                    entry.initFromFile(
                        path = path,
                        title = file.name,
                        sizeBytes = getFileSize(path),
                        dateModifiedMillis = file.lastModified(),
                    )
                }
            } catch (e: SecurityException) {
                callback.onFailure(e)
                return
            }
        }
        entry.fillPreCatalogMetadata(context)

        if (allowUnsized || entry.isSized || entry.isSvg || entry.isVideo) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry has no size"))
        }
    }

    override suspend fun renameSingle(
        context: Context,
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
            EntryFields.URI to Uri.fromFile(newFile).toString(),
            EntryFields.PATH to newFile.path,
            EntryFields.DATE_MODIFIED_MILLIS to newFile.lastModified(),
        )
    }

    override fun scanPostMetadataEdit(context: Context, path: String, uri: Uri, mimeType: String, newFields: FieldMap, callback: ImageOpCallback) {
        try {
            val file = File(path)
            if (file.exists()) {
                newFields[EntryFields.DATE_MODIFIED_MILLIS] = file.lastModified()
                newFields[EntryFields.SIZE_BYTES] = getFileSize(path)
            }
            callback.onSuccess(newFields)
        } catch (e: SecurityException) {
            callback.onFailure(e)
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaStoreImageProvider>()

        fun insert(
            targetDirPath: String,
            targetFileName: String,
            write: (OutputStream) -> Unit,
        ): String {
            val targetDir = File(targetDirPath)
            targetDir.mkdirs()
            if (!targetDir.exists()) {
                throw Exception("failed to create directory at path=$targetDirPath")
            }

            val file = File(targetDir, targetFileName)
            FileOutputStream(file).use(write)
            return file.path
        }

        fun move(
            sourceFile: File,
            targetFile: File,
            copy: Boolean,
        ): String {
            Log.d(LOG_TAG, "move file from path=$sourceFile to path=$targetFile")

            if (targetFile.exists()) {
                throw Exception("failed to move file because target file exists at path=$targetFile")
            }

            val targetDir = targetFile.parentFile
            targetDir?.mkdirs()
            if (targetDir == null || !targetDir.exists()) {
                throw Exception("failed to create parent directory of file at path=$targetFile")
            }

            if (copy) {
                FileUtils.copy(sourceFile, targetFile)
            } else {
                FileUtils.move(sourceFile, targetFile)
            }
            return targetFile.path
        }
    }
}