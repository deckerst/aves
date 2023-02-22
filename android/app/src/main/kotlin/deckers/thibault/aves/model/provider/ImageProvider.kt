package deckers.thibault.aves.model.provider

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.util.Log
import androidx.core.net.toUri
import androidx.exifinterface.media.ExifInterface
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.FutureTarget
import com.bumptech.glide.request.RequestOptions
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.decoder.MultiTrackImage
import deckers.thibault.aves.decoder.SvgImage
import deckers.thibault.aves.decoder.TiffImage
import deckers.thibault.aves.metadata.*
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.Metadata.TYPE_EXIF
import deckers.thibault.aves.metadata.Metadata.TYPE_IPTC
import deckers.thibault.aves.metadata.Metadata.TYPE_MP4
import deckers.thibault.aves.metadata.Metadata.TYPE_XMP
import deckers.thibault.aves.metadata.Mp4ParserHelper.updateLocation
import deckers.thibault.aves.metadata.Mp4ParserHelper.updateRotation
import deckers.thibault.aves.metadata.Mp4ParserHelper.updateXmp
import deckers.thibault.aves.metadata.PixyMetaHelper.extendedXmpDocString
import deckers.thibault.aves.metadata.PixyMetaHelper.xmpDocString
import deckers.thibault.aves.model.*
import deckers.thibault.aves.utils.*
import deckers.thibault.aves.utils.FileUtils.transferFrom
import deckers.thibault.aves.utils.FileUtils.transferTo
import deckers.thibault.aves.utils.MimeTypes.canEditExif
import deckers.thibault.aves.utils.MimeTypes.canEditIptc
import deckers.thibault.aves.utils.MimeTypes.canEditXmp
import deckers.thibault.aves.utils.MimeTypes.canRemoveMetadata
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import java.io.*
import java.nio.channels.Channels
import java.util.*

