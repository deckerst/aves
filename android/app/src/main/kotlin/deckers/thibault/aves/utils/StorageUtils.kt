package deckers.thibault.aves.utils

import android.Manifest
import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.ParcelFileDescriptor
import android.os.storage.StorageManager
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.model.provider.ImageProvider
import deckers.thibault.aves.utils.FileUtils.transferFrom
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.PermissionManager.getGrantedDirForPath
import deckers.thibault.aves.utils.UriUtils.tryParseId
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.Locale
import java.util.regex.Pattern

object StorageUtils {
    private val LOG_TAG = LogUtils.createTag<StorageUtils>()

    private const val SCHEME_CONTENT = ContentResolver.SCHEME_CONTENT

    // cf DocumentsContract.EXTERNAL_STORAGE_PROVIDER_AUTHORITY
    private const val EXTERNAL_STORAGE_PROVIDER_AUTHORITY = "com.android.externalstorage.documents"

    // cf DocumentsContract.EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID
    private const val EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID = "primary"

    private const val TREE_URI_ROOT = "$SCHEME_CONTENT://$EXTERNAL_STORAGE_PROVIDER_AUTHORITY/tree/"

    private val MEDIA_STORE_VOLUME_EXTERNAL = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) MediaStore.VOLUME_EXTERNAL else "external"

    // TODO TLAD get it from `MediaStore.Images.Media.EXTERNAL_CONTENT_URI`?
    private val IMAGE_PATH_ROOT = "/$MEDIA_STORE_VOLUME_EXTERNAL/images/"

    // TODO TLAD get it from `MediaStore.Video.Media.EXTERNAL_CONTENT_URI`?
    private val VIDEO_PATH_ROOT = "/$MEDIA_STORE_VOLUME_EXTERNAL/video/"

    private val UUID_PATTERN = Regex("[A-Fa-f\\d-]+")
    private val TREE_URI_PATH_PATTERN = Pattern.compile("(.*?):(.*)")

    const val TRASH_PATH_PLACEHOLDER = "#trash"

    // whether the provided path is on one of this app specific directories:
    // - /storage/{volume}/Android/data/{package_name}/files
    // - /data/user/0/{package_name}/files
    private fun isAppFile(context: Context, path: String): Boolean {
        val dirs = listOf(
            *context.getExternalFilesDirs(null).filterNotNull().toTypedArray(),
            context.filesDir,
        )
        return dirs.any { path.startsWith(it.path) }
    }

    private fun appExternalFilesDirFor(context: Context, path: String): File? {
        val dirs = context.getExternalFilesDirs(null).filterNotNull()
        val volumePath = getVolumePath(context, path)
        return volumePath?.let { dirs.firstOrNull { it.startsWith(volumePath) } } ?: dirs.firstOrNull()
    }

    fun trashDirFor(context: Context, path: String): File? {
        val externalFilesDir = appExternalFilesDirFor(context, path)
        if (externalFilesDir == null) {
            Log.e(LOG_TAG, "failed to find external files dir for path=$path")
            return null
        }
        val trashDir = File(externalFilesDir, "trash")
        trashDir.mkdirs()
        if (!trashDir.exists()) {
            Log.e(LOG_TAG, "failed to create directories at path=$trashDir")
            return null
        }
        return trashDir
    }

    fun getVaultRoot(context: Context) = ensureTrailingSeparator(File(context.filesDir, "vault").path)

    fun isInVault(context: Context, path: String) = path.startsWith(getVaultRoot(context))

    /**
     * Volume paths
     */

    // volume paths, with trailing "/"
    private var mStorageVolumePaths: Array<String>? = null

    // primary volume path, with trailing "/"
    private var mPrimaryVolumePath: String? = null

    fun getPrimaryVolumePath(context: Context): String {
        if (mPrimaryVolumePath == null) {
            mPrimaryVolumePath = findPrimaryVolumePath(context)
        }
        return mPrimaryVolumePath!!
    }

    fun getVolumePaths(context: Context): Array<String> {
        if (mStorageVolumePaths == null || mStorageVolumePaths!!.isEmpty()) {
            mStorageVolumePaths = findVolumePaths(context)
        }
        return mStorageVolumePaths!!
    }

    fun getVolumePath(context: Context, anyPath: String): String? {
        return getVolumePaths(context).firstOrNull { anyPath.startsWith(it) }
    }

    private fun getPathStepIterator(context: Context, anyPath: String, root: String?): Iterator<String?>? {
        val rootLength = (root ?: getVolumePath(context, anyPath))?.length ?: return null

        var fileName: String? = null
        var relativePath: String? = null
        val lastSeparatorIndex = anyPath.lastIndexOf(File.separator) + 1
        if (lastSeparatorIndex > rootLength) {
            fileName = anyPath.substring(lastSeparatorIndex)
            relativePath = anyPath.substring(rootLength, lastSeparatorIndex)
        }
        relativePath ?: return null

        val pathSteps = relativePath.split(File.separator).filter { it.isNotEmpty() }.toMutableList()
        if (fileName?.isNotEmpty() == true) {
            pathSteps.add(fileName)
        }
        return pathSteps.iterator()
    }

    private fun appSpecificVolumePath(file: File?): String? {
        file ?: return null
        val appSpecificPath = file.absolutePath
        val relativePathStartIndex = appSpecificPath.indexOf("Android/data")
        if (relativePathStartIndex < 0) return null
        return appSpecificPath.substring(0, relativePathStartIndex)
    }

    private fun findPrimaryVolumePath(context: Context): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val sm = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
            val path = sm?.primaryStorageVolume?.directory?.path
            if (path != null) {
                return ensureTrailingSeparator(path)
            }
        }

        // fallback
        try {
            // we want:
            // /storage/emulated/0/
            // `Environment.getExternalStorageDirectory()` (deprecated) yields:
            // /storage/emulated/0
            // `context.getExternalFilesDir(null)` yields:
            // /storage/emulated/0/Android/data/{package_name}/files
            return appSpecificVolumePath(context.getExternalFilesDir(null))
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to find primary volume path", e)
        }
        return null
    }

    private fun findVolumePaths(context: Context): Array<String> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val sm = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
            val paths = sm?.storageVolumes?.mapNotNull { it.directory?.path }
            if (paths != null) {
                return paths.map(::ensureTrailingSeparator).toTypedArray()
            }
        }

        // fallback
        val paths = HashSet<String>()
        try {
            // Primary emulated SD-CARD
            val rawEmulatedStorageTarget = System.getenv("EMULATED_STORAGE_TARGET") ?: ""
            if (TextUtils.isEmpty(rawEmulatedStorageTarget)) {
                // fix of empty raw emulated storage on marshmallow
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    lateinit var files: List<File>
                    var validFiles: Boolean
                    val retryInterval = 100L
                    val maxDelay = 1000L
                    var totalDelay = 0L
                    do {
                        // `getExternalFilesDirs` sometimes include `null` when called right after getting read access
                        // (e.g. on API 30 emulator) so we retry until the file system is ready.
                        // It can also include `null` when there is a faulty SD card.
                        val externalFilesDirs = context.getExternalFilesDirs(null)
                        validFiles = !externalFilesDirs.contains(null)
                        if (validFiles) {
                            files = externalFilesDirs.filterNotNull()
                        } else {
                            Log.d(LOG_TAG, "External files dirs contain `null`. Retrying...")
                            totalDelay += retryInterval
                            try {
                                Thread.sleep(retryInterval)
                            } catch (e: InterruptedException) {
                                Log.e(LOG_TAG, "insomnia", e)
                            }
                        }
                    } while (!validFiles && totalDelay < maxDelay)
                    paths.addAll(files.mapNotNull(::appSpecificVolumePath))
                } else {
                    // Primary physical SD-CARD (not emulated)
                    val rawExternalStorage = System.getenv("EXTERNAL_STORAGE") ?: ""

                    // Device has physical external storage; use plain paths.
                    if (TextUtils.isEmpty(rawExternalStorage)) {
                        // EXTERNAL_STORAGE undefined; falling back to default.
                        paths.addAll(physicalPaths)
                    } else {
                        paths.add(rawExternalStorage)
                    }
                }
            } else {
                // Device has emulated storage; external storage paths should have userId burned into them.
                // /storage/emulated/[0,1,2,...]/
                val path = getPrimaryVolumePath(context)
                val rawUserId = path.split(File.separator).lastOrNull(String::isNotEmpty)?.takeIf { TextUtils.isDigitsOnly(it) } ?: ""
                if (rawUserId.isEmpty()) {
                    paths.add(rawEmulatedStorageTarget)
                } else {
                    paths.add(rawEmulatedStorageTarget + File.separator + rawUserId)
                }
            }

            // All Secondary SD-CARDs (all exclude primary) separated by ":"
            System.getenv("SECONDARY_STORAGE")?.let { secondaryStorages ->
                paths.addAll(secondaryStorages.split(File.pathSeparator).filter { it.isNotEmpty() })
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to find volume paths", e)
        }

        return paths.map { ensureTrailingSeparator(it) }.toTypedArray()
    }

    // returns physicalPaths based on phone model
    @SuppressLint("SdCardPath")
    private val physicalPaths = arrayOf(
        "/storage/sdcard0",
        "/storage/sdcard1",                 //Motorola Xoom
        "/storage/extsdcard",               //Samsung SGS3
        "/storage/sdcard0/external_sdcard", //User request
        "/mnt/extsdcard",
        "/mnt/sdcard/external_sd",          //Samsung galaxy family
        "/mnt/external_sd",
        "/mnt/media_rw/sdcard1",            //4.4.2 on CyanogenMod S3
        "/removable/microsd",               //Asus transformer prime
        "/mnt/emmc",
        "/storage/external_SD",             //LG
        "/storage/ext_sd",                  //HTC One Max
        "/storage/removable/sdcard1",       //Sony Xperia Z1
        "/data/sdext",
        "/data/sdext2",
        "/data/sdext3",
        "/data/sdext4",
        "/sdcard1",                         //Sony Xperia Z
        "/sdcard2",                         //HTC One M8s
        "/storage/microsd"                  //ASUS ZenFone 2
    )

    /**
     * Volume tree URIs
     */

    // e.g.
    // /storage/emulated/0/         -> primary
    // /storage/10F9-3F13/Pictures/ -> 10F9-3F13
    // /storage/extSdCard/          -> 1234-5678 [Android 5.1.1, Samsung Galaxy Core Prime]
    private fun getVolumeUuidForDocumentUri(context: Context, anyPath: String): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val sm = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
            sm?.getStorageVolume(File(anyPath))?.let { volume ->
                if (volume.isPrimary) {
                    return EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID
                }
                volume.uuid?.let { uuid ->
                    return uuid.uppercase(Locale.ROOT)
                }
            }
        }

        // fallback for <N
        getVolumePath(context, anyPath)?.let { volumePath ->
            if (volumePath == getPrimaryVolumePath(context)) {
                return EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID
            }
            volumePath.split(File.separator).lastOrNull { it.isNotEmpty() }?.let { uuid ->
                if (uuid.matches(UUID_PATTERN)) {
                    return uuid.uppercase(Locale.ROOT)
                }
            }

            // fallback when UUID does not appear in the SD card volume path
            context.contentResolver.persistedUriPermissions.firstOrNull { uriPermission ->
                convertTreeDocumentUriToDirPath(context, uriPermission.uri)?.let {
                    getVolumePath(context, it)?.let { grantedVolumePath ->
                        grantedVolumePath == volumePath
                    }
                } ?: false
            }?.let { uriPermission ->
                splitTreeDocumentUri(uriPermission.uri)?.let { (uuid, _) ->
                    return uuid
                }
            }
        }

        Log.e(LOG_TAG, "failed to find volume UUID for anyPath=$anyPath")
        return null
    }

    // e.g.
    // primary      -> /storage/emulated/0/
    // 10F9-3F13    -> /storage/10F9-3F13/
    // 1234-5678    -> /storage/extSdCard/ [Android 5.1.1, Samsung Galaxy Core Prime]
    private fun getVolumePathFromTreeDocumentUriUuid(context: Context, uuid: String): String? {
        if (uuid == EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID) {
            return getPrimaryVolumePath(context)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val sm = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
            if (sm != null) {
                for (volumePath in getVolumePaths(context)) {
                    try {
                        val volume = sm.getStorageVolume(File(volumePath))
                        if (volume != null && uuid.equals(volume.uuid, ignoreCase = true)) {
                            return volumePath
                        }
                    } catch (e: Exception) {
                        // ignore
                    }
                }
            }
        }

        // fallback for <N
        for (volumePath in getVolumePaths(context)) {
            val volumeUuid = volumePath.split(File.separator).lastOrNull { it.isNotEmpty() }
            if (uuid.equals(volumeUuid, ignoreCase = true)) {
                return volumePath
            }
        }

        // fallback when UUID does not appear in the SD card volume path
        val primaryVolumePath = getPrimaryVolumePath(context)
        getVolumePaths(context).firstOrNull { volumePath ->
            if (volumePath == primaryVolumePath) {
                false
            } else {
                // exclude volumes that use regular naming scheme with UUID in them
                // to prevent returning path with the UUID of a new volume
                // when the argument is the UUID of an obsolete volume
                val volumeUuid = volumePath.split(File.separator).lastOrNull { it.isNotEmpty() }
                !(volumeUuid == null || volumeUuid.matches(UUID_PATTERN))
            }
        }?.let { return it }

        Log.e(LOG_TAG, "failed to find volume path for UUID=$uuid")
        return null
    }

    // e.g.
    // /storage/emulated/0/         -> content://com.android.externalstorage.documents/tree/primary%3A
    // /storage/10F9-3F13/Pictures/ -> content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures
    fun convertDirPathToTreeDocumentUri(context: Context, dirPath: String): Uri? {
        val uuid = getVolumeUuidForDocumentUri(context, dirPath)
        if (uuid != null) {
            val relativeDir = removeTrailingSeparator(PathSegments(context, dirPath).relativeDir ?: "")
            return DocumentsContract.buildTreeDocumentUri(EXTERNAL_STORAGE_PROVIDER_AUTHORITY, "$uuid:$relativeDir")
        }
        Log.e(LOG_TAG, "failed to convert dirPath=$dirPath to tree document URI")
        return null
    }

    // e.g.
    // /storage/emulated/0/         -> content://com.android.externalstorage.documents/document/primary%3A
    // /storage/10F9-3F13/Pictures/ -> content://com.android.externalstorage.documents/document/10F9-3F13%3APictures
    fun convertDirPathToDocumentUri(context: Context, dirPath: String): Uri? {
        val uuid = getVolumeUuidForDocumentUri(context, dirPath)
        if (uuid != null) {
            val relativeDir = removeTrailingSeparator(PathSegments(context, dirPath).relativeDir ?: "")
            return DocumentsContract.buildDocumentUri(EXTERNAL_STORAGE_PROVIDER_AUTHORITY, "$uuid:$relativeDir")
        }
        Log.e(LOG_TAG, "failed to convert dirPath=$dirPath to document URI")
        return null
    }

    // e.g.
    // content://com.android.externalstorage.documents/tree/primary%3A              -> ("primary", "")
    // content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures    -> ("10F9-3F13", "Pictures")
    private fun splitTreeDocumentUri(treeDocumentUri: Uri): Pair<String, String>? {
        val treeDocumentUriString = treeDocumentUri.toString()
        if (treeDocumentUriString.length <= TREE_URI_ROOT.length) return null
        val encoded = treeDocumentUriString.substring(TREE_URI_ROOT.length)
        val matcher = TREE_URI_PATH_PATTERN.matcher(Uri.decode(encoded))
        with(matcher) {
            if (find()) {
                val uuid = group(1)
                val relativePath = group(2)
                if (uuid != null && relativePath != null) {
                    return Pair(uuid, relativePath)
                }
            }
        }
        Log.e(LOG_TAG, "failed to split treeDocumentUri=$treeDocumentUri to UUID and relative path")
        return null
    }

    // e.g.
    // content://com.android.externalstorage.documents/tree/primary%3A              -> /storage/emulated/0/
    // content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures    -> /storage/10F9-3F13/Pictures/
    fun convertTreeDocumentUriToDirPath(context: Context, treeDocumentUri: Uri): String? {
        splitTreeDocumentUri(treeDocumentUri)?.let { (uuid, relativePath) ->
            val volumePath = getVolumePathFromTreeDocumentUriUuid(context, uuid)
            if (volumePath != null) {
                return ensureTrailingSeparator(volumePath + relativePath)
            }
        }
        Log.e(LOG_TAG, "failed to convert treeDocumentUri=$treeDocumentUri to path")
        return null
    }

    /**
     * Document files
     */

    fun getDocumentFile(context: Context, anyPath: String, mediaUri: Uri): DocumentFileCompat? {
        try {
            if (requireAccessPermission(context, anyPath)) {
                // need a document URI (not a media content URI) to open a `DocumentFile` output stream
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && isMediaStoreContentUri(mediaUri)) {
                    // cleanest API to get it
                    PermissionManager.sanitizePersistedUriPermissions(context)
                    try {
                        val docUri = MediaStore.getDocumentUri(context, mediaUri)
                        if (docUri != null) {
                            return DocumentFileCompat.fromSingleUri(context, docUri)
                        }
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to get document URI for mediaUri=$mediaUri", e)
                    }
                }

                // fallback for older APIs
                val df = getVolumePath(context, anyPath)?.let { convertDirPathToTreeDocumentUri(context, it) }?.let { getDocumentFileFromVolumeTree(context, it, anyPath) }
                if (df != null) return df

                // try to strip user info, if any
                if (mediaUri.userInfo != null) {
                    val genericMediaUri = stripMediaUriUserInfo(mediaUri)
                    Log.d(LOG_TAG, "retry getDocumentFile for mediaUri=$mediaUri without userInfo: $genericMediaUri")
                    return getDocumentFile(context, anyPath, genericMediaUri)
                }
            }
            // good old `File`
            return DocumentFileCompat.fromFile(File(anyPath))
        } catch (e: SecurityException) {
            Log.w(LOG_TAG, "failed to get document file from mediaUri=$mediaUri", e)
        }
        return null
    }

    // returns the directory `DocumentFile` (from tree URI when scoped storage is required, `File` otherwise)
    // returns null if directory does not exist and could not be created
    fun createDirectoryDocIfAbsent(context: Context, dirPath: String): DocumentFileCompat? {
        try {
            val cleanDirPath = ensureTrailingSeparator(dirPath)
            return if (requireAccessPermission(context, cleanDirPath)) {
                val grantedDir = getGrantedDirForPath(context, cleanDirPath) ?: return null
                val rootTreeDocumentUri = convertDirPathToTreeDocumentUri(context, grantedDir) ?: return null
                var parentFile: DocumentFileCompat? = DocumentFileCompat.fromTreeUri(context, rootTreeDocumentUri) ?: return null
                val pathIterator = getPathStepIterator(context, cleanDirPath, grantedDir)
                while (pathIterator?.hasNext() == true) {
                    val dirName = pathIterator.next()
                    var dirFile = findDocumentFileIgnoreCase(parentFile, dirName)
                    if (dirFile == null || !dirFile.exists()) {
                        dirFile = parentFile?.createDirectory(dirName)
                        if (dirFile == null) {
                            Log.e(LOG_TAG, "failed to create directory with name=$dirName from parent=$parentFile")
                            return null
                        }
                    }
                    parentFile = dirFile
                }
                parentFile
            } else {
                val directory = File(cleanDirPath)
                directory.mkdirs()
                if (!directory.exists()) {
                    Log.e(LOG_TAG, "failed to create directories at path=$cleanDirPath")
                    return null
                }
                DocumentFileCompat.fromFile(directory)
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to create directory at path=$dirPath", e)
            return null
        }
    }

    private fun getDocumentFileFromVolumeTree(context: Context, rootTreeDocumentUri: Uri, anyPath: String): DocumentFileCompat? {
        var documentFile: DocumentFileCompat? = DocumentFileCompat.fromTreeUri(context, rootTreeDocumentUri) ?: return null

        // follow the entry path down the document tree
        val pathIterator = getPathStepIterator(context, anyPath, null)
        while (pathIterator?.hasNext() == true) {
            documentFile = findDocumentFileIgnoreCase(documentFile, pathIterator.next()) ?: return null
        }
        return documentFile
    }

    // variation on `DocumentFileCompat.findFile()` to allow case insensitive search
    private fun findDocumentFileIgnoreCase(documentFile: DocumentFileCompat?, displayName: String?): DocumentFileCompat? {
        documentFile ?: return null
        for (doc in documentFile.listFiles()) {
            if (displayName.equals(doc.name, ignoreCase = true)) {
                return doc
            }
        }
        return null
    }

    /**
     * Misc
     */

    fun canEditByFile(context: Context, path: String) = !requireAccessPermission(context, path)

    fun requireAccessPermission(context: Context, anyPath: String): Boolean {
        if (isAppFile(context, anyPath)) return false

        // on Android 11, we should always require access permission, even on primary volume
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q) return true

        val onPrimaryVolume = anyPath.startsWith(getPrimaryVolumePath(context))
        return !onPrimaryVolume
    }

    fun isMediaStoreContentUri(uri: Uri?): Boolean {
        uri ?: return false
        // a URI's authority is [userinfo@]host[:port]
        // but we only want the host when comparing to Media Store's "authority"
        return SCHEME_CONTENT.equals(uri.scheme, ignoreCase = true) && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)
    }

    fun getOriginalUri(context: Context, uri: Uri): Uri {
        // we get a permission denial if we require original from a provider other than the media store
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isMediaStoreContentUri(uri)) {
            val path = uri.path
            path ?: return uri
            // from Android 11 (API 30), accessing the original URI for a `file` or `downloads` media content yields a `SecurityException`
            if (path.startsWith(IMAGE_PATH_ROOT) || path.startsWith(VIDEO_PATH_ROOT)) {
                // "Caller must hold ACCESS_MEDIA_LOCATION permission to access original"
                if (context.checkSelfPermission(Manifest.permission.ACCESS_MEDIA_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    return MediaStore.setRequireOriginal(uri)
                }
            }
        }
        return uri
    }

    // As of Glide v4.12.0, a special loader `QMediaStoreUriLoader` is automatically used
    // to work around a bug from Android 10 (API 29) where metadata redaction corrupts HEIC images.
    // This loader relies on `MediaStore.setRequireOriginal` but this yields a `SecurityException`
    // for some non image/video content URIs (e.g. `downloads`, `file`)
    fun getGlideSafeUri(context: Context, uri: Uri, mimeType: String, sizeBytes: Long? = null): Uri {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isMediaStoreContentUri(uri)) {
            val uriPath = uri.path
            when {
                uriPath?.contains("/downloads/") == true -> {
                    // e.g. `content://media/external_primary/downloads/...`
                    getMediaUriImageVideoUri(uri, mimeType)?.let { imageVideoUri -> return imageVideoUri }
                }

                uriPath?.contains("/file/") == true -> {
                    // e.g. `content://media/external/file/...`
                    // create an ad-hoc temporary file for decoding only
                    createTempFile(context).apply {
                        try {
                            transferFrom(openInputStream(context, uri), sizeBytes)
                            return Uri.fromFile(this)
                        } catch (e: Exception) {
                            Log.e(LOG_TAG, "failed to create temporary file from uri=$uri", e)
                        }
                    }
                }

                uri.userInfo != null -> return stripMediaUriUserInfo(uri)
            }
        }
        return uri
    }

    // requesting access or writing to some MediaStore content URIs
    // yields an exception with `All requested items must be referenced by specific ID`
    fun getMediaStoreScopedStorageSafeUri(uri: Uri, mimeType: String): Uri {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isMediaStoreContentUri(uri)) {
            val uriPath = uri.path
            when {
                uriPath?.contains("/downloads/") == true -> {
                    // e.g. `content://media/external_primary/downloads/...`
                    getMediaUriImageVideoUri(uri, mimeType)?.let { imageVideoUri -> return imageVideoUri }
                }

                uri.userInfo != null -> return stripMediaUriUserInfo(uri)
            }
        }
        return uri
    }

    // Build a typical `images` or `video` content URI from the original content ID.
    // We cannot safely apply this to a `file` content URI, as it may point to a file not indexed
    // by the Media Store (via `.nomedia`), and therefore has no matching image/video content URI.
    private fun getMediaUriImageVideoUri(uri: Uri, mimeType: String): Uri? {
        return uri.tryParseId()?.let { id ->
            return when {
                isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                else -> uri
            }
        }
    }

    // strip user info, if any
    // e.g. `content://0@media/...`
    private fun stripMediaUriUserInfo(uri: Uri) = Uri.parse(uri.toString().replaceFirst("${uri.userInfo}@", ""))

    fun openInputStream(context: Context, uri: Uri): InputStream? {
        val effectiveUri = getOriginalUri(context, uri)
        return try {
            return when (uri.scheme) {
                ContentResolver.SCHEME_FILE -> FileInputStream(uri.path)
                else -> context.contentResolver.openInputStream(effectiveUri)
            }
        } catch (e: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open input stream from effectiveUri=$effectiveUri for uri=$uri", e)
            null
        }
    }

    fun openOutputStream(context: Context, mimeType: String, uri: Uri, mode: String): OutputStream? {
        val effectiveUri = getMediaStoreScopedStorageSafeUri(uri, mimeType)
        return try {
            context.contentResolver.openOutputStream(effectiveUri, mode)
        } catch (e: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open output stream from effectiveUri=$effectiveUri for uri=$uri mode=$mode", e)
            null
        }
    }

    fun openInputFileDescriptor(context: Context, uri: Uri): ParcelFileDescriptor? {
        val effectiveUri = getOriginalUri(context, uri)
        return try {
            context.contentResolver.openFileDescriptor(effectiveUri, "r")
        } catch (e: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open input file descriptor from effectiveUri=$effectiveUri for uri=$uri", e)
            null
        }
    }

    fun openOutputFileDescriptor(context: Context, mimeType: String, uri: Uri, path: String, mode: String): ParcelFileDescriptor? {
        val effectiveUri = if (ImageProvider.isMediaUriPermissionGranted(context, uri, mimeType)) {
            getMediaStoreScopedStorageSafeUri(uri, mimeType)
        } else {
            getDocumentFile(context, path, uri)?.uri ?: throw Exception("failed to get document file for path=$path, uri=$uri")
        }
        return try {
            context.contentResolver.openFileDescriptor(effectiveUri, mode)
        } catch (e: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open output file descriptor from effectiveUri=$effectiveUri for uri=$uri path=$path", e)
            null
        }
    }

    fun openMetadataRetriever(context: Context, uri: Uri): MediaMetadataRetriever? {
        val effectiveUri = getOriginalUri(context, uri)
        return try {
            MediaMetadataRetriever().apply {
                // on Android 12 preview, setting the data source works but yields an internal IOException
                // (`Input file descriptor already original`), whether we provide the original URI or not
                setDataSource(context, effectiveUri)
            }
        } catch (e: Exception) {
            // unsupported format
            Log.w(LOG_TAG, "failed to initialize MediaMetadataRetriever for uri=$uri effectiveUri=$effectiveUri")
            null
        }
    }

    private fun getTempDirectory(context: Context): File = File(context.cacheDir, "temp")

    fun createTempFile(context: Context, extension: String? = null): File {
        val directory = getTempDirectory(context)
        directory.mkdirs()
        if (!directory.exists()) {
            throw IOException("failed to create directories at path=$directory")
        }
        val tempFile = File.createTempFile("aves", extension, directory)
        // `deleteOnExit` is unreliable, but it does not hurt
        tempFile.deleteOnExit()
        return tempFile
    }

    fun deleteTempDirectory(context: Context): Boolean {
        val directory = getTempDirectory(context)
        if (!directory.exists()) return false
        return directory.deleteRecursively()
    }

    // convenience methods

    fun getFolderSize(f: File): Long {
        var size: Long = 0
        if (f.isDirectory) {
            for (file in f.listFiles()!!) {
                size += getFolderSize(file)
            }
        } else {
            size = f.length()
        }
        return size
    }

    fun ensureTrailingSeparator(dirPath: String): String {
        return if (dirPath.endsWith(File.separator)) dirPath else dirPath + File.separator
    }

    fun removeTrailingSeparator(dirPath: String): String {
        return if (dirPath.endsWith(File.separator)) dirPath.substring(0, dirPath.length - 1) else dirPath
    }

    // `fullPath` should match "volumePath + relativeDir + fileName"
    class PathSegments(context: Context, fullPath: String) {
        var volumePath: String? = null // `volumePath` with trailing "/"
        var relativeDir: String? = null // `relativeDir` with trailing "/"
        private var fileName: String? = null // null for directories

        init {
            volumePath = getVolumePath(context, fullPath)
            if (volumePath != null) {
                val lastSeparatorIndex = fullPath.lastIndexOf(File.separator) + 1
                val volumePathLength = volumePath!!.length
                if (lastSeparatorIndex > volumePathLength) {
                    fileName = fullPath.substring(lastSeparatorIndex)
                    relativeDir = fullPath.substring(volumePathLength, lastSeparatorIndex)
                }
            }
        }
    }
}