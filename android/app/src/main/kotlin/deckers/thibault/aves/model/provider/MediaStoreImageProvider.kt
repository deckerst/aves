package deckers.thibault.aves.model.provider

import android.annotation.SuppressLint
import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.MainActivity.Companion.DELETE_PERMISSION_REQUEST
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.NameConflictStrategy
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils.createDirectoryIfAbsent
import deckers.thibault.aves.utils.StorageUtils.ensureTrailingSeparator
import deckers.thibault.aves.utils.StorageUtils.getDocumentFile
import deckers.thibault.aves.utils.StorageUtils.requireAccessPermission
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
    override suspend fun delete(activity: Activity, uri: Uri, path: String?) {
        path ?: throw Exception("failed to delete file because path is null")

        if (File(path).exists() && requireAccessPermission(activity, path)) {
            // if the file is on SD card, calling the content resolver `delete()` removes the entry from the Media Store
            // but it doesn't delete the file, even if the app has the permission
            val df = getDocumentFile(activity, path, uri)

            @Suppress("BlockingMethodInNonBlockingContext")
            if (df != null && df.delete()) return
            throw Exception("failed to delete file with df=$df")
        }

        try {
            if (activity.contentResolver.delete(uri, null, null) > 0) return
        } catch (securityException: SecurityException) {
            // even if the app has access permission granted on the containing directory,
            // the delete request may yield a `RecoverableSecurityException` on Android 10+
            // when the underlying file no longer exists and this is an orphaned entry in the Media Store
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val rse = securityException as? RecoverableSecurityException ?: throw securityException
                val intentSender = rse.userAction.actionIntent.intentSender

                // request user permission for this item
                pendingDeleteCompleter = CompletableFuture<Boolean>()
                activity.startIntentSenderForResult(intentSender, DELETE_PERMISSION_REQUEST, null, 0, 0, 0, null)
                val granted = pendingDeleteCompleter!!.join()

                pendingDeleteCompleter = null
                if (granted) {
                    delete(activity, uri, path)
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
        destinationDir: String,
        nameConflictStrategy: NameConflictStrategy,
        entries: List<AvesEntry>,
        callback: ImageOpCallback,
    ) {
        val destinationDirDocFile = createDirectoryIfAbsent(activity, destinationDir)
        if (destinationDirDocFile == null) {
            callback.onFailure(Exception("failed to create directory at path=$destinationDir"))
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
                    val newFields = moveSingleByTreeDocAndScan(
                        activity = activity,
                        sourcePath = sourcePath,
                        sourceUri = sourceUri,
                        destinationDir = destinationDir,
                        destinationDirDocFile = destinationDirDocFile,
                        nameConflictStrategy = nameConflictStrategy,
                        mimeType = mimeType,
                        copy = copy,
                    )
                    result["newFields"] = newFields
                    result["success"] = true
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to move to destinationDir=$destinationDir entry with sourcePath=$sourcePath", e)
                }
            }
            callback.onSuccess(result)
        }
    }

    private suspend fun moveSingleByTreeDocAndScan(
        activity: Activity,
        sourcePath: String,
        sourceUri: Uri,
        destinationDir: String,
        destinationDirDocFile: DocumentFileCompat,
        nameConflictStrategy: NameConflictStrategy,
        mimeType: String,
        copy: Boolean,
    ): FieldMap {
        val sourceFile = File(sourcePath)
        val sourceDir = sourceFile.parent?.let { ensureTrailingSeparator(it) }
        if (sourceDir == destinationDir && !(copy && nameConflictStrategy == NameConflictStrategy.RENAME)) {
            // nothing to do unless it's a renamed copy
            return skippedFieldMap
        }

        val sourceFileName = sourceFile.name
        val desiredNameWithoutExtension = sourceFileName.replaceFirst(FILE_EXTENSION_PATTERN, "")
        val targetNameWithoutExtension = resolveTargetFileNameWithoutExtension(
            activity = activity,
            dir = destinationDir,
            desiredNameWithoutExtension = desiredNameWithoutExtension,
            extension = MimeTypes.extensionFor(mimeType),
            conflictStrategy = nameConflictStrategy,
        ) ?: return skippedFieldMap

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        @Suppress("BlockingMethodInNonBlockingContext")
        val destinationTreeFile = destinationDirDocFile.createFile(mimeType, targetNameWithoutExtension)
        val destinationDocFile = DocumentFileCompat.fromSingleUri(activity, destinationTreeFile.uri)

        // `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
        // `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
        // when used with entry URI as `sourceDocumentUri`, and destinationDirDocFile URI as `targetParentDocumentUri`
        val source = DocumentFileCompat.fromSingleUri(activity, sourceUri)
        @Suppress("BlockingMethodInNonBlockingContext")
        source.copyTo(destinationDocFile)

        // the source file name and the created document file name can be different when:
        // - a file with the same name already exists, some implementations give a suffix like ` (1)`, some *do not*
        // - the original extension does not match the extension added by the underlying provider
        val fileName = destinationDocFile.name
        val destinationFullPath = destinationDir + fileName

        var deletedSource = false
        if (!copy) {
            // delete original entry
            try {
                delete(activity, sourceUri, sourcePath)
                deletedSource = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
            }
        }

        return scanNewPath(activity, destinationFullPath, mimeType).apply {
            put("deletedSource", deletedSource)
        }
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
                        oldPath = sourcePath,
                        oldMediaUri = sourceUri,
                        newFileName = newFileName,
                        mimeType = mimeType,
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
        oldPath: String,
        oldMediaUri: Uri,
        newFileName: String,
        mimeType: String,
    ): FieldMap {
        val oldFile = File(oldPath)
        val newFile = File(oldFile.parent, newFileName)
        if (oldFile == newFile) {
            // nothing to do
            return skippedFieldMap
        }

        @Suppress("BlockingMethodInNonBlockingContext")
        val renamed = getDocumentFile(activity, oldPath, oldMediaUri)?.renameTo(newFileName) ?: false
        if (!renamed) {
            throw Exception("failed to rename entry at path=$oldPath")
        }

        // renaming may be successful and the file at the old path no longer exists
        // but, in some situations, scanning the old path does not clear the Media Store entry
        // e.g. for media owned by another package in the Download folder on API 29

        // for higher chance of accurate obsolete item check, keep this order:
        // 1) scan obsolete item,
        // 2) scan current item,
        // 3) check obsolete item in Media Store

        scanObsoletePath(activity, oldPath, mimeType)
        val newFields = scanNewPath(activity, newFile.path, mimeType)

        var deletedSource = !hasEntry(activity, oldMediaUri)
        if (!deletedSource) {
            Log.w(LOG_TAG, "renaming item at uri=$oldMediaUri to newFileName=$newFileName did not clear the MediaStore entry for obsolete path=$oldPath")

            // delete obsolete entry
            try {
                delete(activity, oldMediaUri, oldPath)
                deletedSource = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to delete entry with path=$oldPath", e)
            }
        }
        newFields["deletedSource"] = deletedSource

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

        var pendingDeleteCompleter: CompletableFuture<Boolean>? = null
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

    @Suppress("DEPRECATION")
    const val PATH = MediaStore.MediaColumns.DATA
}

typealias NewEntryHandler = (entry: FieldMap) -> Unit

private typealias NewEntryChecker = (contentId: Int, dateModifiedSecs: Int) -> Boolean