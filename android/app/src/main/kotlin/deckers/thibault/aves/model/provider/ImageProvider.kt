package deckers.thibault.aves.model.provider

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.decoder.MultiTrackImage
import deckers.thibault.aves.decoder.TiffImage
import deckers.thibault.aves.metadata.*
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.PixyMetaHelper.extendedXmpDocString
import deckers.thibault.aves.metadata.PixyMetaHelper.xmpDocString
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.*
import deckers.thibault.aves.utils.MimeTypes.canEditExif
import deckers.thibault.aves.utils.MimeTypes.canEditXmp
import deckers.thibault.aves.utils.MimeTypes.canRemoveMetadata
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils.createDirectoryIfAbsent
import deckers.thibault.aves.utils.StorageUtils.getDocumentFile
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.util.*

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

    open fun scanPostMetadataEdit(context: Context, path: String, uri: Uri, mimeType: String, newFields: HashMap<String, Any?>, callback: ImageOpCallback) {
        throw UnsupportedOperationException()
    }

    open fun scanObsoletePath(context: Context, path: String, mimeType: String) {
        throw UnsupportedOperationException()
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
                bitmap ?: throw Exception("failed to get image for mimeType=$sourceMimeType uri=$sourceUri page=$pageId")

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

        return MediaStoreImageProvider().scanNewPath(context, destinationFullPath, exportMimeType)
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
            val newFields = MediaStoreImageProvider().scanNewPath(context, destinationFullPath, captureMimeType)
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

        scanObsoletePath(context, oldPath, mimeType)
        try {
            callback.onSuccess(MediaStoreImageProvider().scanNewPath(context, newFile.path, mimeType))
        } catch (e: Exception) {
            callback.onFailure(e)
        }
    }

    private fun editExif(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
        trailerDiff: Int = 0,
        edit: (exif: ExifInterface) -> Unit,
    ): Boolean {
        if (!canEditExif(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        val originalDocumentFile = getDocumentFile(context, path, uri)
        if (originalDocumentFile == null) {
            callback.onFailure(Exception("failed to get document file for path=$path, uri=$uri"))
            return false
        }

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.let { it.toInt() + trailerDiff }
        var videoBytes: ByteArray? = null
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                outputStream().use { output ->
                    if (videoSize != null) {
                        // handle motion photo and embedded video separately
                        val imageSize = (originalFileSize - videoSize).toInt()
                        videoBytes = ByteArray(videoSize)

                        StorageUtils.openInputStream(context, uri)?.let { input ->
                            val imageBytes = ByteArray(imageSize)
                            input.read(imageBytes, 0, imageSize)
                            input.read(videoBytes, 0, videoSize)

                            // copy only the image to a temporary file for editing
                            // video will be appended after metadata modification
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
                return false
            }
        }

        try {
            edit(ExifInterface(editableFile))

            if (videoBytes != null) {
                // append trailer video, if any
                editableFile.appendBytes(videoBytes!!)
            }

            // copy the edited temporary file back to the original
            DocumentFileCompat.fromFile(editableFile).copyTo(originalDocumentFile)

            if (!checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return false
            }
        } catch (e: IOException) {
            callback.onFailure(e)
            return false
        }

        return true
    }

    private fun editXmp(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
        trailerDiff: Int = 0,
        edit: (xmp: String) -> String,
    ): Boolean {
        if (!canEditXmp(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        val originalDocumentFile = getDocumentFile(context, path, uri)
        if (originalDocumentFile == null) {
            callback.onFailure(Exception("failed to get document file for path=$path, uri=$uri"))
            return false
        }

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.let { it.toInt() + trailerDiff }
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                val xmp = originalDocumentFile.openInputStream().use { input -> PixyMetaHelper.getXmp(input) }
                if (xmp == null) {
                    callback.onFailure(Exception("failed to find XMP for path=$path, uri=$uri"))
                    return false
                }

                outputStream().use { output ->
                    // reopen input to read from start
                    originalDocumentFile.openInputStream().use { input ->
                        val editedXmpString = edit(xmp.xmpDocString())
                        val extendedXmpString = if (xmp.hasExtendedXmp()) xmp.extendedXmpDocString() else null
                        PixyMetaHelper.setXmp(input, output, editedXmpString, extendedXmpString)
                    }
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return false
            }
        }

        try {
            // copy the edited temporary file back to the original
            DocumentFileCompat.fromFile(editableFile).copyTo(originalDocumentFile)

            if (!checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return false
            }
        } catch (e: IOException) {
            callback.onFailure(e)
            return false
        }

        return true
    }

    // A few bytes are sometimes appended when writing to a document output stream.
    // In that case, we need to adjust the trailer video offset accordingly and rewrite the file.
    // return whether the file at `path` is fine
    private fun checkTrailerOffset(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        trailerOffset: Int?,
        editedFile: File,
        callback: ImageOpCallback,
    ): Boolean {
        if (trailerOffset == null) return true

        val expectedLength = editedFile.length()
        val actualLength = File(path).length()
        val diff = (actualLength - expectedLength).toInt()
        if (diff == 0) return true

        Log.w(
            LOG_TAG, "Edited file length=$expectedLength does not match final document file length=$actualLength. " +
                    "We need to edit XMP to adjust trailer video offset by $diff bytes."
        )
        val newTrailerOffset = trailerOffset + diff
        return editXmp(context, path, uri, mimeType, callback, trailerDiff = diff) { xmp ->
            xmp.replace(
                // GCamera motion photo
                "${XMP.GCAMERA_VIDEO_OFFSET_PROP_NAME}=\"$trailerOffset\"",
                "${XMP.GCAMERA_VIDEO_OFFSET_PROP_NAME}=\"$newTrailerOffset\"",
            ).replace(
                // Container motion photo
                "${XMP.CONTAINER_ITEM_LENGTH_PROP_NAME}=\"$trailerOffset\"",
                "${XMP.CONTAINER_ITEM_LENGTH_PROP_NAME}=\"$newTrailerOffset\"",
            )
        }
    }

    fun editOrientation(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        op: ExifOrientationOp,
        callback: ImageOpCallback,
    ) {
        val newFields = HashMap<String, Any?>()

        val success = editExif(context, path, uri, mimeType, callback) { exif ->
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
            newFields["rotationDegrees"] = exif.rotationDegrees
            newFields["isFlipped"] = exif.isFlipped
        }

        if (success) {
            scanPostMetadataEdit(context, path, uri, mimeType, newFields, callback)
        }
    }

    fun editDate(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        dateMillis: Long?,
        shiftMinutes: Long?,
        fields: List<String>,
        callback: ImageOpCallback,
    ) {
        if (dateMillis != null && dateMillis < 0) {
            callback.onFailure(Exception("dateMillis=$dateMillis cannot be negative"))
            return
        }

        val success = editExif(context, path, uri, mimeType, callback) { exif ->
            when {
                dateMillis != null -> {
                    // set
                    val date = Date(dateMillis)
                    val dateString = ExifInterfaceHelper.DATETIME_FORMAT.format(date)
                    val subSec = dateMillis % 1000
                    val subSecString = if (subSec > 0) subSec.toString().padStart(3, '0') else null

                    if (fields.contains(ExifInterface.TAG_DATETIME)) {
                        exif.setAttribute(ExifInterface.TAG_DATETIME, dateString)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME, subSecString)
                    }
                    if (fields.contains(ExifInterface.TAG_DATETIME_ORIGINAL)) {
                        exif.setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, dateString)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME_ORIGINAL, subSecString)
                    }
                    if (fields.contains(ExifInterface.TAG_DATETIME_DIGITIZED)) {
                        exif.setAttribute(ExifInterface.TAG_DATETIME_DIGITIZED, dateString)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME_DIGITIZED, subSecString)
                    }
                    if (fields.contains(ExifInterface.TAG_GPS_DATESTAMP)) {
                        exif.setAttribute(ExifInterface.TAG_GPS_DATESTAMP, ExifInterfaceHelper.GPS_DATE_FORMAT.format(date))
                        exif.setAttribute(ExifInterface.TAG_GPS_TIMESTAMP, ExifInterfaceHelper.GPS_TIME_FORMAT.format(date))
                    }
                }
                shiftMinutes != null -> {
                    // shift
                    val shiftMillis = shiftMinutes * 60000
                    listOf(
                        ExifInterface.TAG_DATETIME,
                        ExifInterface.TAG_DATETIME_ORIGINAL,
                        ExifInterface.TAG_DATETIME_DIGITIZED,
                    ).forEach { field ->
                        if (fields.contains(field)) {
                            exif.getSafeDateMillis(field) { date ->
                                exif.setAttribute(field, ExifInterfaceHelper.DATETIME_FORMAT.format(date + shiftMillis))
                            }
                        }
                    }
                    if (fields.contains(ExifInterface.TAG_GPS_DATESTAMP)) {
                        exif.gpsDateTime?.let { date ->
                            val shifted = date + shiftMillis - TimeZone.getDefault().rawOffset
                            exif.setAttribute(ExifInterface.TAG_GPS_DATESTAMP, ExifInterfaceHelper.GPS_DATE_FORMAT.format(shifted))
                            exif.setAttribute(ExifInterface.TAG_GPS_TIMESTAMP, ExifInterfaceHelper.GPS_TIME_FORMAT.format(shifted))
                        }
                    }
                }
                else -> {
                    // clear
                    if (fields.contains(ExifInterface.TAG_DATETIME)) {
                        exif.setAttribute(ExifInterface.TAG_DATETIME, null)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME, null)
                        exif.setAttribute(ExifInterface.TAG_OFFSET_TIME, null)
                    }
                    if (fields.contains(ExifInterface.TAG_DATETIME_ORIGINAL)) {
                        exif.setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, null)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME_ORIGINAL, null)
                        exif.setAttribute(ExifInterface.TAG_OFFSET_TIME_ORIGINAL, null)
                    }
                    if (fields.contains(ExifInterface.TAG_DATETIME_DIGITIZED)) {
                        exif.setAttribute(ExifInterface.TAG_DATETIME_DIGITIZED, null)
                        exif.setAttribute(ExifInterface.TAG_SUBSEC_TIME_DIGITIZED, null)
                        exif.setAttribute(ExifInterface.TAG_OFFSET_TIME_DIGITIZED, null)
                    }
                    if (fields.contains(ExifInterface.TAG_GPS_DATESTAMP)) {
                        exif.setAttribute(ExifInterface.TAG_GPS_DATESTAMP, null)
                        exif.setAttribute(ExifInterface.TAG_GPS_TIMESTAMP, null)
                    }
                }
            }
            exif.saveAttributes()
        }

        if (success) {
            scanPostMetadataEdit(context, path, uri, mimeType, HashMap<String, Any?>(), callback)
        }
    }

    fun removeMetadataTypes(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        types: Set<String>,
        callback: ImageOpCallback,
    ) {
        if (!canRemoveMetadata(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return
        }

        val originalDocumentFile = getDocumentFile(context, path, uri)
        if (originalDocumentFile == null) {
            callback.onFailure(Exception("failed to get document file for path=$path, uri=$uri"))
            return
        }

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.toInt()
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                outputStream().use { output ->
                    // reopen input to read from start
                    originalDocumentFile.openInputStream().use { input ->
                        PixyMetaHelper.removeMetadata(input, output, types)
                    }
                }
            } catch (e: Exception) {
                Log.d(LOG_TAG, "failed to remove metadata", e)
                callback.onFailure(e)
                return
            }
        }

        try {
            // copy the edited temporary file back to the original
            DocumentFileCompat.fromFile(editableFile).copyTo(originalDocumentFile)

            if (!types.contains(Metadata.TYPE_XMP) && !checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return
            }
        } catch (e: IOException) {
            callback.onFailure(e)
            return
        }

        val newFields = HashMap<String, Any?>()
        scanPostMetadataEdit(context, path, uri, mimeType, newFields, callback)
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
