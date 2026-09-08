package deckers.thibault.aves.model.provider

import android.annotation.SuppressLint
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import deckers.thibault.aves.model.EntryFields
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.storage.PathSegments
import deckers.thibault.aves.storage.StorageUtils
import deckers.thibault.aves.storage.StorageUtils.ensureTrailingSeparator
import deckers.thibault.aves.storage.StorageUtils.removeTrailingSeparator
import deckers.thibault.aves.storage.apis.FilePermissions
import deckers.thibault.aves.storage.apis.MediaStorePermissions
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isHeic
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.UriUtils.tryParseId
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import java.io.File
import java.io.IOException
import java.io.OutputStream
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.time.Duration.Companion.milliseconds

class MediaStoreImageProvider : ImageProvider() {
    fun fetchAll(
        context: Context,
        knownEntries: Map<Long?, Long?>,
        directory: String?,
        handleNewEntry: NewEntryHandler,
    ) {
        Log.d(LOG_TAG, "fetching all media store items for ${knownEntries.size} known entries, directory=$directory")
        val isModified = fun(contentId: Long, dateModifiedMillis: Long): Boolean {
            val knownDate = knownEntries[contentId]
            return knownDate == null || knownDate < dateModifiedMillis
        }
        val handleNew: NewEntryHandler
        var selection: String? = null
        var selectionArgs: Array<String>? = null
        if (directory != null) {
            val relativePathDirectory = ensureTrailingSeparator(directory)
            val relativePath = PathSegments(context, relativePathDirectory).relativeDir
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && relativePath != null) {
                selection = "${MediaStore.MediaColumns.RELATIVE_PATH} = ? AND ${MediaStore.MediaColumns.DATA} LIKE ?"
                selectionArgs = arrayOf(relativePath, "$relativePathDirectory%")
            } else {
                selection = "${MediaStore.MediaColumns.DATA} LIKE ?"
                selectionArgs = arrayOf("$relativePathDirectory%")
            }

            val parentCheckDirectory = removeTrailingSeparator(directory)
            handleNew = { entry ->
                // skip entries in subfolders
                val path = entry[EntryFields.PATH] as String?
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
    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, allowUnsized: Boolean, callback: ImageOpCallback) {
        var found = false
        val fetched = arrayListOf<FieldMap>()
        val id = uri.tryParseId()
        val alwaysValid: NewEntryChecker = fun(_: Long, _: Long): Boolean = true
        val onSuccess: NewEntryHandler = fun(entry: FieldMap) { fetched.add(entry) }
        if (id != null) {
            if (sourceMimeType == null || isImage(sourceMimeType)) {
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

    fun checkObsoleteContentIds(context: Context, knownContentIds: List<Long?>): List<Long> {
        val foundContentIds = HashSet<Long>()
        fun check(context: Context, contentUri: Uri) {
            val projection = arrayOf(MediaStore.MediaColumns._ID)
            try {
                val cursor = context.contentResolver.query(contentUri, projection, null, null, null)
                if (cursor != null) {
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                    while (cursor.moveToNext()) {
                        foundContentIds.add(cursor.getLong(idColumn))
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

    fun checkObsoletePaths(context: Context, knownPathById: Map<Long?, String?>): List<Long> {
        val obsoleteIds = ArrayList<Long>()
        fun check(context: Context, contentUri: Uri) {
            val projection = arrayOf(MediaStore.MediaColumns._ID, MediaStore.MediaColumns.DATA)
            try {
                val cursor = context.contentResolver.query(contentUri, projection, null, null, null)
                if (cursor != null) {
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                    val pathColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                    while (cursor.moveToNext()) {
                        val id = cursor.getLong(idColumn)
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

    fun getChangedUris(context: Context, sinceGenerationByVolume: Map<String, Long>): List<String> {
        val changedUris = ArrayList<String>()
        fun check(context: Context, sinceGeneration: Long, contentUri: Uri) {
            val projection = arrayOf(MediaStore.MediaColumns._ID)
            val selection = "${MediaStore.MediaColumns.GENERATION_MODIFIED} > ?"
            val selectionArgs = arrayOf(sinceGeneration.toString())
            try {
                val cursor = context.contentResolver.query(contentUri, projection, selection, selectionArgs, null)
                if (cursor != null) {
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                    while (cursor.moveToNext()) {
                        val id = cursor.getLong(idColumn)
                        changedUris.add(ContentUris.withAppendedId(contentUri, id).toString())
                    }
                    cursor.close()
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to get content IDs for contentUri=$contentUri", e)
            }
        }
        sinceGenerationByVolume.forEach { (volumeName, sinceGeneration) ->
            check(context, sinceGeneration, MediaStore.Images.Media.getContentUri(volumeName))
            check(context, sinceGeneration, MediaStore.Video.Media.getContentUri(volumeName))
        }
        return changedUris
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
                val pathColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE)
                val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)
                val widthColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.WIDTH)
                val heightColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.HEIGHT)
                val dateAddedSecsColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_ADDED)
                val dateModifiedSecsColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)
                val dateTakenColumn = cursor.getColumnIndex(MediaColumns.DATE_TAKEN)

                // image & video for API >=29, only for images for API <29
                val orientationColumn = cursor.getColumnIndex(MediaColumns.ORIENTATION)

                // video only
                val durationColumn = cursor.getColumnIndex(MediaColumns.DURATION)
                val needDuration = projection.contentEquals(VIDEO_PROJECTION)

                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idColumn)
                    val dateModifiedMillis = cursor.getInt(dateModifiedSecsColumn) * 1000L
                    if (isValidEntry(id, dateModifiedMillis)) {
                        // for multiple items, `contentUri` is the root without ID,
                        // but for single items, `contentUri` already contains the ID
                        val itemUri = if (contentUriContainsId) contentUri else ContentUris.withAppendedId(contentUri, id)
                        // `mimeType` can be registered as null for file media URIs with unsupported media types (e.g. TIFF on old devices)
                        // in that case we try to use the MIME type provided along the URI
                        val mimeType: String? = cursor.getString(mimeTypeColumn) ?: fileMimeType
                        var width = cursor.getInt(widthColumn)
                        var height = cursor.getInt(heightColumn)
                        val durationMillis = if (durationColumn != -1) cursor.getLong(durationColumn) else 0L

                        if (mimeType == null) {
                            Log.w(LOG_TAG, "failed to make entry from uri=$itemUri because of null MIME type")
                        } else {
                            val path = cursor.getString(pathColumn)

                            val isDir = path != null && File(path).isDirectory
                            if (isDir) {
                                // some directories are wrongly registered as media (e.g. `.../Android/media/is.xyz.mpv`)
                                Log.w(LOG_TAG, "failed to make entry from uri=$itemUri because path=$path refers to a directory")
                            } else {
                                var entryFields: FieldMap = hashMapOf(
                                    EntryFields.ORIGIN to SourceEntry.ORIGIN_MEDIA_STORE_CONTENT,
                                    EntryFields.URI to itemUri.toString(),
                                    EntryFields.PATH to path,
                                    EntryFields.SOURCE_MIME_TYPE to mimeType,
                                    EntryFields.WIDTH to width,
                                    EntryFields.HEIGHT to height,
                                    EntryFields.SOURCE_ROTATION_DEGREES to if (orientationColumn != -1) cursor.getInt(orientationColumn) else 0,
                                    EntryFields.SIZE_BYTES to cursor.getLong(sizeColumn),
                                    EntryFields.DATE_ADDED_SECS to cursor.getInt(dateAddedSecsColumn),
                                    EntryFields.DATE_MODIFIED_MILLIS to dateModifiedMillis,
                                    EntryFields.SOURCE_DATE_TAKEN_MILLIS to if (dateTakenColumn != -1) cursor.getLong(dateTakenColumn) else null,
                                    EntryFields.DURATION_MILLIS to durationMillis,
                                    // only for map export
                                    EntryFields.CONTENT_ID to id,
                                )

                                if (isHeic(mimeType) || mimeType == MimeTypes.TIFF) {
                                    // The reported size for some HEIC images is simply incorrect.
                                    // Some HEIC images are detected as TIFF.
                                    try {
                                        StorageUtils.openInputStream(context, itemUri)?.use { input ->
                                            val options = BitmapFactory.Options().apply {
                                                inJustDecodeBounds = true
                                            }
                                            BitmapFactory.decodeStream(input, null, options)
                                            val outWidth = options.outWidth
                                            val outHeight = options.outHeight
                                            if (outWidth > 0 && outHeight > 0) {
                                                width = outWidth
                                                height = outHeight
                                                entryFields[EntryFields.WIDTH] = width
                                                entryFields[EntryFields.HEIGHT] = height
                                            }
                                        }
                                    } catch (_: IOException) {
                                        // ignore
                                    }
                                }

                                if (MimeTypes.isRaw(mimeType)
                                    || (width <= 0 || height <= 0) && needSize(mimeType)
                                    || durationMillis == 0L && needDuration
                                ) {
                                    // Some images are incorrectly registered in the Media Store,
                                    // missing some attributes such as width, height, orientation.
                                    // Also, the reported size of raw images is inconsistent across devices
                                    // and Android versions (sometimes the raw size, sometimes the decoded size).
                                    val entry = SourceEntry(entryFields).fillPreCatalogMetadata(context)
                                    entryFields = entry.toMap()
                                }

                                getFileModifiedDateMillis(path)?.let { entryFields[EntryFields.DATE_MODIFIED_MILLIS] = it }

                                handleNewEntry(entryFields)
                                found = true
                            }
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

    override suspend fun renameSingle(
        context: Context,
        mimeType: String,
        oldMediaUri: Uri,
        oldPath: String,
        newFile: File,
    ): FieldMap = when {
        FilePermissions.canEdit(context, oldPath) -> {
            val newPath = FileImageProvider.move(File(oldPath), newFile, copy = false)
            scanObsoletePath(context, oldMediaUri, oldPath, mimeType)
            return scanNewPathByMediaStore(context, newPath, mimeType)
        }

        MediaStorePermissions.canEdit(context, oldMediaUri, mimeType) -> {
            return MediaStoreImageProvider.rename(context, mimeType, oldMediaUri, newFile)
        }

        else -> {
            val newPath = renameSingleByTreeDoc(context, oldMediaUri, oldPath, newFile)
            scanObsoletePath(context, oldMediaUri, oldPath, mimeType)
            return scanNewPathByMediaStore(context, newPath, mimeType)
        }
    }

    private fun renameSingleByTreeDoc(
        context: Context,
        oldMediaUri: Uri,
        oldPath: String,
        newFile: File
    ): String {
        Log.d(LOG_TAG, "rename document at uri=$oldMediaUri path=$oldPath")
        val df = StorageUtils.getDocumentFile(context, oldPath, oldMediaUri)
        df ?: throw Exception("failed to get document at path=$oldPath")

        val requestedName = newFile.name
        val renamed = df.renameTo(newFile.name)
        if (!renamed) {
            throw Exception("failed to rename document at path=$oldPath")
        }
        val effectiveName = df.name
        if (requestedName != effectiveName) {
            Log.w(LOG_TAG, "requested renaming document at uri=$oldMediaUri path=$oldPath with name=${requestedName} but got name=$effectiveName")
        }
        val newPath = File(newFile.parentFile, df.name).path
        return newPath
    }

    override fun scanPostMetadataEdit(context: Context, path: String, uri: Uri, mimeType: String, newFields: FieldMap, callback: ImageOpCallback) {
        MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, _ ->
            val projection = arrayOf(
                MediaStore.MediaColumns.DATE_MODIFIED,
                MediaStore.MediaColumns.SIZE,
            )
            try {
                val cursor = context.contentResolver.query(uri, projection, null, null, null)
                if (cursor != null && cursor.moveToFirst()) {
                    cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields[EntryFields.DATE_MODIFIED_MILLIS] = cursor.getInt(it) * 1000 }
                    cursor.getColumnIndex(MediaStore.MediaColumns.SIZE).let { if (it != -1) newFields[EntryFields.SIZE_BYTES] = cursor.getLong(it) }
                    cursor.close()
                }
            } catch (e: Exception) {
                callback.onFailure(e)
                return@scanFile
            }
            getFileModifiedDateMillis(path)?.let { newFields[EntryFields.DATE_MODIFIED_MILLIS] = it }
            callback.onSuccess(newFields)
        }
    }

    fun getContentUriForPath(context: Context, path: String): Uri? {
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        val selection = "${MediaStore.MediaColumns.DATA} = ?"
        val selectionArgs = arrayOf(path)

        fun check(context: Context, contentUri: Uri): Uri? {
            var mediaContentUri: Uri? = null
            try {
                val cursor = context.contentResolver.query(contentUri, projection, selection, selectionArgs, null)
                if (cursor != null && cursor.moveToFirst()) {
                    val idColumn = cursor.getColumnIndex(MediaStore.MediaColumns._ID)
                    if (idColumn != -1) {
                        val id = cursor.getLong(idColumn)
                        mediaContentUri = ContentUris.withAppendedId(contentUri, id)
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
            MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.MIME_TYPE,
            MediaStore.MediaColumns.SIZE,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.DATE_ADDED,
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
            // `ORIENTATION` was only available for images before Android 10 (API 29)
            *if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) arrayOf(
                MediaStore.MediaColumns.ORIENTATION,
            ) else emptyArray()
        )

        // try to fetch the modified date from the file,
        // as it is more precise than the one from the Media Store
        private fun getFileModifiedDateMillis(path: String?): Long? {
            if (path != null) {
                try {
                    return File(path).lastModified()
                } catch (_: SecurityException) {
                    // ignore
                }
            }
            return null
        }

        fun scanObsoletePath(context: Context, uri: Uri, path: String, mimeType: String) {
            val file = File(path)
            val delayMillis = 500L
            val maxDelayMillis = 10000L
            var totalDelayMillis = 0L
            while (file.exists()) {
                if (!contentExists(context, uri)) return
                if (totalDelayMillis < maxDelayMillis) {
                    Log.d(LOG_TAG, "Trying to scan obsolete path but file exists at path=$path. Will retry in $delayMillis ms (total: $totalDelayMillis ms)")
                    runBlocking { delay(delayMillis.milliseconds) }
                    totalDelayMillis += delayMillis
                } else {
                    throw Exception("timeout ($maxDelayMillis ms) to clear MediaStore entry for file at path=$path")
                }
            }

            if (contentExists(context, uri)) {
                MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, newUri: Uri? ->
                    if (newUri != null && contentExists(context, newUri)) {
                        Log.w(LOG_TAG, "Failed to clear Media Store entry at uri=$newUri path=$path")
                    } else {
                        Log.w(LOG_TAG, "Cleared Media Store entry at uri=$newUri path=$path")
                    }
                }
            }
        }

        suspend fun scanNewPathByMediaStore(context: Context, path: String, mimeType: String): FieldMap =
            suspendCancellableCoroutine { cont ->
                tryScanNewPathByMediaStore(
                    context = context,
                    path = path,
                    mimeType = mimeType,
                    cont = cont,
                )
            }

        private fun tryScanNewPathByMediaStore(
            context: Context,
            path: String,
            mimeType: String,
            cont: Continuation<FieldMap>,
            iteration: Int = 0,
        ) {
            // `scanFile` may (e.g. when copying to SD card on Android 10 (API 29)):
            // 1) yield no URI,
            // 2) yield a temporary URI that fails when queried,
            // 3) yield a temporary URI that succeeds when queried right away, but the Media Store actually won't have an entry for it until device reboot.
            if (iteration > 5) {
                // give up
                cont.resumeWithException(Exception("failed to scan new path=$path after $iteration iterations"))
                return
            } else if (iteration > 0) {
                // waiting and retrying just once usually works out for cases 1) and 2)
                Thread.sleep(iteration * 100L)
            } else if (iteration == 0 && Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                // waiting before the first scan usually works out for case 3)
                StorageUtils.getVolumePath(context, path)?.let { volumePath ->
                    if (volumePath != StorageUtils.getPrimaryVolumePath(context)) {
                        Thread.sleep(100L)
                    }
                }
            }

            MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, newUri: Uri? ->
                fun scanUri(uri: Uri?): FieldMap? {
                    uri ?: return null

                    // we retrieve updated fields as the renamed/moved file became a new entry in the Media Store
                    val projection = arrayOf(
                        MediaStore.MediaColumns.DATE_ADDED,
                        MediaStore.MediaColumns.DATE_MODIFIED,
                    )
                    try {
                        val cursor = context.contentResolver.query(uri, projection, null, null, null)
                        if (cursor != null && cursor.moveToFirst()) {
                            val newFields = hashMapOf<String, Any?>(
                                EntryFields.ORIGIN to SourceEntry.ORIGIN_MEDIA_STORE_CONTENT,
                                EntryFields.URI to uri.toString(),
                                EntryFields.CONTENT_ID to uri.tryParseId(),
                                EntryFields.PATH to path,
                            )
                            cursor.getColumnIndex(MediaStore.MediaColumns.DATE_ADDED).let { if (it != -1) newFields[EntryFields.DATE_ADDED_SECS] = cursor.getInt(it) }
                            cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED).let { if (it != -1) newFields[EntryFields.DATE_MODIFIED_MILLIS] = cursor.getInt(it) * 1000 }
                            cursor.close()
                            getFileModifiedDateMillis(path)?.let { newFields[EntryFields.DATE_MODIFIED_MILLIS] = it }
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
                        return@scanFile
                    }
                }

                tryScanNewPathByMediaStore(context, path = path, mimeType = mimeType, cont, iteration + 1)
            }
        }

        fun insert(
            context: Context,
            mimeType: String,
            targetDir: String,
            targetFileName: String,
            write: (OutputStream) -> Unit,
        ): String {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                throw Exception("unsupported Android version")
            }

            val volumePath = StorageUtils.getVolumePath(context, anyPath = targetDir)
            val relativePath = targetDir.substring(volumePath?.length ?: 0)

            val contentUri = StorageUtils.getMediaStoreRootContentUri(context, mimeType = mimeType, anyPath = targetDir)
                ?: throw Exception("failed to get MediaStore root content URI for mimeType=$mimeType targetDir=$targetDir")

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, targetFileName)
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = context.contentResolver
            val uri = resolver.insert(contentUri, values)
                ?: throw Exception("MediaStore failed to insert for an unknown reason")

            resolver.openOutputStream(uri)?.use(write)
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)

            return File(targetDir, targetFileName).path
        }

        suspend fun rename(
            context: Context,
            mimeType: String,
            mediaUri: Uri,
            newFile: File
        ): FieldMap {
            Log.d(LOG_TAG, "rename content at uri=$mediaUri")
            val uri = StorageUtils.getMediaStoreScopedStorageSafeUri(mediaUri, mimeType)

            // `IS_PENDING` is necessary for `TITLE`, not for `DISPLAY_NAME`
            val tempValues = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            if (context.contentResolver.update(uri, tempValues, null, null) == 0) {
                throw Exception("failed to update fields for uri=$uri")
            }

            val finalValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, newFile.name)
                // scanning the new file will not automatically update `TITLE`
                put(MediaStore.MediaColumns.TITLE, newFile.nameWithoutExtension)
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            if (context.contentResolver.update(uri, finalValues, null, null) == 0) {
                throw Exception("failed to update fields for uri=$uri")
            }

            // URI should not change
            return scanNewPathByMediaStore(context, newFile.path, mimeType)
        }

        fun move(
            context: Context,
            mimeType: String,
            mediaUri: Uri,
            sourceFile: File,
            targetFile: File,
        ): String? {
            Log.d(LOG_TAG, "move content at uri=$mediaUri")

            val uri = StorageUtils.getMediaStoreScopedStorageSafeUri(mediaUri, mimeType)

            val sourceSegments = PathSegments(context, sourceFile.path)
            val targetSegments = PathSegments(context, targetFile.path)

            val sourceVolume = sourceSegments.volumePath
            val targetVolume = targetSegments.volumePath
            if (sourceVolume != targetVolume) {
                throw Exception("moving from volume $sourceVolume to $targetVolume is not possible via Media Store API")
            }

            val finalValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, targetFile.name)
                put(MediaStore.MediaColumns.RELATIVE_PATH, targetSegments.relativeDir)
            }
            if (context.contentResolver.update(uri, finalValues, null, null) == 0) {
                throw Exception("failed to update fields for uri=$uri")
            }

            return targetFile.path
        }
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
}

typealias NewEntryHandler = (entry: FieldMap) -> Unit

private typealias NewEntryChecker = (contentId: Long, dateModifiedMillis: Long) -> Boolean