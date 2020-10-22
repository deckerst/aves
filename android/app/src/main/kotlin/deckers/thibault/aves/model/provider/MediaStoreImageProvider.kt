package deckers.thibault.aves.model.provider

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import com.commonsware.cwac.document.DocumentFileCompat
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.SettableFuture
import deckers.thibault.aves.model.AvesImageEntry
import deckers.thibault.aves.model.SourceImageEntry
import deckers.thibault.aves.utils.LogUtils.createTag
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils.createDirectoryIfAbsent
import deckers.thibault.aves.utils.StorageUtils.getDocumentFile
import deckers.thibault.aves.utils.StorageUtils.requireAccessPermission
import java.io.File
import java.io.FileNotFoundException
import java.util.*
import java.util.concurrent.ExecutionException

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
        val id = ContentUris.parseId(uri)
        val onSuccess = fun(entry: FieldMap) {
            entry["uri"] = uri.toString()
            callback.onSuccess(entry)
        }
        val alwaysValid = { _: Int, _: Int -> true }
        if (mimeType == null || isImage(mimeType)) {
            val contentUri = ContentUris.withAppendedId(IMAGE_CONTENT_URI, id)
            if (fetchFrom(context, alwaysValid, onSuccess, contentUri, IMAGE_PROJECTION) > 0) return
        }
        if (mimeType == null || isVideo(mimeType)) {
            val contentUri = ContentUris.withAppendedId(VIDEO_CONTENT_URI, id)
            if (fetchFrom(context, alwaysValid, onSuccess, contentUri, VIDEO_PROJECTION) > 0) return
        }
        callback.onFailure(Exception("failed to fetch entry at uri=$uri"))
    }

    fun getObsoleteContentIds(context: Context, knownContentIds: List<Int>): List<Int> {
        val current = arrayListOf<Int>().apply {
            addAll(getContentIdList(context, IMAGE_CONTENT_URI))
            addAll(getContentIdList(context, VIDEO_CONTENT_URI))
        }
        return knownContentIds.filter { id: Int -> !current.contains(id) }.toList()
    }

    private fun getContentIdList(context: Context, contentUri: Uri): List<Int> {
        val foundContentIds = ArrayList<Int>()
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
        return foundContentIds
    }

    private fun fetchFrom(
        context: Context,
        isValidEntry: NewEntryChecker,
        handleNewEntry: NewEntryHandler,
        contentUri: Uri,
        projection: Array<String>,
    ): Int {
        var newEntryCount = 0
        val orderBy = "${MediaStore.MediaColumns.DATE_MODIFIED} DESC"
        try {
            val cursor = context.contentResolver.query(contentUri, projection, null, null, orderBy)
            if (cursor != null) {
                // image & video
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                val pathColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE)
                val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)
                val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.TITLE)
                val widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH)
                val heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT)
                val dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
                val dateTakenColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_TAKEN)

                // image & video for API >= Q, only for images for API < Q
                val orientationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.ORIENTATION)

                // video only
                val durationColumn = cursor.getColumnIndex(MediaStore.MediaColumns.DURATION)
                val needDuration = projection.contentEquals(VIDEO_PROJECTION)

                while (cursor.moveToNext()) {
                    val contentId = cursor.getInt(idColumn)
                    val dateModifiedSecs = cursor.getInt(dateModifiedColumn)
                    if (isValidEntry(contentId, dateModifiedSecs)) {
                        // building `itemUri` this way is fine if `contentUri` does not already contain the ID
                        val itemUri = ContentUris.withAppendedId(contentUri, contentId.toLong())
                        val mimeType = cursor.getString(mimeTypeColumn)
                        val width = cursor.getInt(widthColumn)
                        val height = cursor.getInt(heightColumn)
                        val durationMillis = if (durationColumn != -1) cursor.getLong(durationColumn) else 0L

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
                            "sourceDateTakenMillis" to cursor.getLong(dateTakenColumn),
                            "durationMillis" to durationMillis,
                            // only for map export
                            "contentId" to contentId,
                        )

                        if ((width <= 0 || height <= 0) && needSize(mimeType)
                            || durationMillis == 0L && needDuration
                        ) {
                            // some images are incorrectly registered in the Media Store,
                            // they are valid but miss some attributes, such as width, height, orientation
                            val entry = SourceImageEntry(entryMap).fillPreCatalogMetadata(context)
                            entryMap = entry.toMap()
                        }

                        handleNewEntry(entryMap)
                        // TODO TLAD is this necessary?
                        if (newEntryCount % 30 == 0) {
                            Thread.sleep(10)
                        }
                        newEntryCount++
                    }
                }
                cursor.close()
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to get entries", e)
        }
        return newEntryCount
    }

    private fun needSize(mimeType: String) = MimeTypes.SVG != mimeType

    // `uri` is a media URI, not a document URI
    override fun delete(context: Context, uri: Uri, path: String?): ListenableFuture<Any?> {
        val future = SettableFuture.create<Any?>()

        if (path == null) {
            future.setException(Exception("failed to delete file because path is null"))
            return future
        }

        if (requireAccessPermission(context, path)) {
            // if the file is on SD card, calling the content resolver `delete()` removes the entry from the Media Store
            // but it doesn't delete the file, even if the app has the permission
            try {
                val df = getDocumentFile(context, path, uri)
                if (df != null && df.delete()) {
                    future.set(null)
                } else {
                    future.setException(Exception("failed to delete file with df=$df"))
                }
            } catch (e: FileNotFoundException) {
                future.setException(e)
            }
            return future
        }

        try {
            if (context.contentResolver.delete(uri, null, null) > 0) {
                future.set(null)
            } else {
                future.setException(Exception("failed to delete row from content provider"))
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to delete entry", e)
            future.setException(e)
        }
        return future
    }

    override fun moveMultiple(
        context: Context,
        copy: Boolean,
        destinationDir: String,
        entries: List<AvesImageEntry>,
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
                    val newFieldsFuture = moveSingleByTreeDocAndScan(
                        context, sourcePath, sourceUri, destinationDir, destinationDirDocFile, mimeType, copy,
                    )
                    result["newFields"] = newFieldsFuture.get()
                    result["success"] = true
                } catch (e: ExecutionException) {
                    Log.w(LOG_TAG, "failed to move to destinationDir=$destinationDir entry with sourcePath=$sourcePath", e)
                } catch (e: InterruptedException) {
                    Log.w(LOG_TAG, "failed to move to destinationDir=$destinationDir entry with sourcePath=$sourcePath", e)
                }
            }
            callback.onSuccess(result)
        }
    }

    private fun moveSingleByTreeDocAndScan(
        context: Context,
        sourcePath: String,
        sourceUri: Uri,
        destinationDir: String,
        destinationDirDocFile: DocumentFileCompat,
        mimeType: String,
        copy: Boolean,
    ): ListenableFuture<FieldMap> {
        val future = SettableFuture.create<FieldMap>()

        try {
            val sourceFileName = File(sourcePath).name
            val desiredNameWithoutExtension = sourceFileName.replaceFirst("[.][^.]+$".toRegex(), "")

            // the file created from a `TreeDocumentFile` is also a `TreeDocumentFile`
            // but in order to open an output stream to it, we need to use a `SingleDocumentFile`
            // through a document URI, not a tree URI
            // note that `DocumentFile.getParentFile()` returns null if we did not pick a tree first
            val destinationTreeFile = destinationDirDocFile.createFile(mimeType, desiredNameWithoutExtension)
            val destinationDocFile = DocumentFileCompat.fromSingleUri(context, destinationTreeFile.uri)

            // `DocumentsContract.moveDocument()` needs `sourceParentDocumentUri`, which could be different for each entry
            // `DocumentsContract.copyDocument()` yields "Unsupported call: android:copyDocument"
            // when used with entry URI as `sourceDocumentUri`, and destinationDirDocFile URI as `targetParentDocumentUri`
            val source = DocumentFileCompat.fromSingleUri(context, sourceUri)
            source.copyTo(destinationDocFile)

            // the source file name and the created document file name can be different when:
            // - a file with the same name already exists, so the name gets a suffix like ` (1)`
            // - the original extension does not match the extension added by the underlying provider
            val fileName = destinationDocFile.name
            val destinationFullPath = destinationDir + fileName

            var deletedSource = false
            if (!copy) {
                // delete original entry
                try {
                    delete(context, sourceUri, sourcePath).get()
                    deletedSource = true
                } catch (e: ExecutionException) {
                    Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
                } catch (e: InterruptedException) {
                    Log.w(LOG_TAG, "failed to delete entry with path=$sourcePath", e)
                }
            }

            scanNewPath(context, destinationFullPath, mimeType, object : ImageOpCallback {
                override fun onSuccess(fields: FieldMap) {
                    fields["deletedSource"] = deletedSource
                    future.set(fields)
                }

                override fun onFailure(throwable: Throwable) {
                    future.setException(throwable)
                }
            })
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to ${(if (copy) "copy" else "move")} entry", e)
            future.setException(e)
        }

        return future
    }

    companion object {
        private val LOG_TAG = createTag(MediaStoreImageProvider::class.java)

        private val IMAGE_CONTENT_URI = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        private val VIDEO_CONTENT_URI = MediaStore.Video.Media.EXTERNAL_CONTENT_URI

        private val BASE_PROJECTION = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.SIZE,  // TODO TLAD use `DISPLAY_NAME` instead/along `TITLE`?
            MediaStore.MediaColumns.TITLE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.DATE_MODIFIED
        )

        private val IMAGE_PROJECTION = arrayOf(
            *BASE_PROJECTION,
            // uses `MediaStore.Images.Media` instead of `MediaStore.MediaColumns` for APIs < Q
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.ORIENTATION
        )

        private val VIDEO_PROJECTION = arrayOf(
            *BASE_PROJECTION,
            // uses `MediaStore.Video.Media` instead of `MediaStore.MediaColumns` for APIs < Q
            MediaStore.Video.Media.DATE_TAKEN,
            MediaStore.Video.Media.DURATION,
            *if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) arrayOf(
                MediaStore.Video.Media.ORIENTATION
            ) else emptyArray()
        )
    }
}

typealias NewEntryHandler = (entry: FieldMap) -> Unit

private typealias NewEntryChecker = (contentId: Int, dateModifiedSecs: Int) -> Boolean