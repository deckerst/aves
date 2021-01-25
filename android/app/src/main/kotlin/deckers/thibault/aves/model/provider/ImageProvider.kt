package deckers.thibault.aves.model.provider

import android.content.ContentUris
import android.content.Context
import android.graphics.Bitmap
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.decoder.MultiTrackImage
import deckers.thibault.aves.decoder.TiffImage
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils.copyFileToTemp
import deckers.thibault.aves.utils.StorageUtils.createDirectoryIfAbsent
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

    open suspend fun moveMultiple(context: Context, copy: Boolean, destinationDir: String, entries: List<AvesEntry>, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException())
    }

    suspend fun exportMultiple(
        context: Context,
        mimeType: String,
        destinationDir: String,
        entries: List<AvesEntry>,
        callback: ImageOpCallback,
    ) {
        val destinationDirDocFile = createDirectoryIfAbsent(context, destinationDir)
        if (destinationDirDocFile == null) {
            callback.onFailure(Exception("failed to create directory at path=$destinationDir"))
            return
        }

        for (entry in entries) {
            val sourceUri = entry.uri
            val sourcePath = entry.path
            val pageId = entry.pageId

            val result = hashMapOf<String, Any?>(
                "uri" to sourceUri.toString(),
                "pageId" to pageId,
                "success" to false,
            )

            try {
                val newFields = exportSingleByTreeDocAndScan(
                    context = context,
                    sourceEntry = entry,
                    destinationDir = destinationDir,
                    destinationDirDocFile = destinationDirDocFile,
                    exportMimeType = mimeType,
                )
                result["newFields"] = newFields
                result["success"] = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to export to destinationDir=$destinationDir entry with sourcePath=$sourcePath pageId=$pageId", e)
            }
            callback.onSuccess(result)
        }
    }

    private suspend fun exportSingleByTreeDocAndScan(
        context: Context,
        sourceEntry: AvesEntry,
        destinationDir: String,
        destinationDirDocFile: DocumentFileCompat,
        exportMimeType: String,
    ): FieldMap {
        val sourceMimeType = sourceEntry.mimeType
        val sourceUri = sourceEntry.uri
        val pageId = sourceEntry.pageId

        var desiredNameWithoutExtension = if (sourceEntry.path != null) {
            val sourcePath = sourceEntry.path
            val sourceFile = File(sourcePath)
            val sourceFileName = sourceFile.name
            sourceFileName.replaceFirst("[.][^.]+$".toRegex(), "")
        } else {
            sourceUri.lastPathSegment!!
        }
        if (pageId != null) {
            val page = if (sourceMimeType == MimeTypes.TIFF) pageId + 1 else pageId
            desiredNameWithoutExtension += "_${page.toString().padStart(3, '0')}"
        }
        val desiredFileName = desiredNameWithoutExtension + when (exportMimeType) {
            MimeTypes.JPEG -> ".jpg"
            MimeTypes.PNG -> ".png"
            MimeTypes.WEBP -> ".webp"
            else -> throw Exception("unsupported export MIME type=$exportMimeType")
        }

        if (File(destinationDir, desiredFileName).exists()) {
            throw Exception("file with name=$desiredFileName already exists in destination directory")
        }

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        @Suppress("BlockingMethodInNonBlockingContext")
        val destinationTreeFile = destinationDirDocFile.createFile(exportMimeType, desiredNameWithoutExtension)
        val destinationDocFile = DocumentFileCompat.fromSingleUri(context, destinationTreeFile.uri)

        val model: Any = if (MimeTypes.isHeifLike(sourceMimeType) && pageId != null) {
            MultiTrackImage(context, sourceUri, pageId)
        } else if (sourceMimeType == MimeTypes.TIFF) {
            TiffImage(context, sourceUri, pageId)
        } else {
            sourceUri
        }

        // request a fresh image with the highest quality format
        val glideOptions = RequestOptions()
            .format(DecodeFormat.PREFER_ARGB_8888)
            .diskCacheStrategy(DiskCacheStrategy.NONE)
            .skipMemoryCache(true)

        val target = Glide.with(context)
            .asBitmap()
            .apply(glideOptions)
            .load(model)
            .submit()
        try {
            @Suppress("BlockingMethodInNonBlockingContext")
            var bitmap = target.get()
            if (MimeTypes.needRotationAfterGlide(sourceMimeType)) {
                bitmap = BitmapUtils.applyExifOrientation(context, bitmap, sourceEntry.rotationDegrees, sourceEntry.isFlipped)
            }
            bitmap ?: throw Exception("failed to get image from uri=$sourceUri page=$pageId")

            val quality = 100
            val format = when (exportMimeType) {
                MimeTypes.JPEG -> Bitmap.CompressFormat.JPEG
                MimeTypes.PNG -> Bitmap.CompressFormat.PNG
                MimeTypes.WEBP -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    if (quality == 100) {
                        Bitmap.CompressFormat.WEBP_LOSSLESS
                    } else {
                        Bitmap.CompressFormat.WEBP_LOSSY
                    }
                } else {
                    @Suppress("DEPRECATION")
                    Bitmap.CompressFormat.WEBP
                }
                else -> throw Exception("unsupported export MIME type=$exportMimeType")
            }

            @Suppress("BlockingMethodInNonBlockingContext")
            destinationDocFile.openOutputStream().use {
                bitmap.compress(format, quality, it)
            }
        } finally {
            Glide.with(context).clear(target)
        }

        val fileName = destinationDocFile.name
        val destinationFullPath = destinationDir + fileName

        return scanNewPath(context, destinationFullPath, exportMimeType)
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
                    if (MimeTypes.isImage(mimeType)) {
                        contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentId)
                    } else if (MimeTypes.isVideo(mimeType)) {
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
        private val LOG_TAG = LogUtils.createTag(ImageProvider::class.java)
    }
}

typealias FieldMap = MutableMap<String, Any?>