abstract class ImageProvider {
    open fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException("`fetchSingle` is not supported by this image provider"))
    }

    suspend fun scanNewPath(context: Context, path: String, mimeType: String): FieldMap {
        return if (StorageUtils.isInVault(context, path)) {
            hashMapOf(
                "origin" to SourceEntry.ORIGIN_VAULT,
                "uri" to File(path).toUri().toString(),
                "contentId" to null,
                "path" to path,
            )
        } else {
            MediaStoreImageProvider().scanNewPathByMediaStore(context, path, mimeType)
        }
    }

    open suspend fun delete(contextWrapper: ContextWrapper, uri: Uri, path: String?, mimeType: String) {
        throw UnsupportedOperationException("`delete` is not supported by this image provider")
    }

    open suspend fun moveMultiple(
        activity: Activity,
        copy: Boolean,
        nameConflictStrategy: NameConflictStrategy,
        entriesByTargetDir: Map<String, List<AvesEntry>>,
        isCancelledOp: CancelCheck,
        callback: ImageOpCallback,
    ) {
        callback.onFailure(UnsupportedOperationException("`moveMultiple` is not supported by this image provider"))
    }

    suspend fun renameMultiple(
        activity: Activity,
        entriesToNewName: Map<AvesEntry, String>,
        isCancelledOp: CancelCheck,
        callback: ImageOpCallback,
    ) {
        for (kv in entriesToNewName) {
            val entry = kv.key
            val desiredName = kv.value

            val sourceUri = entry.uri
            val sourcePath = entry.path
            val mimeType = entry.mimeType

            val result: FieldMap = hashMapOf(
                "uri" to sourceUri.toString(),
                "success" to false,
            )

            // prevent naming with a `.` prefix as it would hide the file and remove it from the Media Store
            if (sourcePath != null && !desiredName.startsWith('.')) {
                try {
                    var newFields: FieldMap = skippedFieldMap
                    if (!isCancelledOp()) {
                        val desiredNameWithoutExtension = desiredName.substringBeforeLast(".")

                        val oldFile = File(sourcePath)
                        if (oldFile.nameWithoutExtension != desiredNameWithoutExtension) {
                            oldFile.parent?.let { dir ->
                                resolveTargetFileNameWithoutExtension(
                                    contextWrapper = activity,
                                    dir = dir,
                                    desiredNameWithoutExtension = desiredNameWithoutExtension,
                                    mimeType = mimeType,
                                    conflictStrategy = NameConflictStrategy.RENAME,
                                )?.let { targetNameWithoutExtension ->
                                    val targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType)}"
                                    val newFile = File(dir, targetFileName)
                                    if (oldFile != newFile) {
                                        newFields = renameSingle(
                                            activity = activity,
                                            mimeType = mimeType,
                                            oldMediaUri = sourceUri,
                                            oldPath = sourcePath,
                                            newFile = newFile,
                                        )
                                    }
                                }
                            }
                        }
                    }
                    result["newFields"] = newFields
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to rename to newFileName=$desiredName entry with sourcePath=$sourcePath", e)
                }
            }
            callback.onSuccess(result)
        }
    }

    open suspend fun renameSingle(
        activity: Activity,
        mimeType: String,
        oldMediaUri: Uri,
        oldPath: String,
        newFile: File,
    ): FieldMap {
        throw UnsupportedOperationException("`renameSingle` is not supported by this image provider")
    }

    open fun scanPostMetadataEdit(context: Context, path: String, uri: Uri, mimeType: String, newFields: FieldMap, callback: ImageOpCallback) {
        throw UnsupportedOperationException("`scanPostMetadataEdit` is not supported by this image provider")
    }

    suspend fun exportMultiple(
        activity: Activity,
        imageExportMimeType: String,
        targetDir: String,
        entries: List<AvesEntry>,
        width: Int,
        height: Int,
        nameConflictStrategy: NameConflictStrategy,
        callback: ImageOpCallback,
    ) {
        if (!supportedExportMimeTypes.contains(imageExportMimeType)) {
            callback.onFailure(Exception("unsupported export MIME type=$imageExportMimeType"))
        }

        val targetDirDocFile = StorageUtils.createDirectoryDocIfAbsent(activity, targetDir)
        if (!File(targetDir).exists()) {
            callback.onFailure(Exception("failed to create directory at path=$targetDir"))
            return
        }

        for (entry in entries) {
            val sourceUri = entry.uri
            val sourcePath = entry.path
            val pageId = entry.pageId

            val result: FieldMap = hashMapOf(
                "uri" to sourceUri.toString(),
                "pageId" to pageId,
                "success" to false,
            )

            val sourceMimeType = entry.mimeType
            val exportMimeType = if (isVideo(sourceMimeType)) sourceMimeType else imageExportMimeType
            try {
                val newFields = exportSingle(
                    activity = activity,
                    sourceEntry = entry,
                    targetDir = targetDir,
                    targetDirDocFile = targetDirDocFile,
                    width = width,
                    height = height,
                    nameConflictStrategy = nameConflictStrategy,
                    exportMimeType = exportMimeType,
                )
                result["newFields"] = newFields
                result["success"] = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to export to targetDir=$targetDir entry with sourcePath=$sourcePath pageId=$pageId", e)
            }
            callback.onSuccess(result)
        }
    }

    private suspend fun exportSingle(
        activity: Activity,
        sourceEntry: AvesEntry,
        targetDir: String,
        targetDirDocFile: DocumentFileCompat?,
        width: Int,
        height: Int,
        nameConflictStrategy: NameConflictStrategy,
        exportMimeType: String,
    ): FieldMap {
        val sourceMimeType = sourceEntry.mimeType
        val sourceUri = sourceEntry.uri
        val pageId = sourceEntry.pageId

        var desiredNameWithoutExtension = if (sourceEntry.path != null) {
            val sourceFileName = File(sourceEntry.path).name
            sourceFileName.substringBeforeLast(".")
        } else {
            sourceUri.lastPathSegment!!
        }
        if (pageId != null) {
            val page = if (sourceMimeType == MimeTypes.TIFF) pageId + 1 else pageId
            desiredNameWithoutExtension += "_${page.toString().padStart(3, '0')}"
        }
        val targetNameWithoutExtension = resolveTargetFileNameWithoutExtension(
            contextWrapper = activity,
            dir = targetDir,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            mimeType = exportMimeType,
            conflictStrategy = nameConflictStrategy,
        ) ?: return skippedFieldMap

        val targetMimeType: String
        val write: (OutputStream) -> Unit
        var target: FutureTarget<Bitmap>? = null
        try {
            if (isVideo(sourceMimeType)) {
                targetMimeType = sourceMimeType
                write = { output ->
                    val sourceDocFile = DocumentFileCompat.fromSingleUri(activity, sourceUri)
                    @Suppress("BlockingMethodInNonBlockingContext")
                    sourceDocFile.copyTo(output)
                }
            } else {
                val model: Any = if (MimeTypes.isHeic(sourceMimeType) && pageId != null) {
                    MultiTrackImage(activity, sourceUri, pageId)
                } else if (sourceMimeType == MimeTypes.TIFF) {
                    TiffImage(activity, sourceUri, pageId)
                } else if (sourceMimeType == MimeTypes.SVG) {
                    SvgImage(activity, sourceUri)
                } else {
                    StorageUtils.getGlideSafeUri(activity, sourceUri, sourceMimeType, sourceEntry.sizeBytes)
                }

                // request a fresh image with the highest quality format
                val glideOptions = RequestOptions()
                    .format(DecodeFormat.PREFER_ARGB_8888)
                    .diskCacheStrategy(DiskCacheStrategy.NONE)
                    .skipMemoryCache(true)

                target = Glide.with(activity)
                    .asBitmap()
                    .apply(glideOptions)
                    .load(model)
                    .submit(width, height)
                @Suppress("BlockingMethodInNonBlockingContext")
                var bitmap = target.get()
                if (MimeTypes.needRotationAfterGlide(sourceMimeType)) {
                    bitmap = BitmapUtils.applyExifOrientation(activity, bitmap, sourceEntry.rotationDegrees, sourceEntry.isFlipped)
                }
                bitmap ?: throw Exception("failed to get image for mimeType=$sourceMimeType uri=$sourceUri page=$pageId")

                targetMimeType = exportMimeType
                write = { output ->
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
                                @Suppress("deprecation")
                                Bitmap.CompressFormat.WEBP
                            }
                            else -> throw Exception("unsupported export MIME type=$exportMimeType")
                        }
                        bitmap.compress(format, quality, output)
                    }
                }
            }

            val targetPath = MediaStoreImageProvider().createSingle(
                activity = activity,
                mimeType = targetMimeType,
                targetDir = targetDir,
                targetDirDocFile = targetDirDocFile,
                targetNameWithoutExtension = targetNameWithoutExtension,
                write = write,
            )
            return scanNewPath(activity, targetPath, exportMimeType)
        } finally {
            // clearing Glide target should happen after effectively writing the bitmap
            Glide.with(activity).clear(target)
        }
    }

    @Suppress("BlockingMethodInNonBlockingContext")
    suspend fun captureFrame(
        contextWrapper: ContextWrapper,
        desiredNameWithoutExtension: String,
        exifFields: FieldMap,
        bytes: ByteArray,
        targetDir: String,
        nameConflictStrategy: NameConflictStrategy,
        callback: ImageOpCallback,
    ) {
        val targetDirDocFile = StorageUtils.createDirectoryDocIfAbsent(contextWrapper, targetDir)
        if (!File(targetDir).exists()) {
            callback.onFailure(Exception("failed to create directory at path=$targetDir"))
            return
        }

        // TODO TLAD [storage] allow inserting by Media Store
        if (targetDirDocFile == null) {
            callback.onFailure(Exception("failed to get tree doc for directory at path=$targetDir"))
            return
        }

        val captureMimeType = MimeTypes.JPEG
        val targetNameWithoutExtension = try {
            resolveTargetFileNameWithoutExtension(
                contextWrapper = contextWrapper,
                dir = targetDir,
                desiredNameWithoutExtension = desiredNameWithoutExtension,
                mimeType = captureMimeType,
                conflictStrategy = nameConflictStrategy,
            )
        } catch (e: Exception) {
            callback.onFailure(e)
            return
        }

        if (targetNameWithoutExtension == null) {
            // skip it
            callback.onSuccess(skippedFieldMap)
            return
        }

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        val targetTreeFile = targetDirDocFile.createFile(captureMimeType, targetNameWithoutExtension)
        val targetDocFile = DocumentFileCompat.fromSingleUri(contextWrapper, targetTreeFile.uri)

        try {
            if (exifFields.isEmpty()) {
                targetDocFile.openOutputStream().use { output ->
                    output.write(bytes)
                }
            } else {
                val editableFile = File.createTempFile("aves", null).apply {
                    deleteOnExit()
                    transferFrom(ByteArrayInputStream(bytes), bytes.size.toLong())
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
                DocumentFileCompat.fromFile(editableFile).copyTo(targetDocFile)
                editableFile.delete()
            }

            val fileName = targetDocFile.name
            val targetFullPath = targetDir + fileName
            val newFields = scanNewPath(contextWrapper, targetFullPath, captureMimeType)
            callback.onSuccess(newFields)
        } catch (e: Exception) {
            callback.onFailure(e)
        }
    }

    // returns available name to use, or `null` to skip it
    suspend fun resolveTargetFileNameWithoutExtension(
        contextWrapper: ContextWrapper,
        dir: String,
        desiredNameWithoutExtension: String,
        mimeType: String,
        conflictStrategy: NameConflictStrategy,
    ): String? {
        val extension = extensionFor(mimeType)
        val targetFile = File(dir, "$desiredNameWithoutExtension$extension")
        return when (conflictStrategy) {
            NameConflictStrategy.RENAME -> {
                var nameWithoutExtension = desiredNameWithoutExtension
                var i = 0
                while (File(dir, "$nameWithoutExtension$extension").exists()) {
                    i++
                    nameWithoutExtension = "$desiredNameWithoutExtension ($i)"
                }
                nameWithoutExtension
            }
            NameConflictStrategy.REPLACE -> {
                if (targetFile.exists()) {
                    val path = targetFile.path
                    MediaStoreImageProvider().apply {
                        val uri = getContentUriForPath(contextWrapper, path)
                        uri ?: throw Exception("failed to find content URI for path=$path")
                        delete(contextWrapper, uri, path, mimeType)
                    }
                }
                desiredNameWithoutExtension
            }
            NameConflictStrategy.SKIP -> {
                if (targetFile.exists()) {
                    null
                } else {
                    desiredNameWithoutExtension
                }
            }
        }
    }

    private fun editExif(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
        autoCorrectTrailerOffset: Boolean = true,
        trailerDiff: Int = 0,
        edit: (exif: ExifInterface) -> Unit,
    ): Boolean {
        if (!canEditExif(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.let { it.toInt() + trailerDiff }
        var videoBytes: ByteArray? = null
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
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
                        transferFrom(ByteArrayInputStream(imageBytes), imageBytes.size.toLong())
                    }
                } else {
                    // copy original file to a temporary file for editing
                    val inputStream = StorageUtils.openInputStream(context, uri)
                    transferFrom(inputStream, originalFileSize)
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
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return false
            }
            editableFile.delete()
        } catch (e: IOException) {
            callback.onFailure(e)
            return false
        }

        return true
    }

    private fun editIptc(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
        autoCorrectTrailerOffset: Boolean = true,
        trailerDiff: Int = 0,
        iptc: List<FieldMap>?,
    ): Boolean {
        if (!canEditIptc(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.let { it.toInt() + trailerDiff }
        var videoBytes: ByteArray? = null
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
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
                        transferFrom(ByteArrayInputStream(imageBytes), imageBytes.size.toLong())
                    }
                } else {
                    // copy original file to a temporary file for editing
                    val inputStream = StorageUtils.openInputStream(context, uri)
                    transferFrom(inputStream, originalFileSize)
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return false
            }
        }

        try {
            editableFile.outputStream().use { output ->
                // reopen input to read from start
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    when {
                        iptc != null ->
                            PixyMetaHelper.setIptc(input, output, iptc)
                        canRemoveMetadata(mimeType) ->
                            PixyMetaHelper.removeMetadata(input, output, setOf(TYPE_IPTC))
                        else -> {
                            Log.w(LOG_TAG, "setting empty IPTC for mimeType=$mimeType")
                            PixyMetaHelper.setIptc(input, output, null)
                        }
                    }
                }
            }

            if (videoBytes != null) {
                // append trailer video, if any
                editableFile.appendBytes(videoBytes!!)
            }

            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return false
            }
            editableFile.delete()
        } catch (e: IOException) {
            callback.onFailure(e)
            return false
        }

        return true
    }

    private fun editMp4Metadata(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
        fieldsToEdit: Map<*, *>,
        newFields: FieldMap? = null,
    ): Boolean {
        if (mimeType != MimeTypes.MP4) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        try {
            val edits = Mp4ParserHelper.computeEdits(context, uri) { isoFile ->
                fieldsToEdit.forEach { kv ->
                    val tag = kv.key as String
                    val value = kv.value as String?
                    when (tag) {
                        "gpsCoordinates" -> isoFile.updateLocation(value)
                        "rotationDegrees" -> {
                            val degrees = value?.toIntOrNull() ?: throw Exception("failed because of invalid rotation=$value")
                            if (isoFile.updateRotation(degrees) && newFields != null) {
                                newFields["rotationDegrees"] = degrees
                            }
                        }
                        "xmp" -> isoFile.updateXmp(value)
                    }
                }
            }

            val pfd = StorageUtils.openOutputFileDescriptor(
                context = context,
                mimeType = mimeType,
                uri = uri,
                path = path,
                // do not truncate with "t"
                // "w" is enough on API 29+, but it will yield an empty file on API <29
                // so "r" is necessary for backward compatibility
                mode = "rw",
            ) ?: throw Exception("failed to open file descriptor for uri=$uri path=$path")
            pfd.use {
                FileOutputStream(it.fileDescriptor).use { outputStream ->
                    outputStream.channel.use { outputChannel ->
                        edits.forEach { (offset, bytes) ->
                            bytes.inputStream().use { inputStream ->
                                Channels.newChannel(inputStream).use { inputChannel ->
                                    outputChannel.transferFrom(inputChannel, offset, bytes.size.toLong())
                                }
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            callback.onFailure(e)
            return false
        }

        return true
    }

    // provide `editCoreXmp` to modify existing core XMP,
    // or provide `coreXmp` and `extendedXmp` to set them
    private fun editXmp(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
        autoCorrectTrailerOffset: Boolean = true,
        trailerDiff: Int = 0,
        coreXmp: String? = null,
        extendedXmp: String? = null,
        editCoreXmp: ((xmp: String) -> String)? = null,
    ): Boolean {
        if (!canEditXmp(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        if (mimeType == MimeTypes.MP4) {
            return editMp4Metadata(
                context = context,
                path = path,
                uri = uri,
                mimeType = mimeType,
                callback = callback,
                fieldsToEdit = mapOf("xmp" to coreXmp),
            )
        }

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.let { it.toInt() + trailerDiff }
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                editXmpWithPixy(
                    context = context,
                    uri = uri,
                    mimeType = mimeType,
                    coreXmp = coreXmp,
                    extendedXmp = extendedXmp,
                    editCoreXmp = editCoreXmp,
                    editableFile = this
                )
            } catch (e: Exception) {
                callback.onFailure(e)
                return false
            }
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return false
            }
            editableFile.delete()
        } catch (e: IOException) {
            callback.onFailure(e)
            return false
        }

        return true
    }

    private fun editXmpWithPixy(
        context: Context,
        uri: Uri,
        mimeType: String,
        coreXmp: String?,
        extendedXmp: String?,
        editCoreXmp: ((xmp: String) -> String)?,
        editableFile: File
    ) {
        var editedXmpString = coreXmp
        var editedExtendedXmp = extendedXmp
        if (editCoreXmp != null) {
            val pixyXmp = StorageUtils.openInputStream(context, uri)?.use { input -> PixyMetaHelper.getXmp(input) }
            if (pixyXmp != null) {
                editedXmpString = editCoreXmp(pixyXmp.xmpDocString())
                if (pixyXmp.hasExtendedXmp()) {
                    editedExtendedXmp = pixyXmp.extendedXmpDocString()
                }
            }
        }

        editableFile.outputStream().use { output ->
            // reopen input to read from start
            StorageUtils.openInputStream(context, uri)?.use { input ->
                if (editedXmpString != null) {
                    if (editedExtendedXmp != null && mimeType != MimeTypes.JPEG) {
                        Log.w(LOG_TAG, "extended XMP is not supported by mimeType=$mimeType")
                        PixyMetaHelper.setXmp(input, output, editedXmpString, null)
                    } else {
                        PixyMetaHelper.setXmp(input, output, editedXmpString, editedExtendedXmp)
                    }
                } else if (canRemoveMetadata(mimeType)) {
                    PixyMetaHelper.removeMetadata(input, output, setOf(TYPE_XMP))
                } else {
                    Log.w(LOG_TAG, "setting empty XMP for mimeType=$mimeType")
                    PixyMetaHelper.setXmp(input, output, null, null)
                }
            }
        }
    }

    // A few bytes are sometimes appended when writing to a document output stream.
    // In that case, we need to adjust the trailer video offset accordingly and rewrite the file.
    // returns whether the file at `path` is fine
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
        return editXmp(context, path, uri, mimeType, callback, trailerDiff = diff, editCoreXmp = { xmp ->
            xmp.replace(
                // GCamera motion photo
                "${XMP.GCAMERA_VIDEO_OFFSET_PROP_NAME}=\"$trailerOffset\"",
                "${XMP.GCAMERA_VIDEO_OFFSET_PROP_NAME}=\"$newTrailerOffset\"",
            ).replace(
                // Container motion photo
                "${XMP.GCONTAINER_ITEM_LENGTH_PROP_NAME}=\"$trailerOffset\"",
                "${XMP.GCONTAINER_ITEM_LENGTH_PROP_NAME}=\"$newTrailerOffset\"",
            )
        })
    }

    fun editOrientation(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        op: ExifOrientationOp,
        callback: ImageOpCallback,
    ) {
        val newFields: FieldMap = hashMapOf()

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
                            val subSecTag = when (field) {
                                ExifInterface.TAG_DATETIME -> ExifInterface.TAG_SUBSEC_TIME
                                ExifInterface.TAG_DATETIME_DIGITIZED -> ExifInterface.TAG_SUBSEC_TIME_DIGITIZED
                                ExifInterface.TAG_DATETIME_ORIGINAL -> ExifInterface.TAG_SUBSEC_TIME_ORIGINAL
                                else -> null
                            }
                            exif.getSafeDateMillis(field, subSecTag) { date ->
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
            scanPostMetadataEdit(context, path, uri, mimeType, HashMap(), callback)
        }
    }

    fun editMetadata(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        modifier: FieldMap,
        autoCorrectTrailerOffset: Boolean,
        callback: ImageOpCallback,
    ) {
        val newFields: FieldMap = hashMapOf()
        if (modifier.containsKey(TYPE_EXIF)) {
            val fields = modifier[TYPE_EXIF] as Map<*, *>?
            if (fields != null && fields.isNotEmpty()) {
                if (!editExif(
                        context = context,
                        path = path,
                        uri = uri,
                        mimeType = mimeType,
                        callback = callback,
                        autoCorrectTrailerOffset = autoCorrectTrailerOffset,
                    ) { exif ->
                        var setLocation = false
                        fields.forEach { kv ->
                            val tag = kv.key as String?
                            if (tag != null) {
                                val value = kv.value
                                if (value == null) {
                                    // remove attribute
                                    exif.setAttribute(tag, null)
                                } else {
                                    when (tag) {
                                        ExifInterface.TAG_GPS_LATITUDE,
                                        ExifInterface.TAG_GPS_LATITUDE_REF,
                                        ExifInterface.TAG_GPS_LONGITUDE,
                                        ExifInterface.TAG_GPS_LONGITUDE_REF -> {
                                            setLocation = true
                                        }
                                        else -> {
                                            if (value is String) {
                                                exif.setAttribute(tag, value)
                                            } else {
                                                Log.w(LOG_TAG, "failed to set Exif attribute $tag because value=$value is not a string")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (setLocation) {
                            val latAbs = (fields[ExifInterface.TAG_GPS_LATITUDE] as Number?)?.toDouble()
                            val latRef = fields[ExifInterface.TAG_GPS_LATITUDE_REF] as String?
                            val lngAbs = (fields[ExifInterface.TAG_GPS_LONGITUDE] as Number?)?.toDouble()
                            val lngRef = fields[ExifInterface.TAG_GPS_LONGITUDE_REF] as String?
                            if (latAbs != null && latRef != null && lngAbs != null && lngRef != null) {
                                val latitude = if (latRef == ExifInterface.LATITUDE_SOUTH) -latAbs else latAbs
                                val longitude = if (lngRef == ExifInterface.LONGITUDE_WEST) -lngAbs else lngAbs
                                exif.setLatLong(latitude, longitude)
                            } else {
                                Log.w(LOG_TAG, "failed to set Exif location with latAbs=$latAbs, latRef=$latRef, lngAbs=$lngAbs, lngRef=$lngRef")
                            }
                        }
                        exif.saveAttributes()
                    }
                ) return
            }
        }

        if (modifier.containsKey(TYPE_IPTC)) {
            val iptc = (modifier[TYPE_IPTC] as List<*>?)?.filterIsInstance<FieldMap>()
            if (!editIptc(
                    context = context,
                    path = path,
                    uri = uri,
                    mimeType = mimeType,
                    callback = callback,
                    autoCorrectTrailerOffset = autoCorrectTrailerOffset,
                    iptc = iptc,
                )
            ) return
        }

        if (modifier.containsKey(TYPE_MP4)) {
            val fieldsToEdit = modifier[TYPE_MP4] as Map<*, *>?
            if (fieldsToEdit != null && fieldsToEdit.isNotEmpty()) {
                if (!editMp4Metadata(
                        context = context,
                        path = path,
                        uri = uri,
                        mimeType = mimeType,
                        callback = callback,
                        fieldsToEdit = fieldsToEdit,
                        newFields = newFields,
                    )
                ) return
            }
        }

        if (modifier.containsKey(TYPE_XMP)) {
            val xmp = modifier[TYPE_XMP] as Map<*, *>?
            if (xmp != null) {
                val coreXmp = xmp["xmp"] as String?
                val extendedXmp = xmp["extendedXmp"] as String?
                if (!editXmp(
                        context = context,
                        path = path,
                        uri = uri,
                        mimeType = mimeType,
                        callback = callback,
                        autoCorrectTrailerOffset = autoCorrectTrailerOffset,
                        coreXmp = coreXmp,
                        extendedXmp = extendedXmp,
                    )
                ) return
            }
        }

        scanPostMetadataEdit(context, path, uri, mimeType, newFields, callback)
    }

    fun removeTrailerVideo(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        callback: ImageOpCallback,
    ) {
        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.toInt()
        if (videoSize == null) {
            callback.onFailure(Exception("failed to get trailer video size"))
            return
        }

        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                val inputStream = StorageUtils.openInputStream(context, uri)
                // partial copy
                transferFrom(inputStream, originalFileSize - videoSize)
            } catch (e: Exception) {
                Log.d(LOG_TAG, "failed to remove trailer video", e)
                callback.onFailure(e)
                return
            }
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))
            editableFile.delete()
        } catch (e: IOException) {
            callback.onFailure(e)
            return
        }

        val newFields: FieldMap = hashMapOf()
        scanPostMetadataEdit(context, path, uri, mimeType, newFields, callback)
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

        val originalFileSize = File(path).length()
        val videoSize = MultiPage.getMotionPhotoOffset(context, uri, mimeType, originalFileSize)?.toInt()
        val editableFile = File.createTempFile("aves", null).apply {
            deleteOnExit()
            try {
                outputStream().use { output ->
                    // reopen input to read from start
                    StorageUtils.openInputStream(context, uri)?.use { input ->
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
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (!types.contains(TYPE_XMP) && !checkTrailerOffset(context, path, uri, mimeType, videoSize, editableFile, callback)) {
                return
            }
            editableFile.delete()
        } catch (e: IOException) {
            callback.onFailure(e)
            return
        }

        val newFields: FieldMap = hashMapOf()
        scanPostMetadataEdit(context, path, uri, mimeType, newFields, callback)
    }

    private fun outputStream(
        context: Context,
        mimeType: String,
        uri: Uri,
        path: String
    ): OutputStream {
        // truncate is necessary when overwriting a longer file
        val mode = "wt"
        return if (isMediaUriPermissionGranted(context, uri, mimeType)) {
            StorageUtils.openOutputStream(context, mimeType, uri, mode) ?: throw Exception("failed to open output stream for uri=$uri")
        } else {
            val documentUri = StorageUtils.getDocumentFile(context, path, uri)?.uri ?: throw Exception("failed to get document file for path=$path, uri=$uri")
            context.contentResolver.openOutputStream(documentUri, mode) ?: throw Exception("failed to open output stream from documentUri=$documentUri for path=$path, uri=$uri")
        }
    }

    interface ImageOpCallback {
        fun onSuccess(fields: FieldMap)
        fun onFailure(throwable: Throwable)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ImageProvider>()

        val supportedExportMimeTypes = listOf(MimeTypes.BMP, MimeTypes.JPEG, MimeTypes.PNG, MimeTypes.WEBP)

        // used when skipping a move/creation op because the target file already exists
        val skippedFieldMap: HashMap<String, Any?> = hashMapOf("skipped" to true)

        // used when deleting instead of moving to bin because the target file no longer exists
        val deletedFieldMap: HashMap<String, Any?> = hashMapOf("deleted" to true)

        fun isMediaUriPermissionGranted(context: Context, uri: Uri, mimeType: String): Boolean {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val safeUri = StorageUtils.getMediaStoreScopedStorageSafeUri(uri, mimeType)

                val pid = Binder.getCallingPid()
                val uid = Binder.getCallingUid()
                val flags = Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                context.checkUriPermission(safeUri, pid, uid, flags) == PackageManager.PERMISSION_GRANTED
            } else {
                false
            }
        }
    }
}

typealias CancelCheck = () -> Boolean
