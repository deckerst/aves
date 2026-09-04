package deckers.thibault.aves.model.provider

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.Context
import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.provider.BaseColumns
import android.util.Log
import androidx.core.net.toUri
import com.bumptech.glide.Glide
import com.bumptech.glide.request.FutureTarget
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.MainActivity.Companion.DELETE_SINGLE_PERMISSION_REQUEST
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
import deckers.thibault.aves.storage.PermissionManager
import deckers.thibault.aves.storage.StorageUtils
import deckers.thibault.aves.storage.StorageUtils.ensureTrailingSeparator
import deckers.thibault.aves.storage.StorageUtils.getVolumePath
import deckers.thibault.aves.storage.apis.MediaStorePermissions
import deckers.thibault.aves.storage.apis.StorageApi
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BmpWriter
import deckers.thibault.aves.utils.FileUtils
import deckers.thibault.aves.utils.FileUtils.copyFrom
import deckers.thibault.aves.utils.FileUtils.copyTo
import deckers.thibault.aves.utils.FileUtils.getFileSize
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.canEditExif
import deckers.thibault.aves.utils.MimeTypes.canEditIptc
import deckers.thibault.aves.utils.MimeTypes.canEditXmp
import deckers.thibault.aves.utils.MimeTypes.canReadWithExifInterface
import deckers.thibault.aves.utils.MimeTypes.canRemoveMetadata
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.UriUtils.isContentScheme
import deckers.thibault.aves.utils.UriUtils.isFileScheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream
import java.io.SyncFailedException
import java.nio.channels.Channels
import java.util.Date
import java.util.TimeZone
import java.util.concurrent.CompletableFuture
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
            MediaStoreImageProvider.scanNewPathByMediaStore(context, path, mimeType)
        }
    }

    fun createSingle(
        context: Context,
        mimeType: String,
        targetDir: String,
        targetNameWithoutExtension: String,
        defaultExtension: String?,
        write: (OutputStream) -> Unit,
    ): String {
        val editionApi = PermissionManager.getStorageEditionApis(
            context = context,
            dirPaths = listOf(ensureTrailingSeparator(targetDir)),
            insertion = true,
        ).values.firstOrNull()?.firstOrNull()
            ?: throw Exception("failed to find API for insertion in dir=$targetDir")

        when (editionApi) {
            StorageApi.FILE -> {
                return FileImageProvider.insert(
                    targetDirPath = targetDir,
                    targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType, defaultExtension)}",
                    write = write,
                )
            }

            StorageApi.MEDIA_STORE -> {
                return MediaStoreImageProvider.insert(
                    context = context,
                    mimeType = mimeType,
                    targetDir = targetDir,
                    targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType, defaultExtension)}",
                    write = write,
                )
            }

            StorageApi.SAF -> {
                return insertByTreeDoc(
                    context = context,
                    mimeType = mimeType,
                    targetDir = targetDir,
                    targetNameWithoutExtension = targetNameWithoutExtension,
                    defaultExtension = defaultExtension,
                    write = write,
                )
            }
        }
    }

    private fun insertByTreeDoc(
        context: Context,
        mimeType: String,
        targetDir: String,
        targetNameWithoutExtension: String,
        defaultExtension: String?,
        write: (OutputStream) -> Unit,
    ): String {
        val targetDirDocFile = StorageUtils.createDirectoryDocIfAbsent(context, targetDir)
        if (!File(targetDir).exists()) {
            throw Exception("failed to create directory at path=$targetDir")
        }
        targetDirDocFile ?: throw Exception("failed to get tree doc for directory at path=$targetDir")

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        var targetTreeFile = targetDirDocFile.createFile(mimeType, targetNameWithoutExtension)
        var targetDocFile = DocumentFileCompat.fromSingleUri(context, targetTreeFile.uri)

        // providing a display name and a MIME type does not guarantee
        // that the created document will be backed by a file with a valid media extension,
        // but having an extension is essential for media detection by Android,
        // so we retry with a display name that includes the extension
        if ((targetDocFile.extension == null || targetDocFile.extension.isEmpty() || targetDocFile.extension == "bin") && defaultExtension != null) {
            if (targetDocFile.exists()) {
                targetDocFile.delete()
            }

            val extension = if (defaultExtension.startsWith(".")) defaultExtension else ".$defaultExtension"
            targetTreeFile = targetDirDocFile.createFile(mimeType, "$targetNameWithoutExtension$extension")
            targetDocFile = DocumentFileCompat.fromSingleUri(context, targetTreeFile.uri)
        }

        try {
            targetDocFile.openOutputStream().use(write)
        } catch (e: Exception) {
            // remove empty file
            if (targetDocFile.exists()) {
                targetDocFile.delete()
            }
            throw e
        }

        // the source file name and the created document file name can be different when:
        // - a file with the same name already exists, some implementations give a suffix like ` (1)`, some *do not*
        // - the original extension does not match the extension added by the underlying provider
        val fileName = targetDocFile.name
        return targetDir + fileName
    }

    private fun deletePath(context: Context, path: String, mimeType: String) {
        if (StorageUtils.isInVault(context, path)) {
            FileImageProvider().apply {
                val uri = Uri.fromFile(File(path))
                deleteSingle(context, uri, path, mimeType)
            }
        } else {
            MediaStoreImageProvider().apply {
                val uri = getContentUriForPath(context, path)
                uri ?: throw Exception("failed to find content URI for path=$path")
                deleteSingle(context, uri, path, mimeType)
            }
        }
    }

    // the following situations are possible:
    // - there is a content row in the Media Store and there is a file on storage
    // - there is a content row in the Media Store, but there is no longer a file on storage
    // - there is no content row in the Media Store, but there is a file on storage
    fun deleteSingle(context: Context, uri: Uri, path: String?, mimeType: String) {
        path ?: throw Exception("failed to delete file because path is null")

        val file = File(path)

        val initialContentExists = contentExists(context, uri)
        val initialFileExists = file.exists()
        Log.d(LOG_TAG, "delete content at uri=$uri (exists=$initialContentExists), file at path=$file (exists=$initialFileExists)")

        if (initialContentExists) {
            // the delete request may yield a `RecoverableSecurityException` when using scoped storage,
            // even if we have permissions on the tree document via SAF
            val scopedStorage = Build.VERSION.SDK_INT > Build.VERSION_CODES.Q
            if (MediaStorePermissions.canEdit(context, uri, mimeType) || !scopedStorage) {
                Log.d(LOG_TAG, "delete via content resolver at uri=$uri")
                try {
                    val rowDeleted = context.contentResolver.delete(uri, null, null) > 0
                    if (!rowDeleted && contentExists(context, uri)) {
                        throw Exception("failed to delete row from content resolver")
                    }
                } catch (securityException: SecurityException) {
                    // even if the app has access permission granted on the containing directory,
                    // the delete request may yield a `RecoverableSecurityException` on API >=29
                    // when the underlying file no longer exists and this is an orphaned entry in the Media Store
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && context is Activity) {
                        Log.w(LOG_TAG, "caught a security exception when attempting to delete content at uri=$uri", securityException)
                        val rse = securityException as? RecoverableSecurityException ?: throw securityException
                        val intentSender = rse.userAction.actionIntent.intentSender

                        // request user permission for this item
                        MainActivity.pendingScopedStoragePermissionCompleter = CompletableFuture<Boolean>()
                        context.startIntentSenderForResult(intentSender, DELETE_SINGLE_PERMISSION_REQUEST, null, 0, 0, 0, null)
                        val granted = MainActivity.pendingScopedStoragePermissionCompleter!!.join()

                        MainActivity.pendingScopedStoragePermissionCompleter = null
                        if (granted) {
                            deleteSingle(context, uri, path, mimeType)
                            return
                        } else {
                            throw Exception("failed to get delete permission")
                        }
                    } else {
                        throw securityException
                    }
                }
            }
        }

        // in theory, deleting via content resolver should remove the file on storage
        // in practice, the file may still be there afterward
        if (file.exists()) {
            Log.d(LOG_TAG, "delete file at path=$file")
            FileUtils.delete(file)
        } else if (uri.isFileScheme) {
            val uriFilePath = File(uri.path!!).path
            // URI and path both point to the same non-existent path
            if (uriFilePath == path) return
        }

        if (file.exists()) {
            Log.d(LOG_TAG, "delete document at path=$path")
            val df = StorageUtils.getDocumentFile(context, path, uri)
            if (df == null || !df.delete()) {
                throw Exception("failed to delete document with df=$df")
            }
        }

        if (contentExists(context, uri) && StorageUtils.isMediaStoreContentUri(uri)) {
            // in theory, scanning an obsolete path should remove the entry from the Media Store
            // in practice, the entry may still be there afterward
            MediaStoreImageProvider.scanObsoletePath(context, uri, path, mimeType)
        }
    }

    suspend fun moveMultiple(
        context: Context,
        copy: Boolean,
        nameConflictStrategy: NameConflictStrategy,
        entriesByTargetDir: Map<String, List<AvesEntry>>,
        isCancelledOp: CancelCheck,
        callback: ImageOpCallback,
    ) {
        entriesByTargetDir.forEach { kv ->
            val targetDir = kv.key
            val entries = kv.value

            for (entry in entries) {
                val mimeType = entry.mimeType
                val trashed = entry.trashed

                val sourceUri = entry.uri
                val sourcePath = entry.storagePath

                var desiredName: String? = null
                if (trashed) {
                    entry.path?.let { desiredName = File(it).name }
                }

                val result: FieldMap = hashMapOf(
                    "uri" to sourceUri.toString(),
                    "success" to false,
                )

                try {
                    val newFields = if (isCancelledOp()) {
                        skippedFieldMap
                    } else {
                        val toBin = targetDir == StorageUtils.TRASH_PATH_PLACEHOLDER

                        val sourceFile = if (sourcePath != null) File(sourcePath) else null
                        if (sourceFile != null && !sourceFile.exists() && toBin) {
                            deleteSingle(context, sourceUri, sourcePath, mimeType = mimeType)
                            deletedFieldMap
                        } else {
                            var effectiveTargetDirPath = targetDir
                            if (toBin) {
                                // trash directory should be on the same storage volume as the entry
                                val trashDir = StorageUtils.trashDirFor(context, sourcePath ?: StorageUtils.getPrimaryVolumePath(context))
                                if (trashDir == null) {
                                    callback.onFailure(Exception("failed to find trash dir for path=$sourcePath"))
                                    return
                                }
                                effectiveTargetDirPath = trashDir.path
                            }
                            effectiveTargetDirPath = ensureTrailingSeparator(effectiveTargetDirPath)

                            val movedFieldMap = moveSingle(
                                context = context,
                                sourceFile = sourceFile,
                                sourceUri = sourceUri,
                                targetDirPath = effectiveTargetDirPath,
                                desiredName = desiredName ?: sourceFile?.name ?: sourceUri.lastPathSegment ?: createTimeStampFileName(),
                                nameConflictStrategy = nameConflictStrategy,
                                mimeType = mimeType,
                                copy = copy,
                                toBin = toBin,
                            )
                            movedFieldMap
                        }
                    }
                    result["newFields"] = newFields
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to move to targetDir=$targetDir entry with sourcePath=$sourcePath", e)
                }
                callback.onSuccess(result)
            }
        }
    }

    // on API 30 we cannot get SAF access granted directly to a volume root from its document tree,
    // but it is still less constraining to use tree document files than to rely on the Media Store
    //
    // Relying on `DocumentFile`, we can create an item via `DocumentFile.createFile()`, but:
    // - we need to scan the file to get the Media Store content URI
    // - the underlying document provider controls the new file name
    //
    // Relying on the Media Store, we can create an item via `ContentResolver.insert()`
    // with a path, and retrieve its content URI, but:
    // - the Media Store isolates content by storage volume (e.g. `MediaStore.Images.Media.getContentUri(volumeName)`)
    // - the Media Store volume name is not the same as the `StorageVolume` UUID (cf `StorageVolume.getMediaStoreVolumeName()`)
    // - inserting on a removable volume works on API 29, but not on older ones
    // - there is no documentation regarding support for usage with removable storage
    // - the Media Store only allows inserting in specific primary directories ("DCIM", "Pictures") when using scoped storage
    private suspend fun moveSingle(
        context: Context,
        sourceFile: File?,
        sourceUri: Uri,
        targetDirPath: String,
        desiredName: String,
        nameConflictStrategy: NameConflictStrategy,
        mimeType: String,
        copy: Boolean,
        toBin: Boolean,
    ): FieldMap {
        val sourcePath = sourceFile?.path
        val sourceExtension = sourceFile?.extension
        val sourceDirPath = sourceFile?.parent?.let { ensureTrailingSeparator(it) }
        if (sourceDirPath == targetDirPath && !(copy && nameConflictStrategy == NameConflictStrategy.RENAME)) {
            // nothing to do unless it is a renamed copy
            return skippedFieldMap
        }

        if (sourceFile != null && !sourceFile.exists()) {
            throw Exception("failed to move file because it is missing at path=$sourcePath")
        }

        val desiredNameWithoutExtension = desiredName.substringBeforeLast(".")
        val resolution = resolveTargetFileNameWithoutExtension(
            context = context,
            dir = targetDirPath,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            mimeType = mimeType,
            defaultExtension = sourceExtension,
            conflictStrategy = nameConflictStrategy,
        )
        val targetNameWithoutExtension = resolution.nameWithoutExtension ?: return skippedFieldMap
        val targetFile = File(targetDirPath, "$targetNameWithoutExtension.$sourceExtension")

        var moveApi: StorageApi? = null

        if (sourceDirPath != null) {
            val sourceEditionApi = PermissionManager.getStorageEditionApis(
                context = context,
                dirPaths = listOf(ensureTrailingSeparator(sourceDirPath)),
                insertion = false,
            ).values.firstOrNull()?.firstOrNull()
                ?: throw Exception("failed to find API for edition in dir=$targetDirPath")

            val targetEditionApi = PermissionManager.getStorageEditionApis(
                context = context,
                dirPaths = listOf(ensureTrailingSeparator(targetDirPath)),
                insertion = true,
            ).values.firstOrNull()?.firstOrNull()
                ?: throw Exception("failed to find API for insertion in dir=$targetDirPath")

            if (sourceEditionApi == targetEditionApi && sourceEditionApi == StorageApi.MEDIA_STORE) {
                // Media Store tables are segregated by storage volume,
                // so the API does not allow moving a file to a different volume
                if (!copy && getVolumePath(context, sourceFile.path) == getVolumePath(context, targetFile.path)) {
                    // when moving via the Media Store API, the primary directory of the target is constrained according to the content URI:
                    // - for `content://media/XXXX/images/media/`, allowed directories are [DCIM, Pictures]
                    // - for `content://media/XXXX/video/media/`, allowed directories are [DCIM, Movies, Pictures]
                    if (MediaStorePermissions.canMoveToPath(context = context, mimeType = mimeType, targetDirPath = targetDirPath)) {
                        moveApi = StorageApi.MEDIA_STORE
                    }
                }
            }

            if (sourceEditionApi == targetEditionApi && sourceEditionApi == StorageApi.FILE) {
                moveApi = StorageApi.FILE
            }

            // according to https://developer.android.com/training/data-storage/shared/media#direct-file-paths
            // direct file access is possible on Android 11 if Media Store permissions are granted
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                if (setOf(StorageApi.FILE, StorageApi.MEDIA_STORE).containsAll(setOf(sourceEditionApi, targetEditionApi))) {
                    // in practice moving files sometimes fail (e.g. from SD Pictures dir to SD app bin dir),
                    // so we only use this direct access for file copy
                    if (copy) {
                        moveApi = StorageApi.FILE
                    }
                }
            }
        }

        val beforeMove = System.nanoTime()
        val effectiveTargetPath = when (moveApi) {
            StorageApi.FILE -> {
                FileImageProvider.move(
                    sourceFile = sourceFile!!,
                    targetFile = targetFile,
                    copy = copy,
                )
            }

            StorageApi.MEDIA_STORE -> {
                MediaStoreImageProvider.move(
                    context = context,
                    mimeType = mimeType,
                    mediaUri = sourceUri,
                    sourceFile = sourceFile!!,
                    targetFile = targetFile,
                )
            }

            // TODO TLAD review `DocumentsContract.moveDocument` viability
            // Regarding SAF move/copy:
            // - `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
            // - `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
            // when used with entry URI as `sourceDocumentUri`, and targetDirDocFile URI as `targetParentDocumentUri`

            else -> {
                Log.d(LOG_TAG, "move doc at uri=$sourceUri")
                // always copy, even for move, then delete if necessary
                val targetPath = createSingle(
                    context = context,
                    mimeType = mimeType,
                    targetDir = targetDirPath,
                    targetNameWithoutExtension = targetNameWithoutExtension,
                    defaultExtension = sourceExtension,
                ) { output: OutputStream ->
                    try {
                        StorageUtils.openInputStream(context, sourceUri)?.use { input ->
                            input.copyTo(output)
                        }
                    } catch (e: SyncFailedException) {
                        // The copied file is synced after writing, but it consistently fails in some cases
                        // (e.g. copying to SD card on Xiaomi 2201117PG with Android 11).
                        // It seems this failure can be safely ignored, as the new file is complete.
                        Log.w(LOG_TAG, "sync failure after copying from uri=$sourceUri, path=$sourcePath to targetDir=$targetDirPath", e)
                    }
                }

                if (!copy) {
                    // delete original entry
                    try {
                        deleteSingle(context, sourceUri, sourcePath, mimeType)
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
                    }
                }

                targetPath
            }
        } ?: throw Exception("failed to get target path")

        val afterMove = System.nanoTime()
        var targetSizeBytes = 0L
        try {
            targetSizeBytes = getFileSize(effectiveTargetPath)
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get file size for path=$effectiveTargetPath", e)
        }
        val durationMillis = (afterMove - beforeMove) / 1_000_000
        Log.d(LOG_TAG, "moved via $moveApi API ${targetSizeBytes}B in ${durationMillis}ms at ${targetSizeBytes / durationMillis}KB/s")

        return if (toBin) {
            hashMapOf(
                EntryFields.TRASHED to true,
                EntryFields.TRASH_PATH to effectiveTargetPath,
            )
        } else {
            val fields = scanNewPath(context, effectiveTargetPath, mimeType)
            fields
        }
    }

    suspend fun renameMultiple(
        context: Context,
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
                                    context = context,
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
                                            context = context,
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
        context: Context,
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
        context: Context,
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
                    context = context,
                    sourceEntry = entry,
                    targetDir = targetDir,
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
        context: Context,
        sourceEntry: AvesEntry,
        targetDir: String,
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
            context = context,
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
                    StorageUtils.openInputStream(context, sourceUri)?.use { input ->
                        input.copyTo(output)
                    }
                }
            } else {
                var targetWidthPx: Int
                var targetHeightPx: Int
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

                val rotationDegrees = sourceEntry.rotationDegrees
                val needRotationAfterGlide = MimeTypes.needRotationAfterGlide(sourceMimeType, pageId)
                if (rotationDegrees != 0 && needRotationAfterGlide) {
                    targetWidthPx = targetHeightPx.also { targetHeightPx = targetWidthPx }
                }

                target = Glide.with(context.applicationContext)
                    .asBitmap()
                    .apply(AvesAppGlideModule.uncachedFullImageOptions)
                    .load(AvesAppGlideModule.getModel(context, sourceUri, sourceMimeType, pageId, sourceEntry.sizeBytes))
                    .submit(targetWidthPx, targetHeightPx)

                var bitmap = withContext(Dispatchers.IO) { target.get() }
                if (needRotationAfterGlide) {
                    bitmap = BitmapUtils.applyExifOrientation(context, bitmap, rotationDegrees, sourceEntry.isFlipped)
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
                                @Suppress("DEPRECATION")
                                Bitmap.CompressFormat.WEBP
                            }

                            else -> throw Exception("unsupported export MIME type=$exportMimeType")
                        }
                        bitmap.compress(format, quality, output)
                    }
                }
            }

            val targetPath = createSingle(
                context = context,
                mimeType = targetMimeType,
                targetDir = targetDir,
                targetNameWithoutExtension = targetNameWithoutExtension,
                defaultExtension = defaultExtension,
                write = write,
            )

            val newFields = scanNewPath(context, targetPath, exportMimeType)
            val targetUri = (newFields[EntryFields.URI] as String).toUri()
            if (writeMetadata) {
                copyMetadata(
                    context = context,
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
            Glide.with(context.applicationContext).clear(target)

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
            copyFrom(StorageUtils.openInputStream(context, targetUri), getFileSize(targetPath))
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
        editableFile.copyTo(outputStream(context, targetMimeType, targetUri, targetPath))
        editableFile.delete()
    }

    suspend fun captureFrame(
        context: Context,
        desiredNameWithoutExtension: String,
        exifFields: FieldMap,
        bytes: ByteArray,
        targetDir: String,
        nameConflictStrategy: NameConflictStrategy,
        callback: ImageOpCallback,
    ) {
        val captureMimeType = MimeTypes.JPEG

        // there is no benefit providing input extension
        // for known output MIME type
        val defaultExtension = null

        val resolution = try {
            resolveTargetFileNameWithoutExtension(
                context = context,
                dir = targetDir,
                desiredNameWithoutExtension = desiredNameWithoutExtension,
                mimeType = captureMimeType,
                defaultExtension = defaultExtension,
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

        val write: (OutputStream) -> Unit = { output ->
            if (exifFields.isEmpty()) {
                output.write(bytes)
            } else {
                val editableFile = StorageUtils.createTempFile(context).apply {
                    copyFrom(ByteArrayInputStream(bytes), bytes.size.toLong())
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
                editableFile.copyTo(output)
                editableFile.delete()
            }
        }

        try {
            val targetPath = createSingle(
                context = context,
                mimeType = captureMimeType,
                targetDir = targetDir,
                targetNameWithoutExtension = targetNameWithoutExtension,
                defaultExtension = defaultExtension,
                write = write,
            )
            val newFields = scanNewPath(context, targetPath, captureMimeType)
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
    fun resolveTargetFileNameWithoutExtension(
        context: Context,
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
                    replacementFile = StorageUtils.createTempFile(context).apply {
                        targetFile.copyTo(outputStream())
                    }
                    deletePath(context, targetFile.path, mimeType)
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

    // editing may corrupt the file for various reasons,
    // making them undecodable by some decoders (including Android's and Chrome's)
    // even though `BitmapFactory` successfully decodes their bounds,
    // so we check whether decoding it with `ImageDecoder` throws an exception
    private fun ensureDecodable(mimeType: String, editableFile: File) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val isMimeTypeSupported = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ImageDecoder.isMimeTypeSupported(mimeType)
            } else {
                true
            }
            if (isMimeTypeSupported) {
                ImageDecoder.decodeBitmap(ImageDecoder.createSource(editableFile))
            }
        }
    }

    private fun editExif(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        sizeBytes: Long,
        callback: ImageOpCallback,
        autoCorrectTrailerOffset: Boolean = true,
        trailerDiff: Int = 0,
        edit: (exif: ExifInterface) -> Unit,
    ): Boolean {
        if (!canEditExif(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        // prefer provided `sizeBytes` over file attribute, because the file size
        // may be temporary incorrect and not match results from `MediaScannerConnection`
        val originalFileSize = sizeBytes

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
                        copyFrom(ByteArrayInputStream(imageBytes), imageBytes.size.toLong())
                    }
                } else {
                    // copy original file to a temporary file for editing
                    copyFrom(StorageUtils.openInputStream(context, uri), originalFileSize)
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return false
            }
        }

        try {
            // ensure file is decodable before editing
            ensureDecodable(mimeType, editableFile)
        } catch (e: IOException) {
            callback.onFailure(Exception("failed to decode editable file before editing", e))
            return false
        }

        try {
            edit(ExifInterface(editableFile))

            val editableFileSizeBytes = getFileSize(editableFile.path)
            if (editableFileSizeBytes == 0L) {
                callback.onFailure(Exception("editing Exif yielded an empty file"))
                return false
            }

            val editedMimeType = detectMimeType(context, Uri.fromFile(editableFile), mimeType, editableFileSizeBytes)
            if (editedMimeType != mimeType) {
                throw Exception("editing Exif changes mimeType=$mimeType -> $editedMimeType for uri=$uri path=$path")
            }

            // ensure file is decodable after editing
            ensureDecodable(mimeType, editableFile)

            if (trailerVideoBytes != null) {
                // append trailer video, if any
                editableFile.appendBytes(trailerVideoBytes)
            }

            // copy the edited temporary file back to the original
            editableFile.copyTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(
                    context = context,
                    path = path,
                    uri = uri,
                    mimeType = mimeType,
                    sizeBytes = sizeBytes,
                    trailerOffset = trailerVideoBytes?.size,
                    editedFile = editableFile,
                    callback = callback,
                )
            ) {
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
        sizeBytes: Long,
        callback: ImageOpCallback,
        autoCorrectTrailerOffset: Boolean = true,
        trailerDiff: Int = 0,
        iptc: List<FieldMap>?,
    ): Boolean {
        if (!canEditIptc(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return false
        }

        // prefer provided `sizeBytes` over file attribute, because the file size
        // may be temporary incorrect and not match results from `MediaScannerConnection`
        val originalFileSize = sizeBytes

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
                        copyFrom(ByteArrayInputStream(imageBytes), imageBytes.size.toLong())
                    }
                } else {
                    // copy original file to a temporary file for editing
                    copyFrom(StorageUtils.openInputStream(context, uri), originalFileSize)
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

            if (getFileSize(editableFile.path) == 0L) {
                callback.onFailure(Exception("editing IPTC yielded an empty file"))
                return false
            }

            if (trailerVideoBytes != null) {
                // append trailer video, if any
                editableFile.appendBytes(trailerVideoBytes)
            }

            // copy the edited temporary file back to the original
            editableFile.copyTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(
                    context = context,
                    path = path,
                    uri = uri,
                    mimeType = mimeType,
                    sizeBytes = sizeBytes,
                    trailerOffset = trailerVideoBytes?.size,
                    editedFile = editableFile,
                    callback = callback,
                )
            ) {
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
        sizeBytes: Long,
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

        // prefer provided `sizeBytes` over file attribute, because the file size
        // may be temporary incorrect and not match results from `MediaScannerConnection`
        val originalFileSize = sizeBytes

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

        if (getFileSize(editableFile.path) == 0L) {
            callback.onFailure(Exception("editing XMP yielded an empty file"))
            return false
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.copyTo(outputStream(context, mimeType, uri, path))

            if (autoCorrectTrailerOffset && !checkTrailerOffset(
                    context = context,
                    path = path,
                    uri = uri,
                    mimeType = mimeType,
                    sizeBytes = sizeBytes,
                    trailerOffset = trailerVideoSize,
                    editedFile = editableFile,
                    callback = callback,
                )
            ) {
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
        sizeBytes: Long,
        trailerOffset: Number?,
        editedFile: File,
        callback: ImageOpCallback,
    ): Boolean {
        if (trailerOffset == null) return true

        val expectedLength = getFileSize(editedFile.path)
        val actualLength = getFileSize(path)
        val diff = (actualLength - expectedLength).toInt()
        if (diff == 0) return true

        Log.w(
            LOG_TAG, "Edited file length=$expectedLength does not match final document file length=$actualLength. " +
                    "We need to edit XMP to adjust trailer video offset by $diff bytes."
        )
        val newTrailerOffset = trailerOffset.toLong() + diff
        return editXmp(
            context = context,
            path = path,
            uri = uri,
            mimeType = mimeType,
            sizeBytes = sizeBytes,
            callback = callback,
            trailerDiff = diff,
            editCoreXmp = { xmp ->
                GoogleXMP.updateTrailingVideoOffset(xmp, trailerOffset, newTrailerOffset)
            },
        )
    }

    fun editOrientation(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        sizeBytes: Long,
        op: ExifOrientationOp,
        callback: ImageOpCallback,
    ) {
        val newFields: FieldMap = hashMapOf()

        val success = editExif(context, path, uri, mimeType, sizeBytes, callback) { exif ->
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

    fun editExifDate(
        context: Context,
        path: String,
        uri: Uri,
        mimeType: String,
        sizeBytes: Long,
        dateMillis: Long?,
        shiftSeconds: Long?,
        fields: List<String>,
        callback: ImageOpCallback,
    ) {
        val success = editExif(context, path, uri, mimeType, sizeBytes, callback) { exif ->
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
        sizeBytes: Long,
        modifier: FieldMap,
        autoCorrectTrailerOffset: Boolean,
        callback: ImageOpCallback,
    ) {
        val newFields: FieldMap = hashMapOf()
        if (modifier.containsKey(TYPE_EXIF)) {
            val fieldsToEdit = HashMap<String, Any?>()
            (modifier[TYPE_EXIF] as Map<*, *>?)?.forEach {
                val tag = it.key as String?
                if (tag != null) {
                    fieldsToEdit[tag] = it.value
                }
            }
            if (fieldsToEdit.isNotEmpty()) {
                val modifiedDateTag = ExifInterface.TAG_DATETIME
                if (!fieldsToEdit.containsKey(modifiedDateTag)) {
                    fieldsToEdit[modifiedDateTag] = ExifInterfaceHelper.DATETIME_FORMAT.format(Date())
                }
                if (!editExif(
                        context = context,
                        path = path,
                        uri = uri,
                        mimeType = mimeType,
                        sizeBytes = sizeBytes,
                        callback = callback,
                        autoCorrectTrailerOffset = autoCorrectTrailerOffset,
                    ) { exif ->
                        var setLocation = false
                        fieldsToEdit.forEach { kv ->
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
                            val latAbs = (fieldsToEdit[ExifInterface.TAG_GPS_LATITUDE] as Number?)?.toDouble()
                            val latRef = fieldsToEdit[ExifInterface.TAG_GPS_LATITUDE_REF] as String?
                            val lngAbs = (fieldsToEdit[ExifInterface.TAG_GPS_LONGITUDE] as Number?)?.toDouble()
                            val lngRef = fieldsToEdit[ExifInterface.TAG_GPS_LONGITUDE_REF] as String?
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
                    sizeBytes = sizeBytes,
                    callback = callback,
                    autoCorrectTrailerOffset = autoCorrectTrailerOffset,
                    iptc = iptc,
                )
            ) return
        }

        if (modifier.containsKey(TYPE_MP4)) {
            val fieldsToEdit = modifier[TYPE_MP4] as Map<*, *>?
            if (!fieldsToEdit.isNullOrEmpty()) {
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
                        sizeBytes = sizeBytes,
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
        sizeBytes: Long,
        callback: ImageOpCallback,
    ) {
        // prefer provided `sizeBytes` over file attribute, because the file size
        // may be temporary incorrect and not match results from `MediaScannerConnection`
        val originalFileSize = sizeBytes

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
                // partial copy
                copyFrom(StorageUtils.openInputStream(context, uri), originalFileSize - trailerVideoSize)
            } catch (e: Exception) {
                Log.d(LOG_TAG, "failed to remove trailer video", e)
                callback.onFailure(e)
                return
            }
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.copyTo(outputStream(context, mimeType, uri, path))
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
        sizeBytes: Long,
        types: Set<String>,
        callback: ImageOpCallback,
    ) {
        if (!canRemoveMetadata(mimeType)) {
            callback.onFailure(UnsupportedOperationException("unsupported mimeType=$mimeType"))
            return
        }

        // prefer provided `sizeBytes` over file attribute, because the file size
        // may be temporary incorrect and not match results from `MediaScannerConnection`
        val originalFileSize = sizeBytes

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

        if (getFileSize(editableFile.path) == 0L) {
            callback.onFailure(Exception("removing metadata yielded an empty file"))
            return
        }

        try {
            // copy the edited temporary file back to the original
            editableFile.copyTo(outputStream(context, mimeType, uri, path))

            if (!types.contains(TYPE_XMP) && isTrailerVideoValid && !checkTrailerOffset(
                    context = context,
                    path = path,
                    uri = uri,
                    mimeType = mimeType,
                    sizeBytes = sizeBytes,
                    trailerOffset = trailerVideoSize,
                    editedFile = editableFile,
                    callback = callback,
                )
            ) {
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
        return if (MediaStorePermissions.canEdit(context, uri, mimeType)) {
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

        fun contentExists(context: Context, uri: Uri): Boolean {
            if (!uri.isContentScheme) return false

            var found = false
            val projection = arrayOf(BaseColumns._ID)
            try {
                val cursor = context.contentResolver.query(uri, projection, null, null, null)
                if (cursor != null) {
                    while (cursor.moveToNext()) {
                        found = true
                    }
                    cursor.close()
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to query content at uri=$uri", e)
            }
            return found
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
