package deckers.thibault.aves.model.provider

import android.content.ContentUris
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.model.AvesImageEntry
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.utils.LogUtils.createTag
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils.copyFileToTemp
import deckers.thibault.aves.utils.StorageUtils.getDocumentFile
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

abstract class ImageProvider {
    open suspend fun fetchSingle(context: Context, uri: Uri, mimeType: String?, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException())
    }

    open suspend fun delete(context: Context, uri: Uri, path: String?) {
        throw UnsupportedOperationException()
    }

    open suspend fun moveMultiple(context: Context, copy: Boolean, destinationDir: String, entries: List<AvesImageEntry>, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException())
    }

    suspend fun rename(context: Context, oldPath: String, oldMediaUri: Uri, mimeType: String, newFilename: String, callback: ImageOpCallback) {
        val oldFile = File(oldPath)
        val newFile = File(oldFile.parent, newFilename)
        if (oldFile == newFile) {
            Log.w(LOG_TAG, "new name and old name are the same, path=$oldPath")
            callback.onSuccess(HashMap())
            return
        }

        val df = getDocumentFile(context, oldPath, oldMediaUri)
        try {
            @Suppress("BlockingMethodInNonBlockingContext")
            val renamed = df != null && df.renameTo(newFilename)
            if (!renamed) {
                callback.onFailure(Exception("failed to rename entry at path=$oldPath"))
                return
            }
        } catch (e: FileNotFoundException) {
            callback.onFailure(e)
            return
        }

        MediaScannerConnection.scanFile(context, arrayOf(oldPath), arrayOf(mimeType), null)
        try {
            callback.onSuccess(scanNewPath(context, newFile.path, mimeType))
        } catch (e: Exception) {
            callback.onFailure(e)
        }
    }

    fun changeOrientation(context: Context, path: String, uri: Uri, mimeType: String, op: ExifOrientationOp, callback: ImageOpCallback) {
        if (!canEditExif(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return
        }

        val originalDocumentFile = getDocumentFile(context, path, uri)
        if (originalDocumentFile == null) {
            callback.onFailure(Exception("failed to get document file for path=$path, uri=$uri"))
            return
        }

        // copy original file to a temporary file for editing
        val editablePath = copyFileToTemp(originalDocumentFile, path)
        if (editablePath == null) {
            callback.onFailure(Exception("failed to create a temporary file for path=$path"))
            return
        }

        val newFields = HashMap<String, Any?>()
        try {
            val exif = ExifInterface(editablePath)
            // when the orientation is not defined, it returns `undefined (0)` instead of the orientation default value `normal (1)`
            // in that case we explicitly set it to `normal` first
            // because ExifInterface fails to rotate an image with undefined orientation
            // as of androidx.exifinterface:exifinterface:1.3.0
            val currentOrientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
            if (currentOrientation == ExifInterface.ORIENTATION_UNDEFINED) {
                exif.setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL.toString())
            }
            when (op) {
                ExifOrientationOp.ROTATE_CW -> exif.rotate(90)
                ExifOrientationOp.ROTATE_CCW -> exif.rotate(-90)
                ExifOrientationOp.FLIP -> exif.flipHorizontally()
            }
            exif.saveAttributes()

            // copy the edited temporary file back to the original
            DocumentFileCompat.fromFile(File(editablePath)).copyTo(originalDocumentFile)

            newFields["rotationDegrees"] = exif.rotationDegrees
            newFields["isFlipped"] = exif.isFlipped
        } catch (e: IOException) {
            callback.onFailure(e)
            return
        }

        MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, _ ->
            val projection = arrayOf(MediaStore.MediaColumns.DATE_MODIFIED)
            try {
                val cursor = context.contentResolver.query(uri, projection, null, null, null)
                if (cursor != null && cursor.moveToFirst()) {
                    cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields["dateModifiedSecs"] = cursor.getInt(it) }
                    cursor.close()
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return@scanFile
            }
            callback.onSuccess(newFields)
        }
    }

    // support for writing EXIF
    // as of androidx.exifinterface:exifinterface:1.3.0
    private fun canEditExif(mimeType: String): Boolean {
        return when (mimeType) {
            "image/jpeg", "image/png", "image/webp" -> true
            else -> false
        }
    }

    protected suspend fun scanNewPath(context: Context, path: String, mimeType: String): FieldMap =
        suspendCoroutine { cont ->
            MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, newUri: Uri? ->
                var contentId: Long = 0
                var contentUri: Uri? = null
                if (newUri != null) {
                    // `newURI` is possibly a file media URI (e.g. "content://media/12a9-8b42/file/62872")
                    // but we need an image/video media URI (e.g. "content://media/external/images/media/62872")
                    contentId = ContentUris.parseId(newUri)
                    if (isImage(mimeType)) {
                        contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentId)
                    } else if (isVideo(mimeType)) {
                        contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentId)
                    }
                }
                if (contentUri == null) {
                    cont.resumeWithException(Exception("failed to get content URI of item at path=$path"))
                    return@scanFile
                }

                val newFields = HashMap<String, Any?>()
                // we retrieve updated fields as the renamed/moved file became a new entry in the Media Store
                val projection = arrayOf(
                    MediaStore.MediaColumns.DATE_MODIFIED,
                    MediaStore.MediaColumns.DISPLAY_NAME,
                    MediaStore.MediaColumns.TITLE,
                )
                try {
                    val cursor = context.contentResolver.query(contentUri, projection, null, null, null)
                    if (cursor != null && cursor.moveToFirst()) {
                        newFields["uri"] = contentUri.toString()
                        newFields["contentId"] = contentId
                        newFields["path"] = path
                        cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields["dateModifiedSecs"] = cursor.getInt(it) }
                        cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME).let { if (it != -1) newFields["displayName"] = cursor.getString(it) }
                        cursor.getColumnIndex(MediaStore.MediaColumns.TITLE).let { if (it != -1) newFields["title"] = cursor.getString(it) }
                        cursor.close()
                    }
                } catch (e: Exception) {
                    cont.resumeWithException(e)
                    return@scanFile
                }

                if (newFields.isEmpty()) {
                    cont.resumeWithException(Exception("failed to get item details from provider at contentUri=$contentUri (from newUri=$newUri)"))
                } else {
                    cont.resume(newFields)
                }
            }
        }

    interface ImageOpCallback {
        fun onSuccess(fields: FieldMap)
        fun onFailure(throwable: Throwable)
    }

    companion object {
        private val LOG_TAG = createTag(ImageProvider::class.java)
    }
}

typealias FieldMap = MutableMap<String, Any?>
