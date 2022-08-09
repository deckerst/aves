package deckers.thibault.aves.model.provider

import android.annotation.SuppressLint
import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.*
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.MainActivity.Companion.DELETE_SINGLE_PERMISSION_REQUEST
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.NameConflictStrategy
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.StorageUtils.PathSegments
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import deckers.thibault.aves.utils.StorageUtils.removeTrailingSeparator
import deckers.thibault.aves.utils.UriUtils.tryParseId
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import java.io.File
import java.io.OutputStream
import java.util.*
import java.util.concurrent.CompletableFuture
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class MediaStoreImageProvider : ImageProvider() {
    fun fetchAll(
        context: Context,
        knownEntries: Map<Int?, Int?>,
        directory: String?,
        handleNewEntry: NewEntryHandler,
    ) {
        val isModified = fun(contentId: Int, dateModifiedSecs: Int): Boolean {
            val knownDate = knownEntries[contentId]
            return knownDate == null || knownDate < dateModifiedSecs
        }
        val handleNew: NewEntryHandler
        var selection: String? = null
        var selectionArgs: Array<String>? = null
        if (directory != null) {
            val relativePathDirectory = ensureTrailingSeparator(directory)
            val relativePath = PathSegments(context, relativePathDirectory).relativeDir
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && relativePath != null) {
                selection = "${MediaStore.MediaColumns.RELATIVE_PATH} = ? AND ${MediaColumns.PATH} LIKE ?"
                selectionArgs = arrayOf(relativePath, "relativePathDirectory%")
            } else {
                selection = "${MediaColumns.PATH} LIKE ?"
                selectionArgs = arrayOf("$relativePathDirectory%")
            }

            val parentCheckDirectory = removeTrailingSeparator(directory)
            handleNew = { entry ->
                // skip entries in subfolders
                val path = entry["path"] as String?
                if (path != null && File(path).parent == parentCheckDirectory) {
                    handleNewEntry(entry)
                }
            }
        } else {
            handleNew = handleNewEntry
        }
        fetchFrom(context, isModified, handleNew, IMAGE_CONTENT_URI, IMAGE_PROJECTION, selection, selectionArgs)
        fetchFrom(context, isModified, handleNew, VIDEO_CONTENT_URI, VIDEO_PROJECTION, selection, selectionArgs)
    }

    // the provided URI can point to the wrong media collection,
    // e.g. a GIF image with the URI `content://media/external/video/media/[ID]`
    // so the effective entry URI may not match the provided URI
    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, callback: ImageOpCallback) {
        var found = false
        val fetched = arrayListOf<FieldMap>()
        val id = uri.tryParseId()
        val alwaysValid: NewEntryChecker = fun(_: Int, _: Int): Boolean = true
        val onSuccess: NewEntryHandler = fun(entry: FieldMap) { fetched.add(entry) }
        if (id != null) {
            if (!found && (sourceMimeType == null || isImage(sourceMimeType))) {
                val contentUri = ContentUris.withAppendedId(IMAGE_CONTENT_URI, id)
                found = fetchFrom(context, alwaysValid, onSuccess, contentUri, IMAGE_PROJECTION)
            }
            if (!found && (sourceMimeType == null || isVideo(sourceMimeType))) {
                val contentUri = ContentUris.withAppendedId(VIDEO_CONTENT_URI, id)
                found = fetchFrom(context, alwaysValid, onSuccess, contentUri, VIDEO_PROJECTION)
            }
        }
        if (!found) {
            // the uri can be a file media URI (e.g. "content://0@media/external/file/30050")
            // without an equivalent image/video if it is shared from a file browser
            // but the file is not publicly visible
            found = fetchFrom(context, alwaysValid, onSuccess, uri, BASE_PROJECTION, fileMimeType = sourceMimeType)
        }

        if (found && fetched.isNotEmpty()) {
            if (fetched.size == 1) {
                callback.onSuccess(fetched.first())
            } else {
                callback.onFailure(Exception("found ${fetched.size} entries at uri=$uri"))
            }
        } else {
            callback.onFailure(Exception("failed to fetch entry at uri=$uri"))
        }
    }

    fun checkObsoleteContentIds(context: Context, knownContentIds: List<Int?>): List<Int> {
        val foundContentIds = HashSet<Int>()
        fun check(context: Context, contentUri: Uri) {
            val projection = arrayOf(MediaStore.MediaColumns._ID)
            try {
                val cursor = context.contentResolver.query(contentUri, projection, null, null, null)
                if (cursor != null) {
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                    while (cursor.moveToNext()) {
                        foundContentIds.add(cursor.getInt(idColumn))
                    }
                    cursor.close()
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to get content IDs for contentUri=$contentUri", e)
            }
        }
        check(context, IMAGE_CONTENT_URI)
        check(context, VIDEO_CONTENT_URI)
        return knownContentIds.subtract(foundContentIds).filterNotNull().toList()
    }

    fun checkObsoletePaths(context: Context, knownPathById: Map<Int?, String?>): List<Int> {
        val obsoleteIds = ArrayList<Int>()
        fun check(context: Context, contentUri: Uri) {
            val projection = arrayOf(MediaStore.MediaColumns._ID, MediaColumns.PATH)
            try {
                val cursor = context.contentResolver.query(contentUri, projection, null, null, null)
                if (cursor != null) {
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                    val pathColumn = cursor.getColumnIndexOrThrow(MediaColumns.PATH)
                    while (cursor.moveToNext()) {
                        val id = cursor.getInt(idColumn)
                        val path = cursor.getString(pathColumn)
                        if (knownPathById.containsKey(id) && knownPathById[id] != path) {
                            obsoleteIds.add(id)
                        }
                    }
                    cursor.close()
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to get content IDs for contentUri=$contentUri", e)
            }
        }
        check(context, IMAGE_CONTENT_URI)
        check(context, VIDEO_CONTENT_URI)
        return obsoleteIds
    }

    private fun fetchFrom(
        context: Context,
        isValidEntry: NewEntryChecker,
        handleNewEntry: NewEntryHandler,
        contentUri: Uri,
        projection: Array<String>,
        selection: String? = null,
        selectionArgs: Array<String>? = null,
        fileMimeType: String? = null,
    ): Boolean {
        var found = false
        val orderBy = "${MediaStore.MediaColumns.DATE_MODIFIED} DESC"
        try {
            val cursor = context.contentResolver.query(contentUri, projection, selection, selectionArgs, orderBy)
            if (cursor != null) {
                val contentUriContainsId = when (contentUri) {
                    IMAGE_CONTENT_URI, VIDEO_CONTENT_URI -> false
                    else -> true
                }

                // image & video
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                val pathColumn = cursor.getColumnIndexOrThrow(MediaColumns.PATH)
                val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE)
                val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)
                val widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH)
                val heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT)
                val dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
                val dateTakenColumn = cursor.getColumnIndex(MediaColumns.DATE_TAKEN)

                // image & video for API >=29, only for images for API <29
                val orientationColumn = cursor.getColumnIndex(MediaColumns.ORIENTATION)

                // video only
                val durationColumn = cursor.getColumnIndex(MediaColumns.DURATION)
                val needDuration = projection.contentEquals(VIDEO_PROJECTION)

                while (cursor.moveToNext()) {
                    val contentId = cursor.getInt(idColumn)
                    val dateModifiedSecs = cursor.getInt(dateModifiedColumn)
                    if (isValidEntry(contentId, dateModifiedSecs)) {
                        // for multiple items, `contentUri` is the root without ID,
                        // but for single items, `contentUri` already contains the ID
                        val itemUri = if (contentUriContainsId) contentUri else ContentUris.withAppendedId(contentUri, contentId.toLong())
                        // `mimeType` can be registered as null for file media URIs with unsupported media types (e.g. TIFF on old devices)
                        // in that case we try to use the MIME type provided along the URI
                        val mimeType: String? = cursor.getString(mimeTypeColumn) ?: fileMimeType
                        val width = cursor.getInt(widthColumn)
                        val height = cursor.getInt(heightColumn)
                        val durationMillis = if (durationColumn != -1) cursor.getLong(durationColumn) else 0L

                        if (mimeType == null) {
                            Log.w(LOG_TAG, "failed to make entry from uri=$itemUri because of null MIME type")
                        } else {
                            var entryMap: FieldMap = hashMapOf(
                                "uri" to itemUri.toString(),
                                "path" to cursor.getString(pathColumn),
                                "sourceMimeType" to mimeType,
                                "width" to width,
                                "height" to height,
                                "sourceRotationDegrees" to if (orientationColumn != -1) cursor.getInt(orientationColumn) else 0,
                                "sizeBytes" to cursor.getLong(sizeColumn),
                                "dateModifiedSecs" to dateModifiedSecs,
                                "sourceDateTakenMillis" to if (dateTakenColumn != -1) cursor.getLong(dateTakenColumn) else null,
                                "durationMillis" to durationMillis,
                                // only for map export
                                "contentId" to contentId,
                            )

                            if (MimeTypes.isRaw(mimeType)
                                || (width <= 0 || height <= 0) && needSize(mimeType)
                                || durationMillis == 0L && needDuration
                            ) {
                                // Some images are incorrectly registered in the Media Store,
                                // missing some attributes such as width, height, orientation.
                                // Also, the reported size of raw images is inconsistent across devices
                                // and Android versions (sometimes the raw size, sometimes the decoded size).
                                val entry = SourceEntry(entryMap).fillPreCatalogMetadata(context)
                                entryMap = entry.toMap()
                            }

                            handleNewEntry(entryMap)
                            found = true
                        }
                    }
                }
                cursor.close()
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to get entries", e)
        }
        return found
    }

    private fun hasEntry(context: Context, contentUri: Uri): Boolean {
        var found = false
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        try {
            val cursor = context.contentResolver.query(contentUri, projection, null, null, null)
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    found = true
                }
                cursor.close()
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to get entry at contentUri=$contentUri", e)
        }
        return found
    }

    private fun needSize(mimeType: String) = MimeTypes.SVG != mimeType

    // `uri` is a media URI, not a document URI
    override suspend fun delete(contextWrapper: ContextWrapper, uri: Uri, path: String?, mimeType: String) {
        path ?: throw Exception("failed to delete file because path is null")

        // the following situations are possible:
        // - there is an entry in the Media Store and there is a file on storage
        // - there is an entry in the Media Store but there is no longer a file on storage
        // - there is no entry in the Media Store but there is a file on storage
        val file = File(path)
        val fileExists = file.exists()

        if (fileExists) {
            if (StorageUtils.canEditByFile(contextWrapper, path)) {
                if (hasEntry(contextWrapper, uri)) {
                    Log.d(LOG_TAG, "delete [permission:file, file exists, content exists] content at uri=$uri path=$path")
                    contextWrapper.contentResolver.delete(uri, null, null)
                }
                // in theory, deleting via content resolver should remove the file on storage
                // in practice, the file may still be there afterwards
                if (file.exists()) {
                    Log.d(LOG_TAG, "delete [permission:file, file exists after content delete] file at uri=$uri path=$path")
                    if (file.delete()) {
                        // in theory, scanning an obsolete path should remove the entry from the Media Store
                        // in practice, the entry may still be there afterwards
                        scanObsoletePath(contextWrapper, uri, path, mimeType)
                        return
                    }
                } else {
                    return
                }
            } else if (!isMediaUriPermissionGranted(contextWrapper, uri, mimeType)
                && StorageUtils.requireAccessPermission(contextWrapper, path)
            ) {
                // the delete request may yield a `RecoverableSecurityException` when using scoped storage,
                // even if we have permissions on the tree document via SAF
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q && hasEntry(contextWrapper, uri)) {
                    Log.d(LOG_TAG, "delete [permission:doc, file exists, content exists] content at uri=$uri path=$path")
                    contextWrapper.contentResolver.delete(uri, null, null)
                }

                // in theory, deleting via content resolver should remove the file on storage
                // in practice, the file may still be there afterwards
                if (file.exists()) {
                    Log.d(LOG_TAG, "delete [permission:doc, file exists after content delete] document at uri=$uri path=$path")
                    val df = StorageUtils.getDocumentFile(contextWrapper, path, uri)

                    @Suppress("BlockingMethodInNonBlockingContext")
                    if (df != null && df.delete()) {
                        scanObsoletePath(contextWrapper, uri, path, mimeType)
                        return
                    }
                    throw Exception("failed to delete document with df=$df")
                } else {
                    return
                }
            }
        } else if (uri.scheme?.lowercase(Locale.ROOT) == ContentResolver.SCHEME_FILE) {
            val uriFilePath = File(uri.path!!).path
            // URI and path both point to the same non existent path
            if (uriFilePath == path) return
        }

        try {
            Log.d(LOG_TAG, "delete [file exists=$fileExists] content at uri=$uri path=$path")
            if (contextWrapper.contentResolver.delete(uri, null, null) > 0) return

            if (hasEntry(contextWrapper, uri) || file.exists()) {
                throw Exception("failed to delete row from content provider")
            }
        } catch (securityException: SecurityException) {
            // even if the app has access permission granted on the containing directory,
            // the delete request may yield a `RecoverableSecurityException` on Android >=10
            // when the underlying file no longer exists and this is an orphaned entry in the Media Store
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && contextWrapper is Activity) {
                Log.w(LOG_TAG, "caught a security exception when attempting to delete uri=$uri", securityException)
                val rse = securityException as? RecoverableSecurityException ?: throw securityException
                val intentSender = rse.userAction.actionIntent.intentSender

                // request user permission for this item
                MainActivity.pendingScopedStoragePermissionCompleter = CompletableFuture<Boolean>()
                contextWrapper.startIntentSenderForResult(intentSender, DELETE_SINGLE_PERMISSION_REQUEST, null, 0, 0, 0, null)
                val granted = MainActivity.pendingScopedStoragePermissionCompleter!!.join()

                MainActivity.pendingScopedStoragePermissionCompleter = null
                if (granted) {
                    delete(contextWrapper, uri, path, mimeType)
                } else {
                    throw Exception("failed to get delete permission")
                }
            } else {
                throw securityException
            }
        }
    }

    override suspend fun moveMultiple(
        activity: Activity,
        copy: Boolean,
        nameConflictStrategy: NameConflictStrategy,
        entriesByTargetDir: Map<String, List<AvesEntry>>,
        isCancelledOp: CancelCheck,
        callback: ImageOpCallback,
    ) {
        entriesByTargetDir.forEach { kv ->
            val targetDir = kv.key
            val entries = kv.value

            val toBin = targetDir == StorageUtils.TRASH_PATH_PLACEHOLDER

            var effectiveTargetDir: String? = null
            var targetDirDocFile: DocumentFileCompat? = null
            if (!toBin) {
                effectiveTargetDir = targetDir
                targetDirDocFile = StorageUtils.createDirectoryDocIfAbsent(activity, targetDir)
                if (!File(targetDir).exists()) {
                    callback.onFailure(Exception("failed to create directory at path=$targetDir"))
                    return
                }
            }

            for (entry in entries) {
                val mimeType = entry.mimeType
                val trashed = entry.trashed

                val sourceUri = entry.uri
                val sourcePath = if (trashed) entry.trashPath else entry.path

                var desiredName: String? = null
                if (trashed) {
                    entry.path?.let { desiredName = File(it).name }
                }

                val result: FieldMap = hashMapOf(
                    "uri" to sourceUri.toString(),
                    "success" to false,
                )

                if (sourcePath != null) {
                    // on API 30 we cannot get access granted directly to a volume root from its document tree,
                    // but it is still less constraining to use tree document files than to rely on the Media Store
                    //
                    // Relying on `DocumentFile`, we can create an item via `DocumentFile.createFile()`, but:
                    // - we need to scan the file to get the Media Store content URI
                    // - the underlying document provider controls the new file name
                    //
                    // Relying on the Media Store, we can create an item via `ContentResolver.insert()`
                    // with a path, and retrieve its content URI, but:
                    // - the Media Store isolates content by storage volume (e.g. `MediaStore.Images.Media.getContentUri(volumeName)`)
                    // - the volume name should be lower case, not exactly as the `StorageVolume` UUID
                    //   cf new method in API 30 `StorageVolume.getMediaStoreVolumeName()`
                    // - inserting on a removable volume works on API 29, but not on API 25 nor 26 (on which API/devices does it work?)
                    // - there is no documentation regarding support for usage with removable storage
                    // - the Media Store only allows inserting in specific primary directories ("DCIM", "Pictures") when using scoped storage
                    try {
                        if (toBin) {
                            val trashDir = StorageUtils.trashDirFor(activity, sourcePath)
                            if (trashDir != null) {
                                effectiveTargetDir = ensureTrailingSeparator(trashDir.path)
                                targetDirDocFile = DocumentFileCompat.fromFile(trashDir)
                            }
                        }
                        if (effectiveTargetDir != null) {
                            val newFields = if (isCancelledOp()) skippedFieldMap else {
                                val sourceFile = File(sourcePath)
                                if (!sourceFile.exists() && toBin) {
                                    delete(activity, sourceUri, sourcePath, mimeType = mimeType)
                                    deletedFieldMap
                                } else {
                                    moveSingle(
                                        activity = activity,
                                        sourceFile = sourceFile,
                                        sourceUri = sourceUri,
                                        targetDir = effectiveTargetDir,
                                        targetDirDocFile = targetDirDocFile,
                                        desiredName = desiredName ?: sourceFile.name,
                                        nameConflictStrategy = nameConflictStrategy,
                                        mimeType = mimeType,
                                        copy = copy,
                                        toBin = toBin,
                                    )
                                }
                            }
                            result["newFields"] = newFields
                            result["success"] = true
                        }
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to move to targetDir=$targetDir entry with sourcePath=$sourcePath", e)
                    }
                }
                callback.onSuccess(result)
            }
        }
    }

    private suspend fun moveSingle(
        activity: Activity,
        sourceFile: File,
        sourceUri: Uri,
        targetDir: String,
        targetDirDocFile: DocumentFileCompat?,
        desiredName: String,
        nameConflictStrategy: NameConflictStrategy,
        mimeType: String,
        copy: Boolean,
        toBin: Boolean,
    ): FieldMap {
        val sourcePath = sourceFile.path
        val sourceDir = sourceFile.parent?.let { ensureTrailingSeparator(it) }
        if (sourceDir == targetDir && !(copy && nameConflictStrategy == NameConflictStrategy.RENAME)) {
            // nothing to do unless it's a renamed copy
            return skippedFieldMap
        }

        val desiredNameWithoutExtension = desiredName.substringBeforeLast(".")
        val targetNameWithoutExtension = resolveTargetFileNameWithoutExtension(
            contextWrapper = activity,
            dir = targetDir,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            mimeType = mimeType,
            conflictStrategy = nameConflictStrategy,
        ) ?: return skippedFieldMap

        val sourceDocFile = DocumentFileCompat.fromSingleUri(activity, sourceUri)
        val targetPath = createSingle(
            activity = activity,
            mimeType = mimeType,
            targetDir = targetDir,
            targetDirDocFile = targetDirDocFile,
            targetNameWithoutExtension = targetNameWithoutExtension,
        ) { output: OutputStream -> sourceDocFile.copyTo(output) }

        if (!copy) {
            // delete original entry
            try {
                delete(activity, sourceUri, sourcePath, mimeType)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
            }
        }
        if (toBin) {
            return hashMapOf(
                "trashed" to true,
                "trashPath" to targetPath,
            )
        }
        return scanNewPath(activity, targetPath, mimeType)
    }

    // `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
    // `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
    // when used with entry URI as `sourceDocumentUri`, and targetDirDocFile URI as `targetParentDocumentUri`
    fun createSingle(
        activity: Activity,
        mimeType: String,
        targetDir: String,
        targetDirDocFile: DocumentFileCompat?,
        targetNameWithoutExtension: String,
        write: (OutputStream) -> Unit,
    ): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && isDownloadDir(activity, targetDir)) {
            val targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType)}"
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, targetFileName)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = activity.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)

            uri?.let {
                resolver.openOutputStream(uri)?.use(write)
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } ?: throw Exception("MediaStore failed for some reason")

            File(targetDir, targetFileName).path
        } else {
            targetDirDocFile ?: throw Exception("failed to get tree doc for directory at path=$targetDir")

            // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
            // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
            // through a document URI, not a tree URI
            // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
            val targetTreeFile = targetDirDocFile.createFile(mimeType, targetNameWithoutExtension)
            val targetDocFile = DocumentFileCompat.fromSingleUri(activity, targetTreeFile.uri)

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
            targetDir + fileName
        }
    }

    private fun isDownloadDir(context: Context, dirPath: String): Boolean {
        val relativeDir = removeTrailingSeparator(PathSegments(context, dirPath).relativeDir ?: "")
        return relativeDir == Environment.DIRECTORY_DOWNLOADS
    }

    override suspend fun renameMultiple(
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
                    val newFields = if (isCancelledOp()) skippedFieldMap else renameSingle(
                        activity = activity,
                        mimeType = mimeType,
                        oldMediaUri = sourceUri,
                        oldPath = sourcePath,
                        desiredName = desiredName,
                    )
                    result["newFields"] = newFields
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to rename to newFileName=$desiredName entry with sourcePath=$sourcePath", e)
                }
            }
            callback.onSuccess(result)
        }
    }

    private suspend fun renameSingle(
        activity: Activity,
        mimeType: String,
        oldMediaUri: Uri,
        oldPath: String,
        desiredName: String,
    ): FieldMap {
        val desiredNameWithoutExtension = desiredName.substringBeforeLast(".")

        val oldFile = File(oldPath)
        if (oldFile.nameWithoutExtension == desiredNameWithoutExtension) return skippedFieldMap

        val dir = oldFile.parent ?: return skippedFieldMap
        val targetNameWithoutExtension = resolveTargetFileNameWithoutExtension(
            contextWrapper = activity,
            dir = dir,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            mimeType = mimeType,
            conflictStrategy = NameConflictStrategy.RENAME,
        ) ?: return skippedFieldMap
        val targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType)}"

        val newFile = File(dir, targetFileName)
        return when {
            oldFile == newFile -> skippedFieldMap
            StorageUtils.canEditByFile(activity, oldPath) -> renameSingleByFile(activity, mimeType, oldMediaUri, oldPath, newFile)
            isMediaUriPermissionGranted(activity, oldMediaUri, mimeType) -> renameSingleByMediaStore(activity, mimeType, oldMediaUri, newFile)
            else -> renameSingleByTreeDoc(activity, mimeType, oldMediaUri, oldPath, newFile)
        }
    }

    private suspend fun renameSingleByMediaStore(
        activity: Activity,
        mimeType: String,
        mediaUri: Uri,
        newFile: File
    ): FieldMap {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw Exception("unsupported Android version")
        }

        Log.d(LOG_TAG, "rename content at uri=$mediaUri")
        val uri = StorageUtils.getMediaStoreScopedStorageSafeUri(mediaUri, mimeType)

        // `IS_PENDING` is necessary for `TITLE`, not for `DISPLAY_NAME`
        val tempValues = ContentValues().apply {
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        if (activity.contentResolver.update(uri, tempValues, null, null) == 0) {
            throw Exception("failed to update fields for uri=$uri")
        }

        val finalValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, newFile.name)
            // scanning the new file will not automatically update `TITLE`
            put(MediaStore.MediaColumns.TITLE, newFile.nameWithoutExtension)
            put(MediaStore.MediaColumns.IS_PENDING, 0)
        }
        if (activity.contentResolver.update(uri, finalValues, null, null) == 0) {
            throw Exception("failed to update fields for uri=$uri")
        }

        // URI should not change
        return scanNewPath(activity, newFile.path, mimeType)
    }

    private suspend fun renameSingleByTreeDoc(
        activity: Activity,
        mimeType: String,
        oldMediaUri: Uri,
        oldPath: String,
        newFile: File
    ): FieldMap {
        Log.d(LOG_TAG, "rename document at uri=$oldMediaUri path=$oldPath")
        val df = StorageUtils.getDocumentFile(activity, oldPath, oldMediaUri)
        df ?: throw Exception("failed to get document at path=$oldPath")

        @Suppress("BlockingMethodInNonBlockingContext")
        val renamed = df.renameTo(newFile.name)
        if (!renamed) {
            throw Exception("failed to rename document at path=$oldPath")
        }
        scanObsoletePath(activity, oldMediaUri, oldPath, mimeType)
        return scanNewPath(activity, newFile.path, mimeType)
    }

    private suspend fun renameSingleByFile(
        activity: Activity,
        mimeType: String,
        oldMediaUri: Uri,
        oldPath: String,
        newFile: File
    ): FieldMap {
        Log.d(LOG_TAG, "rename file at path=$oldPath")
        val renamed = File(oldPath).renameTo(newFile)
        if (!renamed) {
            throw Exception("failed to rename file at path=$oldPath")
        }
        scanObsoletePath(activity, oldMediaUri, oldPath, mimeType)
        return scanNewPath(activity, newFile.path, mimeType)
    }

    override fun scanPostMetadataEdit(context: Context, path: String, uri: Uri, mimeType: String, newFields: HashMap<String, Any?>, callback: ImageOpCallback) {
        MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, _ ->
            val projection = arrayOf(
                MediaStore.MediaColumns.DATE_MODIFIED,
                MediaStore.MediaColumns.SIZE,
            )
            try {
                val cursor = context.contentResolver.query(uri, projection, null, null, null)
                if (cursor != null && cursor.moveToFirst()) {
                    cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields["dateModifiedSecs"] = cursor.getInt(it) }
                    cursor.getColumnIndex(MediaStore.MediaColumns.SIZE).let { if (it != -1) newFields["sizeBytes"] = cursor.getLong(it) }
                    cursor.close()
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return@scanFile
            }
            callback.onSuccess(newFields)
        }
    }

    private fun scanObsoletePath(context: Context, uri: Uri, path: String, mimeType: String) {
        val file = File(path)
        val delayMillis = 500L
        val maxDelayMillis = 10000L
        var totalDelayMillis = 0L
        while (file.exists()) {
            if (!hasEntry(context, uri)) return
            if (totalDelayMillis < maxDelayMillis) {
                Log.d(LOG_TAG, "Trying to scan obsolete path but file exists at path=$path. Will retry in $delayMillis ms (total: $totalDelayMillis ms)")
                runBlocking { delay(delayMillis) }
                totalDelayMillis += delayMillis
            } else {
                throw Exception("Timeout ($maxDelayMillis ms) to clear MediaStore entry for file at path=$path")
            }
        }

        if (hasEntry(context, uri)) {
            MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, newUri: Uri? ->
                if (newUri != null && hasEntry(context, newUri)) {
                    Log.w(LOG_TAG, "Failed to clear Media Store entry at uri=$newUri path=$path")
                } else {
                    Log.w(LOG_TAG, "Cleared Media Store entry at uri=$newUri path=$path")
                }
            }
        }
    }

    suspend fun scanNewPath(context: Context, path: String, mimeType: String): FieldMap =
        suspendCoroutine { cont ->
            MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, newUri: Uri? ->
                fun scanUri(uri: Uri?): FieldMap? {
                    uri ?: return null

                    // we retrieve updated fields as the renamed/moved file became a new entry in the Media Store
                    val projection = arrayOf(
                        MediaStore.MediaColumns.DATE_MODIFIED,
                    )
                    try {
                        val cursor = context.contentResolver.query(uri, projection, null, null, null)
                        if (cursor != null && cursor.moveToFirst()) {
                            val newFields = HashMap<String, Any?>()
                            newFields["uri"] = uri.toString()
                            newFields["contentId"] = uri.tryParseId()
                            newFields["path"] = path
                            cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields["dateModifiedSecs"] = cursor.getInt(it) }
                            cursor.close()
                            return newFields
                        }
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to scan uri=$uri", e)
                    }
                    return null
                }

                if (newUri != null) {
                    var contentUri: Uri? = null
                    // `newURI` is possibly a file media URI (e.g. "content://media/12a9-8b42/file/62872")
                    // but we need an image/video media URI (e.g. "content://media/external/images/media/62872")
                    val contentId = newUri.tryParseId()
                    if (contentId != null) {
                        if (isImage(mimeType)) {
                            contentUri = ContentUris.withAppendedId(IMAGE_CONTENT_URI, contentId)
                        } else if (isVideo(mimeType)) {
                            contentUri = ContentUris.withAppendedId(VIDEO_CONTENT_URI, contentId)
                        }
                    }

                    // prefer image/video content URI, fallback to original URI (possibly a file content URI)
                    val newFields = scanUri(contentUri) ?: scanUri(newUri)

                    if (newFields != null) {
                        cont.resume(newFields)
                    } else {
                        cont.resumeWithException(Exception("failed to get item details from provider at contentUri=$contentUri (from newUri=$newUri)"))
                    }
                } else {
                    cont.resumeWithException(Exception("failed to get URI of item at path=$path"))
                }
            }
        }

    fun getContentUriForPath(context: Context, path: String): Uri? {
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        val selection = "${MediaColumns.PATH} = ?"
        val selectionArgs = arrayOf(path)

        fun check(context: Context, contentUri: Uri): Uri? {
            var mediaContentUri: Uri? = null
            try {
                val cursor = context.contentResolver.query(contentUri, projection, selection, selectionArgs, null)
                if (cursor != null && cursor.moveToFirst()) {
                    cursor.getColumnIndex(MediaStore.MediaColumns._ID).let {
                        if (it != -1) mediaContentUri = ContentUris.withAppendedId(contentUri, cursor.getLong(it))
                    }
                    cursor.close()
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to get URI for contentUri=$contentUri path=$path", e)
            }
            return mediaContentUri
        }
        return check(context, IMAGE_CONTENT_URI) ?: check(context, VIDEO_CONTENT_URI)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaStoreImageProvider>()

        private val IMAGE_CONTENT_URI = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        private val VIDEO_CONTENT_URI = MediaStore.Video.Media.EXTERNAL_CONTENT_URI

        private val BASE_PROJECTION = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaColumns.PATH,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.DATE_MODIFIED,
            MediaColumns.DATE_TAKEN,
        )

        private val IMAGE_PROJECTION = arrayOf(
            *BASE_PROJECTION,
            MediaColumns.ORIENTATION,
        )

        private val VIDEO_PROJECTION = arrayOf(
            *BASE_PROJECTION,
            MediaColumns.DURATION,
            // `ORIENTATION` was only available for images before Android 10
            *if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) arrayOf(
                MediaStore.MediaColumns.ORIENTATION,
            ) else emptyArray()
        )
    }
}

object MediaColumns {
    // `DATE_TAKEN`, `ORIENTATION`, `DURATION` used to be in `MediaStore.[Images,Video].Media`
    // but were moved to `MediaStore.MediaColumns` for API 29
    // it is safe to use them because they are static strings that have not changed

    @SuppressLint("InlinedApi")
    const val DATE_TAKEN = MediaStore.MediaColumns.DATE_TAKEN

    @SuppressLint("InlinedApi")
    const val ORIENTATION = MediaStore.MediaColumns.ORIENTATION

    @SuppressLint("InlinedApi")
    const val DURATION = MediaStore.MediaColumns.DURATION

    @Suppress("deprecation")
    const val PATH = MediaStore.MediaColumns.DATA
}

typealias NewEntryHandler = (entry: FieldMap) -> Unit

private typealias NewEntryChecker = (contentId: Int, dateModifiedSecs: Int) -> Boolean