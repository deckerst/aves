package deckers.thibault.aves.model.provider

import android.annotation.SuppressLint
import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi
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
import deckers.thibault.aves.utils.UriUtils.tryParseId
import java.io.File
import java.util.*
import java.util.concurrent.CompletableFuture
import kotlin.collections.ArrayList
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class MediaStoreImageProvider : ImageProvider() {
    fun fetchAll(context: Context, knownEntries: Map<Int, Int?>, handleNewEntry: NewEntryHandler) {
        val isModified = fun(contentId: Int, dateModifiedSecs: Int): Boolean {
            val knownDate = knownEntries[contentId]
            return knownDate == null || knownDate < dateModifiedSecs
        }
        fetchFrom(context, isModified, handleNewEntry, IMAGE_CONTENT_URI, IMAGE_PROJECTION)
        fetchFrom(context, isModified, handleNewEntry, VIDEO_CONTENT_URI, VIDEO_PROJECTION)
    }

    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, callback: ImageOpCallback) {
        var found = false
        val fetched = arrayListOf<FieldMap>()
        val id = uri.tryParseId()
        val onSuccess = fun(entry: FieldMap) {
            entry["uri"] = uri.toString()
            fetched.add(entry)
        }
        val alwaysValid = { _: Int, _: Int -> true }
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

    fun checkObsoleteContentIds(context: Context, knownContentIds: List<Int>): List<Int> {
        val foundContentIds = ArrayList<Int>()
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
        return knownContentIds.subtract(foundContentIds).toList()
    }

    fun checkObsoletePaths(context: Context, knownPathById: Map<Int, String>): List<Int> {
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
        fileMimeType: String? = null,
    ): Boolean {
        var found = false
        val orderBy = "${MediaStore.MediaColumns.DATE_MODIFIED} DESC"
        try {
            val cursor = context.contentResolver.query(contentUri, projection, null, null, orderBy)
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
                val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE)
                val widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH)
                val heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT)
                val dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
                val dateTakenColumn = cursor.getColumnIndex(MediaColumns.DATE_TAKEN)

                // image & video for API >= Q, only for images for API < Q
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
                        // in that case we try to use the mime type provided along the URI
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
                                "title" to cursor.getString(titleColumn),
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
    override suspend fun delete(activity: Activity, uri: Uri, path: String?, mimeType: String) {
        if (!(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
                    && isMediaUriPermissionGranted(activity, uri, mimeType))
        ) {
            // if the file is on SD card, calling the content resolver `delete()`
            // removes the entry from the Media Store but it doesn't delete the file,
            // even when the app has the permission, so we manually delete the document file
            path ?: throw Exception("failed to delete file because path is null")
            if (File(path).exists() && StorageUtils.requireAccessPermission(activity, path)) {
                Log.d(LOG_TAG, "delete document at uri=$uri path=$path")
                val df = StorageUtils.getDocumentFile(activity, path, uri)

                @Suppress("BlockingMethodInNonBlockingContext")
                if (df != null && df.delete()) return
                throw Exception("failed to delete file with df=$df")
            }
        }

        try {
            Log.d(LOG_TAG, "delete content at uri=$uri")
            if (activity.contentResolver.delete(uri, null, null) > 0) return
        } catch (securityException: SecurityException) {
            // even if the app has access permission granted on the containing directory,
            // the delete request may yield a `RecoverableSecurityException` on Android 10+
            // when the underlying file no longer exists and this is an orphaned entry in the Media Store
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                Log.w(LOG_TAG, "caught a security exception when attempting to delete uri=$uri", securityException)
                val rse = securityException as? RecoverableSecurityException ?: throw securityException
                val intentSender = rse.userAction.actionIntent.intentSender

                // request user permission for this item
                MainActivity.pendingScopedStoragePermissionCompleter = CompletableFuture<Boolean>()
                activity.startIntentSenderForResult(intentSender, DELETE_SINGLE_PERMISSION_REQUEST, null, 0, 0, 0, null)
                val granted = MainActivity.pendingScopedStoragePermissionCompleter!!.join()

                MainActivity.pendingScopedStoragePermissionCompleter = null
                if (granted) {
                    delete(activity, uri, path, mimeType)
                } else {
                    throw Exception("failed to get delete permission")
                }
            } else {
                throw securityException
            }
        }
        throw Exception("failed to delete row from content provider")
    }

    override suspend fun moveMultiple(
        activity: Activity,
        copy: Boolean,
        targetDir: String,
        nameConflictStrategy: NameConflictStrategy,
        entries: List<AvesEntry>,
        callback: ImageOpCallback,
    ) {
        val targetDirDocFile = StorageUtils.createDirectoryDocIfAbsent(activity, targetDir)
        if (!File(targetDir).exists()) {
            callback.onFailure(Exception("failed to create directory at path=$targetDir"))
            return
        }

        for (entry in entries) {
            val sourceUri = entry.uri
            val sourcePath = entry.path
            val mimeType = entry.mimeType

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
                // - inserting on a removable volume works on API 29, but not on API 25 nor 26 (on which API/devices does it work?)
                // - there is no documentation regarding support for usage with removable storage
                // - the Media Store only allows inserting in specific primary directories ("DCIM", "Pictures") when using scoped storage
                try {
                    val newFields = moveSingle(
                        activity = activity,
                        sourcePath = sourcePath,
                        sourceUri = sourceUri,
                        targetDir = targetDir,
                        targetDirDocFile = targetDirDocFile,
                        nameConflictStrategy = nameConflictStrategy,
                        mimeType = mimeType,
                        copy = copy,
                    )
                    result["newFields"] = newFields
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to move to targetDir=$targetDir entry with sourcePath=$sourcePath", e)
                }
            }
            callback.onSuccess(result)
        }
    }

    private suspend fun moveSingle(
        activity: Activity,
        sourcePath: String,
        sourceUri: Uri,
        targetDir: String,
        targetDirDocFile: DocumentFileCompat?,
        nameConflictStrategy: NameConflictStrategy,
        mimeType: String,
        copy: Boolean,
    ): FieldMap {
        val sourceFile = File(sourcePath)
        val sourceDir = sourceFile.parent?.let { StorageUtils.ensureTrailingSeparator(it) }
        if (sourceDir == targetDir && !(copy && nameConflictStrategy == NameConflictStrategy.RENAME)) {
            // nothing to do unless it's a renamed copy
            return skippedFieldMap
        }

        val sourceFileName = sourceFile.name
        val desiredNameWithoutExtension = sourceFileName.replaceFirst(FILE_EXTENSION_PATTERN, "")
        val targetNameWithoutExtension = resolveTargetFileNameWithoutExtension(
            activity = activity,
            dir = targetDir,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            mimeType = mimeType,
            conflictStrategy = nameConflictStrategy,
        ) ?: return skippedFieldMap

        return moveSingleByTreeDoc(
            activity = activity,
            mimeType = mimeType,
            sourceUri = sourceUri,
            sourcePath = sourcePath,
            targetDir = targetDir,
            targetDirDocFile = targetDirDocFile,
            targetNameWithoutExtension = targetNameWithoutExtension,
            copy = copy
        )
    }

    private suspend fun moveSingleByTreeDoc(
        activity: Activity,
        mimeType: String,
        sourceUri: Uri,
        sourcePath: String,
        targetDir: String,
        targetDirDocFile: DocumentFileCompat?,
        targetNameWithoutExtension: String,
        copy: Boolean
    ): FieldMap {
        // `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
        // `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
        // when used with entry URI as `sourceDocumentUri`, and targetDirDocFile URI as `targetParentDocumentUri`
        val source = DocumentFileCompat.fromSingleUri(activity, sourceUri)

        val targetPath = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && isDownloadDir(activity, targetDir)) {
            val targetFileName = "$targetNameWithoutExtension${extensionFor(mimeType)}"
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, targetFileName)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = activity.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)

            uri?.let {
                @Suppress("BlockingMethodInNonBlockingContext")
                resolver.openOutputStream(uri)?.use { output ->
                    source.copyTo(output)
                }
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
            @Suppress("BlockingMethodInNonBlockingContext")
            val targetTreeFile = targetDirDocFile.createFile(mimeType, targetNameWithoutExtension)
            val targetDocFile = DocumentFileCompat.fromSingleUri(activity, targetTreeFile.uri)

            @Suppress("BlockingMethodInNonBlockingContext")
            source.copyTo(targetDocFile)

            // the source file name and the created document file name can be different when:
            // - a file with the same name already exists, some implementations give a suffix like ` (1)`, some *do not*
            // - the original extension does not match the extension added by the underlying provider
            val fileName = targetDocFile.name
            targetDir + fileName
        }

        if (!copy) {
            // delete original entry
            try {
                delete(activity, sourceUri, sourcePath, mimeType)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
            }
        }

        return scanNewPath(activity, targetPath, mimeType)
    }

    private fun isDownloadDir(context: Context, dirPath: String): Boolean {
        var relativeDir = PathSegments(context, dirPath).relativeDir ?: ""
        if (relativeDir.endsWith(File.separator)) {
            relativeDir = relativeDir.substring(0, relativeDir.length - 1)
        }
        return relativeDir == Environment.DIRECTORY_DOWNLOADS
    }

    override suspend fun renameMultiple(
        activity: Activity,
        newFileName: String,
        entries: List<AvesEntry>,
        callback: ImageOpCallback,
    ) {
        for (entry in entries) {
            val sourceUri = entry.uri
            val sourcePath = entry.path
            val mimeType = entry.mimeType

            val result: FieldMap = hashMapOf(
                "uri" to sourceUri.toString(),
                "success" to false,
            )

            if (sourcePath != null) {
                try {
                    val newFields = renameSingle(
                        activity = activity,
                        mimeType = mimeType,
                        oldMediaUri = sourceUri,
                        oldPath = sourcePath,
                        newFileName = newFileName,
                    )
                    result["newFields"] = newFields
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to rename to newFileName=$newFileName entry with sourcePath=$sourcePath", e)
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
        newFileName: String,
    ): FieldMap {
        val oldFile = File(oldPath)
        val newFile = File(oldFile.parent, newFileName)
        if (oldFile == newFile) {
            // nothing to do
            return skippedFieldMap
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
            && isMediaUriPermissionGranted(activity, oldMediaUri, mimeType)
        ) {
            renameSingleByMediaStore(activity, mimeType, oldMediaUri, newFile)
        } else {
            renameSingleByTreeDoc(activity, mimeType, oldMediaUri, oldPath, newFile)
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private suspend fun renameSingleByMediaStore(
        activity: Activity,
        mimeType: String,
        mediaUri: Uri,
        newFile: File
    ): FieldMap {
        val uri = StorageUtils.getMediaStoreScopedStorageSafeUri(mediaUri, mimeType)

        // `IS_PENDING` is necessary for `TITLE`, not for `DISPLAY_NAME`
        val tempValues = ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 1) }
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
        @Suppress("BlockingMethodInNonBlockingContext")
        val renamed = StorageUtils.getDocumentFile(activity, oldPath, oldMediaUri)?.renameTo(newFile.name) ?: false
        if (!renamed) {
            throw Exception("failed to rename entry at path=$oldPath")
        }

        // Renaming may be successful and the file at the old path no longer exists
        // but, in some situations, scanning the old path does not clear the Media Store entry.
        // For higher chance of accurate obsolete item check, keep this order:
        // 1) scan obsolete item,
        // 2) scan current item,
        // 3) check obsolete item in Media Store

        scanObsoletePath(activity, oldPath, mimeType)
        val newFields = scanNewPath(activity, newFile.path, mimeType)

        if (hasEntry(activity, oldMediaUri)) {
            Log.w(LOG_TAG, "renaming item at uri=$oldMediaUri to newFile=$newFile did not clear the MediaStore entry for obsolete path=$oldPath")

            // On Android Q (emulator/Mi9TPro), the concept of owner package disrupts renaming and the Media Store keeps an obsolete entry,
            // but we use legacy external storage, so at least we do not have to deal with a `RecoverableSecurityException`
            // when deleting this obsolete entry which is not backed by a file anymore.
            // On Android R (S10e), everything seems fine!
            // On Android S (emulator), renaming always leaves an obsolete entry whatever the owner package,
            // and we get a `RecoverableSecurityException` if we attempt to delete this obsolete entry,
            // but the entry seems to be cleaned later automatically by the Media Store anyway.
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
                try {
                    delete(activity, oldMediaUri, oldPath, mimeType)
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to delete entry with path=$oldPath", e)
                }
            }
        }

        return newFields
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

    override fun scanObsoletePath(context: Context, path: String, mimeType: String) {
        MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType), null)
    }

    suspend fun scanNewPath(context: Context, path: String, mimeType: String): FieldMap =
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
            // TODO TLAD use `DISPLAY_NAME` instead/along `TITLE`?
            MediaStore.MediaColumns.TITLE,
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
            // `ORIENTATION` was only available for images before Android Q
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