package deckers.thibault.aves.model.provider

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.util.Log
import androidx.core.net.toUri
import com.bumptech.glide.Glide
import com.bumptech.glide.request.FutureTarget
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.glide.AvesAppGlideModule
import deckers.thibault.aves.metadata.ExifInterfaceHelper
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.Metadata.TYPE_EXIF
import deckers.thibault.aves.metadata.Metadata.TYPE_IPTC
import deckers.thibault.aves.metadata.Metadata.TYPE_MP4
import deckers.thibault.aves.metadata.Metadata.TYPE_XMP
import deckers.thibault.aves.metadata.Mp4ParserHelper
import deckers.thibault.aves.metadata.Mp4ParserHelper.updateLocation
import deckers.thibault.aves.metadata.Mp4ParserHelper.updateRotation
import deckers.thibault.aves.metadata.Mp4ParserHelper.updateXmp
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.metadata.PixyMetaHelper
import deckers.thibault.aves.metadata.PixyMetaHelper.extendedXmpDocString
import deckers.thibault.aves.metadata.PixyMetaHelper.xmpDocString
import deckers.thibault.aves.metadata.metadataextractor.Helper
import deckers.thibault.aves.metadata.xmp.GoogleXMP
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.EntryFields
import deckers.thibault.aves.model.ExifOrientationOp
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.NameConflictResolution
import deckers.thibault.aves.model.NameConflictStrategy
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BmpWriter
import deckers.thibault.aves.utils.FileUtils.transferFrom
import deckers.thibault.aves.utils.FileUtils.transferTo
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.canEditExif
import deckers.thibault.aves.utils.MimeTypes.canEditIptc
import deckers.thibault.aves.utils.MimeTypes.canEditXmp
import deckers.thibault.aves.utils.MimeTypes.canReadWithExifInterface
import deckers.thibault.aves.utils.MimeTypes.canRemoveMetadata
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream
import java.nio.channels.Channels
import java.util.Date
import java.util.TimeZone
import kotlin.math.absoluteValue
import androidx.exifinterface.media.ExifInterfaceFork as ExifInterface

