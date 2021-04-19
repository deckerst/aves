package deckers.thibault.aves.model.provider

import android.annotation.SuppressLint
import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.model.AvesEntry
import deckers.thibault.aves.model.FieldMap
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
import kotlin.collections.ArrayList

class MediaStoreImageProvider : ImageProvider() {
    fun fetchAll(context: Context, knownEntries: Map<Int, Int?>, handleNewEntry: NewEntryHandler) {
        val isModified = fun(contentId: Int, dateModifiedSecs: Int): Boolean {
            val knownDate = knownEntries[contentId]
            return knownDate == null || knownDate < dateModifiedSecs
        }
        fetchFrom(context, isModified, handleNewEntry, IMAGE_CONTENT_URI, IMAGE_PROJECTION)
        fetchFrom(context, isModified, handleNewEntry, VIDEO_CONTENT_URI, VIDEO_PROJECTION)
    }

    override fun fetchSingle(context: Context, uri: Uri, mimeType: String?, callback: ImageOpCallback) {
        val id = uri.tryParseId()
        val onSuccess = fun(entry: FieldMap) {
            entry["uri"] = uri.toString()
            callback.onSuccess(entry)
        }
        val alwaysValid = { _: Int, _: Int -> true }
        if (id != null) {
            if (mimeType == null || isImage(mimeType)) {
                val contentUri = ContentUris.withAppendedId(IMAGE_CONTENT_URI, id)
                if (fetchFrom(context, alwaysValid, onSuccess, contentUri, IMAGE_PROJECTION)) return
            }
            if (mimeType == null || isVideo(mimeType)) {
                val contentUri = ContentUris.withAppendedId(VIDEO_CONTENT_URI, id)
                if (fetchFrom(context, alwaysValid, onSuccess, contentUri, VIDEO_PROJECTION)) return
            }
        }
        // the uri can be a file media URI (e.g. "content://0@media/external/file/30050")
        // without an equivalent image/video if it is shared from a file browser
        // but the file is not publicly visible
        if (fetchFrom(context, alwaysValid, onSuccess, uri, BASE_PROJECTION, fileMimeType = mimeType)) return

        callback.onFailure(Exception("failed to fetch entry at uri=$uri"))
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
        return knownContentIds.filter { id: Int -> !foundContentIds.contains(id) }.toList()
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

    private fun needSize(mimeType: String) = MimeTypes.SVG != mimeType

    // `uri` is a media URI, not a document URI
    override suspend fun delete(context: Context, uri: Uri, path: String?) {
        path ?: throw Exception("failed to delete file because path is null")

        if (File(path).exists() && requireAccessPermission(context, path)) {
            // if the file is on SD card, calling the content resolver `delete()` removes the entry from the Media Store
            // but it doesn't delete the file, even if the app has the permission
            val df = getDocumentFile(context, path, uri)

            @Suppress("BlockingMethodInNonBlockingContext")
            if (df != null && df.delete()) return
            throw Exception("failed to delete file with df=$df")
        }

        if (context.contentResolver.delete(uri, null, null) > 0) return
        throw Exception("failed to delete row from content provider")
    }

    override suspend fun moveMultiple(
        context: Context,
        copy: Boolean,
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
            val mimeType = entry.mimeType

            val result = hashMapOf<String, Any?>(
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
                        context, sourcePath, sourceUri, destinationDir, destinationDirDocFile, mimeType, copy,
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
        context: Context,
        sourcePath: String,
        sourceUri: Uri,
        destinationDir: String,
        destinationDirDocFile: DocumentFileCompat,
        mimeType: String,
        copy: Boolean,
    ): FieldMap {
        val sourceFile = File(sourcePath)
        val sourceDir = sourceFile.parent?.let { ensureTrailingSeparator(it) }
        if (sourceDir == destinationDir) {
            if (copy) throw Exception("file at path=$sourcePath is already in destination directory")
            return HashMap<String, Any?>()
        }

        val sourceFileName = sourceFile.name
        val desiredNameWithoutExtension = sourceFileName.replaceFirst("[.][^.]+$".toRegex(), "")

        if (File(destinationDir, sourceFileName).exists()) {
            throw Exception("file with name=$sourceFileName already exists in destination directory")
        }

        // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
        // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
        // through a document URI, not a tree URI
        // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
        @Suppress("BlockingMethodInNonBlockingContext")
        val destinationTreeFile = destinationDirDocFile.createFile(mimeType, desiredNameWithoutExtension)
        val destinationDocFile = DocumentFileCompat.fromSingleUri(context, destinationTreeFile.uri)

        // `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
        // `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
        // when used with entry URI as `sourceDocumentUri`, and destinationDirDocFile URI as `targetParentDocumentUri`
        val source = DocumentFileCompat.fromSingleUri(context, sourceUri)
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
                delete(context, sourceUri, sourcePath)
                deletedSource = true
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
            }
        }

        return scanNewPath(context, destinationFullPath, mimeType).apply {
            put("deletedSource", deletedSource)
        }
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

    @Suppress("DEPRECATION")
    const val PATH = MediaStore.MediaColumns.DATA
}

typealias NewEntryHandler = (entry: FieldMap) -> Unit

private typealias NewEntryChecker = (contentId: Int, dateModifiedSecs: Int) -> Boolean