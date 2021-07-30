package deckers.thibault.aves.model.provider

import android.app.Activity
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
import deckers.thibault.aves.metadata.ExifInterfaceHelper
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.*
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils.createDirectoryIfAbsent
import deckers.thibault.aves.utils.StorageUtils.getDocumentFile
import deckers.thibault.aves.utils.UriUtils.tryParseId
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

abstract class ImageProvider {
    open fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException())
    }

    open suspend fun delete(activity: Activity, uri: Uri, path: String?) {
        throw UnsupportedOperationException()
    }

    open suspend fun moveMultiple(activity: Activity, copy: Boolean, destinationDir: String, entries: List<AvesEntry>, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException())
    }

    suspend fun exportMultiple(
        context: Context,
        imageExportMimeType: String,
        destinationDir: String,
        entries: List<AvesEntry>,
        callback: ImageOpCallback,
    ) {
        if (!supportedExportMimeTypes.contains(imageExportMimeType)) {
            throw Exception("unsupported export MIME type=$imageExportMimeType")
        }

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

            val sourceMimeType = entry.mimeType
            val exportMimeType = if (isVideo(sourceMimeType)) sourceMimeType else imageExportMimeType
            try {
                val newFields = exportSingleByTreeDocAndScan(
                    context = context,
                    sourceEntry = entry,
                    destinationDir = destinationDir,
                    destinationDirDocFile = destinationDirDocFile,
                    exportMimeType = exportMimeType,
                )
                result["newFields"] = newFields
                result["success"] = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to export to destinationDir=$destinationDir entry with sourcePath=$sourcePath pageId=$pageId", e)
            }
            callback.onSuccess(result)
        }
    }

    @Suppress("BlockingMethodInNonBlockingContext")
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
            val sourceFileName = File(sourceEntry.path).name
            sourceFileName.replaceFirst("[.][^.]+$".toRegex(), "")
        } else {
            sourceUri.lastPathSegment!!
        }
        if (pageId != null) {
            val page = if (sourceMimeType == MimeTypes.TIFF) pageId + 1 else pageId
            desiredNameWithoutExtension += "_${page.toString().padStart(3, '0')}"
        }
        val desiredFileName = desiredNameWithoutExtension + extensionFor(exportMimeType)

        if (File(destinationDir, desiredFileName).exists()) {
            throw Exception("file with name=$desiredFileName already exists in destination directory")
        }

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        val destinationTreeFile = destinationDirDocFile.createFile(exportMimeType, desiredNameWithoutExtension)
        val destinationDocFile = DocumentFileCompat.fromSingleUri(context, destinationTreeFile.uri)

        if (isVideo(sourceMimeType)) {
            val sourceDocFile = DocumentFileCompat.fromSingleUri(context, sourceUri)
            sourceDocFile.copyTo(destinationDocFile)
        } else {
            val model: Any = if (MimeTypes.isHeic(sourceMimeType) && pageId != null) {
                MultiTrackImage(context, sourceUri, pageId)
            } else if (sourceMimeType == MimeTypes.TIFF) {
                TiffImage(context, sourceUri, pageId)
            } else {
                StorageUtils.getGlideSafeUri(sourceUri, sourceMimeType)
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
                var bitmap = target.get()
                if (MimeTypes.needRotationAfterGlide(sourceMimeType)) {
                    bitmap = BitmapUtils.applyExifOrientation(context, bitmap, sourceEntry.rotationDegrees, sourceEntry.isFlipped)
                }
                bitmap ?: throw Exception("failed to get image from uri=$sourceUri page=$pageId")

                destinationDocFile.openOutputStream().use { output ->
                    if (exportMimeType == MimeTypes.BMP) {
                        BmpWriter.writeRGB24(bitmap, output)
                    } else {
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
                        bitmap.compress(format, quality, output)
                    }
                }
            } finally {
                Glide.with(context).clear(target)
            }
        }

        val fileName = destinationDocFile.name
        val destinationFullPath = destinationDir + fileName

        return scanNewPath(context, destinationFullPath, exportMimeType)
    }

    @Suppress("BlockingMethodInNonBlockingContext")
    suspend fun captureFrame(
        context: Context,
        desiredNameWithoutExtension: String,
        exifFields: FieldMap,
        bytes: ByteArray,
        destinationDir: String,
        callback: ImageOpCallback,
    ) {
        val destinationDirDocFile = createDirectoryIfAbsent(context, destinationDir)
        if (destinationDirDocFile == null) {
            callback.onFailure(Exception("failed to create directory at path=$destinationDir"))
            return
        }

        val captureMimeType = MimeTypes.JPEG
        val desiredFileName = desiredNameWithoutExtension + extensionFor(captureMimeType)
        if (File(destinationDir, desiredFileName).exists()) {
            callback.onFailure(Exception("file with name=$desiredFileName already exists in destination directory"))
            return
        }

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        val destinationTreeFile = destinationDirDocFile.createFile(captureMimeType, desiredNameWithoutExtension)
        val destinationDocFile = DocumentFileCompat.fromSingleUri(context, destinationTreeFile.uri)

        try {
            if (exifFields.isEmpty()) {
                destinationDocFile.openOutputStream().use { output ->
                    output.write(bytes)
                }
            } else {
                val editableFile = File.createTempFile("aves", null).apply {
                    deleteOnExit()
                    outputStream().use { output ->
                        ByteArrayInputStream(bytes).use { imageInput ->
                            imageInput.copyTo(output)
                        }
                    }
                }

                val exif = ExifInterface(editableFile)

                val rotationDegrees = exifFields["rotationDegrees"] as Int?
                if (rotationDegrees != null) {
                    // when the orientation is not defined, it returns `undefined (0)` instead of the orientation default value `normal (1)`
                    // in that case we explicitly set it to `normal` first
                    // because ExifInterface fails to rotate an image with undefined orientation
                    // as of androidx.exifinterface:exifinterface:1.3.0
                    val currentOrientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                    if (currentOrientation == ExifInterface.ORIENTATION_UNDEFINED) {
                        exif.setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL.toString())
                    }
                    exif.rotate(rotationDegrees)
                }

                val dateTimeMillis = (exifFields["dateTimeMillis"] as Number?)?.toLong()
                if (dateTimeMillis != null) {
                    val dateString = ExifInterfaceHelper.DATETIME_FORMAT.format(Date(dateTimeMillis))
                    exif.setAttribute(ExifInterface.TAG_DATETIME, dateString)
                    exif.setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, dateString)

                    val offsetInMinutes = TimeZone.getDefault().getOffset(dateTimeMillis) / 60000
                    val offsetSign = if (offsetInMinutes < 0) "-" else "+"
                    val offsetHours = "${offsetInMinutes / 60}".padStart(2, '0')
                    val offsetMinutes = "${offsetInMinutes % 60}".padStart(2, '0')
                    val timeZoneString = "$offsetSign$offsetHours:$offsetMinutes"
                    exif.setAttribute(ExifInterface.TAG_OFFSET_TIME, timeZoneString)
                    exif.setAttribute(ExifInterface.TAG_OFFSET_TIME_ORIGINAL, timeZoneString)

                    val sub = dateTimeMillis % 1000
                    if (sub > 0) {
                        val subString = sub.toString()
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME, subString)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME_ORIGINAL, subString)
                    }
                }

                val latitude = (exifFields["latitude"] as Number?)?.toDouble()
                val longitude = (exifFields["longitude"] as Number?)?.toDouble()
                if (latitude != null && longitude != null) {
                    exif.setLatLong(latitude, longitude)
                }

                exif.saveAttributes()

                // copy the edited temporary file back to the original
                DocumentFileCompat.fromFile(editableFile).copyTo(destinationDocFile)
            }

            val fileName = destinationDocFile.name
            val destinationFullPath = destinationDir + fileName
            val newFields = scanNewPath(context, destinationFullPath, captureMimeType)
            callback.onSuccess(newFields)
        } catch (e: Exception) {
            callback.onFailure(e)
        }
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

    fun changeOrientation(context: Context, path: String, uri: Uri, mimeType: String, sizeBytes: Long, op: ExifOrientationOp, callback: ImageOpCallback) {
        if (!canEditExif(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return
        }

        val originalDocumentFile = getDocumentFile(context, path, uri)
        if (originalDocumentFile == null) {
            callback.onFailure(Exception("failed to get document file for path=$path, uri=$uri"))
            return
        }

        val videoSizeBytes = MultiPage.getMotionPhotoOffset(context, uri, mimeType, sizeBytes)?.toInt()
        var videoBytes: ByteArray? = null
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                outputStream().use { output ->
                    if (videoSizeBytes != null) {
                        // handle motion photo and embedded video separately
                        val imageSizeBytes = (sizeBytes - videoSizeBytes).toInt()
                        videoBytes = ByteArray(videoSizeBytes)

                        StorageUtils.openInputStream(context, uri)?.let { input ->
                            val imageBytes = ByteArray(imageSizeBytes)
                            input.read(imageBytes, 0, imageSizeBytes)
                            input.read(videoBytes, 0, videoSizeBytes)

                            // copy only the image to a temporary file for editing
                            // video will be appended after EXIF modification
                            ByteArrayInputStream(imageBytes).use { imageInput ->
                                imageInput.copyTo(output)
                            }
                        }
                    } else {
                        // copy original file to a temporary file for editing
                        originalDocumentFile.openInputStream().use { imageInput ->
                            imageInput.copyTo(output)
                        }
                    }
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return
            }
        }

        val newFields = HashMap<String, Any?>()
        try {
            val exif = ExifInterface(editableFile)
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

            if (videoBytes != null) {
                // append motion photo video, if any
                editableFile.appendBytes(videoBytes!!)
            }
            // copy the edited temporary file back to the original
            DocumentFileCompat.fromFile(editableFile).copyTo(originalDocumentFile)

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
            MimeTypes.JPEG, MimeTypes.PNG, MimeTypes.WEBP -> true
            else -> false
        }
    }

    protected suspend fun scanNewPath(context: Context, path: String, mimeType: String): FieldMap =
        suspendCoroutine { cont ->
            MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, newUri: Uri? ->
                fun scanUri(uri: Uri?): FieldMap? {
                    uri ?: return null

                    // we retrieve updated fields as the renamed/moved file became a new entry in the Media Store
                    val projection = arrayOf(
                        MediaStore.MediaColumns.DATE_MODIFIED,
                        MediaStore.MediaColumns.DISPLAY_NAME,
                        MediaStore.MediaColumns.TITLE,
                    )
                    try {
                        val cursor = context.contentResolver.query(uri, projection, null, null, null)
                        if (cursor != null && cursor.moveToFirst()) {
                            val newFields = HashMap<String, Any?>()
                            newFields["uri"] = uri.toString()
                            newFields["contentId"] = uri.tryParseId()
                            newFields["path"] = path
                            cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields["dateModifiedSecs"] = cursor.getInt(it) }
                            cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME).let { if (it != -1) newFields["displayName"] = cursor.getString(it) }
                            cursor.getColumnIndex(MediaStore.MediaColumns.TITLE).let { if (it != -1) newFields["title"] = cursor.getString(it) }
                            cursor.close()
                            return newFields
                        }
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to scan uri=$uri", e)
                    }
                    return null
                }

                if (newUri == null) {
                    cont.resumeWithException(Exception("failed to get URI of item at path=$path"))
                    return@scanFile
                }

                var contentUri: Uri? = null
                // `newURI` is possibly a file media URI (e.g. "content://media/12a9-8b42/file/62872")
                // but we need an image/video media URI (e.g. "content://media/external/images/media/62872")
                val contentId = newUri.tryParseId()
                if (contentId != null) {
                    if (isImage(mimeType)) {
                        contentUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentId)
                    } else if (isVideo(mimeType)) {
                        contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentId)
                    }
                }

                // prefer image/video content URI, fallback to original URI (possibly a file content URI)
                val newFields = scanUri(contentUri) ?: scanUri(newUri)

                if (newFields != null) {
                    cont.resume(newFields)
                } else {
                    cont.resumeWithException(Exception("failed to get item details from provider at contentUri=$contentUri (from newUri=$newUri)"))
                }
            }
        }

    interface ImageOpCallback {
        fun onSuccess(fields: FieldMap)
        fun onFailure(throwable: Throwable)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ImageProvider>()

        val supportedExportMimeTypes = listOf(MimeTypes.BMP, MimeTypes.JPEG, MimeTypes.PNG, MimeTypes.WEBP)
    }
}