abstract class ImageProvider {
    open fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, allowUnsized: Boolean, callback: ImageOpCallback) {
        callback.onFailure(UnsupportedOperationException("`fetchSingle` is not supported by this image provider"))
    }

    suspend fun scanNewPath(context: Context, path: String, mimeType: String): FieldMap {
        return if (StorageUtils.isInVault(context, path)) {
            val uri = Uri.fromFile(File(path))
            hashMapOf(
                EntryFields.ORIGIN to SourceEntry.ORIGIN_VAULT,
                EntryFields.URI to uri.toString(),
                EntryFields.CONTENT_ID to null,
                EntryFields.PATH to path,
            )
        } else {
            MediaStoreImageProvider().scanNewPathByMediaStore(context, path, mimeType)
        }
    }

    private suspend fun deletePath(contextWrapper: ContextWrapper, path: String, mimeType: String) {
        if (StorageUtils.isInVault(contextWrapper, path)) {
            FileImageProvider().apply {
                val uri = Uri.fromFile(File(path))
                delete(contextWrapper, uri, path, mimeType)
            }
        } else {
            MediaStoreImageProvider().apply {
                val uri = getContentUriForPath(contextWrapper, path)
                uri ?: throw Exception("failed to find content URI for path=$path")
                delete(contextWrapper, uri, path, mimeType)
            }
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

            if (sourcePath != null) {
                try {
                    var newFields: FieldMap = skippedFieldMap
                    if (!isCancelledOp()) {
                        val desiredNameWithoutExtension = desiredName.substringBeforeLast(".")

                        val oldFile = File(sourcePath)
                        if (oldFile.nameWithoutExtension != desiredNameWithoutExtension) {
                            val defaultExtension = oldFile.extension
                            oldFile.parent?.let { dir ->
                                val resolution = resolveTargetFileNameWithoutExtension(
                                    contextWrapper = activity,
                                    dir = dir,
                                    desiredNameWithoutExtension = desiredNameWithoutExtension,
                                    mimeType = mimeType,
                                    defaultExtension = defaultExtension,
                                    conflictStrategy = NameConflictStrategy.RENAME,
                                )
                                resolution.nameWithoutExtension?.let { targetNameWithoutExtension ->
                                    val targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType, defaultExtension)}"
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

    suspend fun convertMultiple(
        activity: Activity,
        imageExportMimeType: String,
        targetDir: String,
        entries: List<AvesEntry>,
        quality: Int,
        lengthUnit: String,
        width: Int,
        height: Int,
        writeMetadata: Boolean,
        nameConflictStrategy: NameConflictStrategy,
        callback: ImageOpCallback,
    ) {
        if (!supportedExportMimeTypes.contains(imageExportMimeType)) {
            callback.onFailure(Exception("unsupported export MIME type=$imageExportMimeType"))
            return
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
                val newFields = convertSingle(
                    activity = activity,
                    sourceEntry = entry,
                    targetDir = targetDir,
                    targetDirDocFile = targetDirDocFile,
                    quality = quality,
                    lengthUnit = lengthUnit,
                    width = width,
                    height = height,
                    writeMetadata = writeMetadata,
                    nameConflictStrategy = nameConflictStrategy,
                    exportMimeType = exportMimeType,
                )
                result["newFields"] = newFields
                result["success"] = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to convert to targetDir=$targetDir entry with sourcePath=$sourcePath pageId=$pageId", e)
            }
            callback.onSuccess(result)
        }
    }

    private suspend fun convertSingle(
        activity: Activity,
        sourceEntry: AvesEntry,
        targetDir: String,
        targetDirDocFile: DocumentFileCompat?,
        quality: Int,
        lengthUnit: String,
        width: Int,
        height: Int,
        writeMetadata: Boolean,
        nameConflictStrategy: NameConflictStrategy,
        exportMimeType: String,
    ): FieldMap {
        val sourceMimeType = sourceEntry.mimeType
        var sourceUri = sourceEntry.uri
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

        // there is no benefit providing input extension
        // for known output MIME type
        val defaultExtension = null

        val resolution = resolveTargetFileNameWithoutExtension(
            contextWrapper = activity,
            dir = targetDir,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            mimeType = exportMimeType,
            defaultExtension = defaultExtension,
            conflictStrategy = nameConflictStrategy,
        )
        val targetNameWithoutExtension = resolution.nameWithoutExtension ?: return skippedFieldMap
        resolution.replacementFile?.let { file ->
            sourceUri = Uri.fromFile(file)
        }

        val targetMimeType: String
        val write: (OutputStream) -> Unit
        var target: FutureTarget<Bitmap>? = null
        try {
            if (isVideo(sourceMimeType)) {
                targetMimeType = sourceMimeType
                write = { output ->
                    val sourceDocFile = DocumentFileCompat.fromSingleUri(activity, sourceUri)
                    sourceDocFile.copyTo(output)
                }
            } else {
                val targetWidthPx: Int
                val targetHeightPx: Int
                when (lengthUnit) {
                    LENGTH_UNIT_PERCENT -> {
                        targetWidthPx = sourceEntry.displayWidth * width / 100
                        targetHeightPx = sourceEntry.displayHeight * height / 100
                    }

                    else -> {
                        targetWidthPx = width
                        targetHeightPx = height
                    }
                }

                target = Glide.with(activity.applicationContext)
                    .asBitmap()
                    .apply(AvesAppGlideModule.uncachedFullImageOptions)
                    .load(AvesAppGlideModule.getModel(activity, sourceUri, sourceMimeType, pageId, sourceEntry.sizeBytes))
                    .submit(targetWidthPx, targetHeightPx)

                var bitmap = withContext(Dispatchers.IO) { target.get() }
                if (MimeTypes.needRotationAfterGlide(sourceMimeType, pageId)) {
                    bitmap = BitmapUtils.applyExifOrientation(activity, bitmap, sourceEntry.rotationDegrees, sourceEntry.isFlipped)
                }
                bitmap ?: throw Exception("failed to get image for mimeType=$sourceMimeType uri=$sourceUri page=$pageId")

                targetMimeType = exportMimeType
                write = { output ->
                    if (exportMimeType == MimeTypes.BMP) {
                        BmpWriter.writeRGB24(bitmap, output)
                    } else {
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
                defaultExtension = defaultExtension,
                write = write,
            )

            val newFields = scanNewPath(activity, targetPath, exportMimeType)
            val targetUri = (newFields[EntryFields.URI] as String).toUri()
            if (writeMetadata) {
                copyMetadata(
                    context = activity,
                    sourceMimeType = sourceMimeType,
                    sourceUri = sourceUri,
                    targetMimeType = targetMimeType,
                    targetUri = targetUri,
                    targetPath = targetPath,
                )
            }

            return newFields
        } finally {
            // clearing Glide target should happen after effectively writing the bitmap
            Glide.with(activity.applicationContext).clear(target)

            resolution.replacementFile?.delete()
        }
    }

    private fun copyMetadata(
        context: Context,
        sourceMimeType: String,
        sourceUri: Uri,
        targetMimeType: String,
        targetUri: Uri,
        targetPath: String,
    ) {
        val editableFile = StorageUtils.createTempFile(context).apply {
            // copy original file to a temporary file for editing
            val inputStream = StorageUtils.openInputStream(context, targetUri)
            transferFrom(inputStream, File(targetPath).length())
        }

        // copy IPTC / XMP via PixyMeta
        PixyMetaHelper.copyIptcXmp(context, sourceMimeType, sourceUri, targetMimeType, targetUri, editableFile)

        // copy Exif via ExifInterface

        val exif = HashMap<String, String?>()
        val skippedTags = listOf(
            ExifInterface.TAG_IMAGE_LENGTH,
            ExifInterface.TAG_IMAGE_WIDTH,
            ExifInterface.TAG_ORIENTATION,
            // Thumbnail Offset / Length
            ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT,
            ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT_LENGTH,
            // Exif Image Width / Height
            ExifInterface.TAG_PIXEL_X_DIMENSION,
            ExifInterface.TAG_PIXEL_Y_DIMENSION,
        )
        if (canReadWithExifInterface(sourceMimeType) && canEditExif(targetMimeType)) {
            StorageUtils.openInputStream(context, sourceUri)?.use { input ->
                ExifInterface(input).apply {
                    ExifInterfaceHelper.allTags.keys.filterNot { skippedTags.contains(it) }.filter { hasAttribute(it) }.forEach { tag ->
                        exif[tag] = getAttribute(tag)
                    }
                }
            }
        }
        if (exif.isNotEmpty()) {
            ExifInterface(editableFile).apply {
                exif.entries.forEach { (tag, value) ->
                    setAttribute(tag, value)
                }
                saveAttributes()
            }
        }

        // copy the edited temporary file back to the original
        editableFile.transferTo(outputStream(context, targetMimeType, targetUri, targetPath))
        editableFile.delete()
    }

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
        val resolution = try {
            resolveTargetFileNameWithoutExtension(
                contextWrapper = contextWrapper,
                dir = targetDir,
                desiredNameWithoutExtension = desiredNameWithoutExtension,
                mimeType = captureMimeType,
                defaultExtension = null,
                conflictStrategy = nameConflictStrategy,
            )
        } catch (e: Exception) {
            callback.onFailure(e)
            return
        }

        val targetNameWithoutExtension = resolution.nameWithoutExtension
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
                val editableFile = withContext(Dispatchers.IO) { StorageUtils.createTempFile(contextWrapper) }.apply {
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

                    val timeZoneString = getTimeZoneString(TimeZone.getDefault(), dateTimeMillis)
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

    fun createTimeStampFileName() = Date().time.toString()

    private fun sanitizeDesiredFileName(desiredName: String): String {
        var name = desiredName
        // prevent creating hidden files
        while (name.isNotEmpty() && name.startsWith(".")) {
            name = name.substring(1)
        }
        if (name.isEmpty()) {
            name = createTimeStampFileName()
        }
        return name
    }

    // returns available name to use, or `null` to skip it
    suspend fun resolveTargetFileNameWithoutExtension(
        contextWrapper: ContextWrapper,
        dir: String,
        desiredNameWithoutExtension: String,
        mimeType: String,
        defaultExtension: String?,
        conflictStrategy: NameConflictStrategy,
    ): NameConflictResolution {
        val sanitizedNameWithoutExtension = sanitizeDesiredFileName(desiredNameWithoutExtension)
        var resolvedName: String? = sanitizedNameWithoutExtension
        var replacementFile: File? = null

        val extension = extensionFor(mimeType, defaultExtension)
        val targetFile = File(dir, "$sanitizedNameWithoutExtension$extension")
        when (conflictStrategy) {
            NameConflictStrategy.RENAME -> {
                var nameWithoutExtension = sanitizedNameWithoutExtension
                var i = 0
                while (File(dir, "$nameWithoutExtension$extension").exists()) {
                    i++
                    nameWithoutExtension = "$sanitizedNameWithoutExtension ($i)"
                }
                resolvedName = nameWithoutExtension
            }

            NameConflictStrategy.REPLACE -> {
                if (targetFile.exists()) {
                    // move replaced file to temp storage
                    // so that it can be used as a source for conversion or metadata copy
                    replacementFile = StorageUtils.createTempFile(contextWrapper).apply {
                        targetFile.transferTo(outputStream())
                    }
                    deletePath(contextWrapper, targetFile.path, mimeType)
                }
            }

            NameConflictStrategy.SKIP -> {
                if (targetFile.exists()) {
                    resolvedName = null
                }
            }
        }

        return NameConflictResolution(resolvedName, replacementFile)
    }

    // cf `MetadataFetchHandler.getCatalogMetadataByMetadataExtractor()` for a more thorough check
    fun detectMimeType(context: Context, uri: Uri, mimeType: String?, sizeBytes: Long?): String? {
        var detectedMimeType: String? = null
        if (MimeTypes.canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    detectedMimeType = Helper.readMimeType(input)
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }
        return detectedMimeType
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
        var trailerVideoBytes: ByteArray? = null
        val editableFile = StorageUtils.createTempFile(context).apply {
            val trailerVideoSize = MultiPage.getTrailerVideoSize(context, uri, mimeType, originalFileSize)?.let { it + trailerDiff }
            val isTrailerVideoValid = trailerVideoSize != null && MultiPage.getTrailerVideoInfo(context, uri, originalFileSize, trailerVideoSize) != null
            try {
                if (trailerVideoSize != null && isTrailerVideoValid) {
                    // handle motion photo and embedded video separately
                    val imageSize = (originalFileSize - trailerVideoSize).toInt()
                    val videoByteSize = trailerVideoSize.toInt()
                    trailerVideoBytes = ByteArray(videoByteSize)

                    StorageUtils.openInputStream(context, uri)?.let { input ->
                        val imageBytes = ByteArray(imageSize)
                        input.read(imageBytes, 0, imageSize)
                        input.read(trailerVideoBytes, 0, videoByteSize)

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

            val editableFileSizeBytes = editableFile.length()
            if (editableFileSizeBytes == 0L) {
                callback.onFailure(Exception("editing Exif yielded an empty file"))
                return false
            }

            val editedMimeType = detectMimeType(context, Uri.fromFile(editableFile), mimeType, editableFileSizeBytes)
            if (editedMimeType != mimeType) {
                throw Exception("editing Exif changes mimeType=$mimeType -> $editedMimeType for uri=$uri path=$path")
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // editing may corrupt the file for various reasons,
                // so we check whether decoding it throws an exception
                ImageDecoder.decodeBitmap(ImageDecoder.createSource(editableFile))
            }

            if (trailerVideoBytes != null) {
                // append trailer video, if any
                editableFile.appendBytes(trailerVideoBytes!!)
            }

            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(context, path, uri, mimeType, trailerVideoBytes?.size, editableFile, callback)) {
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
        var trailerVideoBytes: ByteArray? = null
        val editableFile = StorageUtils.createTempFile(context).apply {
            val trailerVideoSize = MultiPage.getTrailerVideoSize(context, uri, mimeType, originalFileSize)?.let { it + trailerDiff }
            val isTrailerVideoValid = trailerVideoSize != null && MultiPage.getTrailerVideoInfo(context, uri, originalFileSize, trailerVideoSize) != null
            try {
                if (trailerVideoSize != null && isTrailerVideoValid) {
                    // handle motion photo and embedded video separately
                    val imageSize = (originalFileSize - trailerVideoSize).toInt()
                    val videoByteSize = trailerVideoSize.toInt()
                    trailerVideoBytes = ByteArray(videoByteSize)

                    StorageUtils.openInputStream(context, uri)?.let { input ->
                        val imageBytes = ByteArray(imageSize)
                        input.read(imageBytes, 0, imageSize)
                        input.read(trailerVideoBytes, 0, videoByteSize)

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

            if (editableFile.length() == 0L) {
                callback.onFailure(Exception("editing IPTC yielded an empty file"))
                return false
            }

            if (trailerVideoBytes != null) {
                // append trailer video, if any
                editableFile.appendBytes(trailerVideoBytes!!)
            }

            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(context, path, uri, mimeType, trailerVideoBytes?.size, editableFile, callback)) {
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
        } catch (e: NoClassDefFoundError) {
            callback.onFailure(e)
            return false
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
        val trailerVideoSize = MultiPage.getTrailerVideoSize(context, uri, mimeType, originalFileSize)?.let { it.toInt() + trailerDiff }
        val editableFile = StorageUtils.createTempFile(context).apply {
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

        if (editableFile.length() == 0L) {
            callback.onFailure(Exception("editing XMP yielded an empty file"))
            return false
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(context, path, uri, mimeType, trailerVideoSize, editableFile, callback)) {
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
        trailerOffset: Number?,
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
        val newTrailerOffset = trailerOffset.toLong() + diff
        return editXmp(context, path, uri, mimeType, callback, trailerDiff = diff, editCoreXmp = { xmp ->
            GoogleXMP.updateTrailingVideoOffset(xmp, trailerOffset, newTrailerOffset)
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
        shiftSeconds: Long?,
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

                shiftSeconds != null -> {
                    // shift
                    val shiftMillis = shiftSeconds * 1000
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
        val trailerVideoSize = MultiPage.getTrailerVideoSize(context, uri, mimeType, originalFileSize)
        if (trailerVideoSize == null) {
            callback.onFailure(Exception("failed to get trailer video size"))
            return
        }

        val isTrailerVideoValid = MultiPage.getTrailerVideoInfo(context, uri, fileSize = originalFileSize, videoSize = trailerVideoSize) != null
        if (!isTrailerVideoValid) {
            callback.onFailure(Exception("failed to open trailer video with size=$trailerVideoSize"))
            return
        }

        val editableFile = StorageUtils.createTempFile(context).apply {
            try {
                val inputStream = StorageUtils.openInputStream(context, uri)
                // partial copy
                transferFrom(inputStream, originalFileSize - trailerVideoSize)
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
        val trailerVideoSize = MultiPage.getTrailerVideoSize(context, uri, mimeType, originalFileSize)
        val isTrailerVideoValid = trailerVideoSize != null && MultiPage.getTrailerVideoInfo(context, uri, originalFileSize, trailerVideoSize) != null
        val editableFile = StorageUtils.createTempFile(context).apply {
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

        if (editableFile.length() == 0L) {
            callback.onFailure(Exception("removing metadata yielded an empty file"))
            return
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.transferTo(outputStream(context, mimeType, uri, path))

            if (!types.contains(TYPE_XMP) && isTrailerVideoValid && !checkTrailerOffset(context, path, uri, mimeType, trailerVideoSize, editableFile, callback)) {
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

        private const val LENGTH_UNIT_PERCENT = "percent"

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

        fun getTimeZoneString(timeZone: TimeZone, dateTimeMillis: Long): String {
            val offset = timeZone.getOffset(dateTimeMillis)
            val offsetInMinutes = offset.absoluteValue / 60000
            val offsetSign = if (offset < 0) "-" else "+"
            val offsetHours = "${offsetInMinutes / 60}".padStart(2, '0')
            val offsetMinutes = "${offsetInMinutes % 60}".padStart(2, '0')
            return "$offsetSign$offsetHours:$offsetMinutes"
        }
    }
}

typealias CancelCheck = () -> Boolean
