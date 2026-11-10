package deckers.thibault.aves.storage

import android.content.ContentResolver
import android.content.Context
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
import androidx.core.text.isDigitsOnly
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.model.ContentProviderCrash
import deckers.thibault.aves.model.FileDescriptorException
import deckers.thibault.aves.model.OutputStreamException
import deckers.thibault.aves.model.ReadOnlyFileSystemException
import deckers.thibault.aves.storage.apis.FilePermissions
import deckers.thibault.aves.storage.apis.MediaStorePermissions
import deckers.thibault.aves.storage.apis.SafPermissions
import deckers.thibault.aves.utils.FileUtils.copyFrom
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.UriUtils.isDataScheme
import deckers.thibault.aves.utils.UriUtils.isFileScheme
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.Locale
import java.util.regex.Pattern
import kotlin.io.encoding.Base64

object StorageUtils {
    private val LOG_TAG = LogUtils.createTag<StorageUtils>()

    // cf DocumentsContract.EXTERNAL_STORAGE_PROVIDER_AUTHORITY
    private const val EXTERNAL_STORAGE_PROVIDER_AUTHORITY = "com.android.externalstorage.documents"

    // cf DocumentsContract.EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID
    private const val EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID = "primary"

    private const val TREE_URI_ROOT = "${ContentResolver.SCHEME_CONTENT}://$EXTERNAL_STORAGE_PROVIDER_AUTHORITY/tree/"

    private const val DATA_URI_BASE64_SEPARATOR = ";base64,"
    private val UUID_PATTERN = Regex("[A-Fa-f\\d-]+")
    private val TREE_URI_PATH_PATTERN = Pattern.compile("(.*?):(.*)")

    const val TRASH_PATH_PLACEHOLDER = "#trash"

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

    fun isInVault(context: Context, anyPath: String) = anyPath.startsWith(getVaultRoot(context))

    fun getAvesAppDirectories(context: Context): Set<String> {
        return hashSetOf<File>().apply {
            // /storage/{volume}/Android/data/{aves_application_id}/files
            addAll(context.getExternalFilesDirs(null).filterNotNull())
            // /data/user/0/{aves_application_id}/files
            add(context.filesDir)
        }.map { ensureTrailingSeparator(it.path) }.toSet()
    }

    fun isInAvesAppStorage(context: Context, anyPath: String): Boolean {
        val dirs = getAvesAppDirectories(context)
        return dirs.any { anyPath.startsWith(it) }
    }

    fun getAppMediaRootDirectories(context: Context): Set<String> {
        // roots to paths like `/storage/{volume}/Android/media/{any_application_id}/`
        @Suppress("DEPRECATION")
        return context.externalMediaDirs.filterNotNull().mapNotNull { it.parentFile?.path }.map { ensureTrailingSeparator(it) }.toSet()
    }

    fun isInAppMediaStorage(context: Context, anyPath: String): Boolean {
        val dirs = getAppMediaRootDirectories(context)
        return dirs.any { anyPath.startsWith(it) }
    }

    /**
     * Volume paths
     */

    // volume paths, with trailing "/"
    private var mStorageVolumePaths = listOf<String>()

    // primary volume path, with trailing "/"
    private var mPrimaryVolumePath: String? = null

    fun getPrimaryVolumePath(context: Context): String {
        if (mPrimaryVolumePath == null) {
            mPrimaryVolumePath = findPrimaryVolumePath(context)
        }
        return mPrimaryVolumePath!!
    }

    fun getVolumePaths(context: Context): List<String> {
        if (mStorageVolumePaths.isEmpty()) {
            mStorageVolumePaths = findVolumePaths(context)
        }
        return mStorageVolumePaths
    }

    fun getVolumePath(context: Context, anyPath: String): String? {
        return getVolumePaths(context).firstOrNull { anyPath.startsWith(it) }
    }

    private fun getPathStepIterator(anyPath: String, root: String): Iterator<String?>? {
        val rootLength = root.length

        var fileName: String? = null
        var relativePath: String? = null
        val lastSeparatorIndex = anyPath.lastIndexOf(File.separator) + 1
        if (lastSeparatorIndex >= rootLength) {
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
        return appSpecificPath.take(relativePathStartIndex)
    }

    private fun findPrimaryVolumePath(context: Context): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
            val path = storageManager?.primaryStorageVolume?.directory?.path
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
            // /storage/emulated/0/Android/data/{application_id}/files
            return appSpecificVolumePath(context.getExternalFilesDir(null))
        } catch (ex: Exception) {
            Log.e(LOG_TAG, "failed to find primary volume path", ex)
        }
        return null
    }

    private fun findVolumePaths(context: Context): List<String> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
            val paths = storageManager?.storageVolumes?.mapNotNull { it.directory?.path }
            if (paths != null) {
                return paths.map(::ensureTrailingSeparator).toList()
            }
        }

        // fallback
        val paths = HashSet<String>()
        try {
            // Primary emulated SD-CARD
            val rawEmulatedStorageTarget = System.getenv("EMULATED_STORAGE_TARGET") ?: ""
            if (TextUtils.isEmpty(rawEmulatedStorageTarget)) {
                // fix of empty raw emulated storage on marshmallow
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
                        } catch (ex: InterruptedException) {
                            Log.e(LOG_TAG, "insomnia", ex)
                        }
                    }
                } while (!validFiles && totalDelay < maxDelay)
                paths.addAll(files.mapNotNull(::appSpecificVolumePath))
            } else {
                // Device has emulated storage; external storage paths should have userId burned into them.
                // /storage/emulated/[0,1,2,...]/
                val path = getPrimaryVolumePath(context)
                val rawUserId = path.split(File.separator).lastOrNull(String::isNotEmpty)?.takeIf { it.isDigitsOnly() } ?: ""
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
        } catch (ex: Exception) {
            Log.e(LOG_TAG, "failed to find volume paths", ex)
        }

        return paths.map { ensureTrailingSeparator(it) }.toList()
    }

    /**
     * Volume tree URIs
     */

    // e.g.
    // /storage/emulated/0/         -> primary
    // /storage/10F9-3F13/Pictures/ -> 10F9-3F13
    // /storage/extSdCard/          -> 1234-5678 [Android 5.1.1, Samsung Galaxy Core Prime]
    private fun getVolumeUuidForDocumentUri(context: Context, anyPath: String): String? {
        val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
        storageManager?.getStorageVolume(File(anyPath))?.let { volume ->
            if (volume.isPrimary) {
                return EXTERNAL_STORAGE_PRIMARY_EMULATED_ROOT_ID
            }
            volume.uuid?.let { uuid ->
                return uuid.uppercase(Locale.ROOT)
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
            SafPermissions.getPersistedUriPermissions(context).firstOrNull { uriPermission ->
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

        val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
        if (storageManager != null) {
            for (volumePath in getVolumePaths(context)) {
                try {
                    val volume = storageManager.getStorageVolume(File(volumePath))
                    if (volume != null && uuid.equals(volume.uuid, ignoreCase = true)) {
                        return volumePath
                    }
                } catch (_: Exception) {
                    // ignore
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

    fun getDocumentFileForExistingFile(context: Context, filePath: String, mediaUri: Uri): DocumentFileCompat? {
        try {
            if (!FilePermissions.canEdit(context, filePath)) {
                // need a document URI (not a media content URI) to open a `DocumentFile` output stream
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && MediaStoreUriHelper.isMediaStoreContentUri(mediaUri)) {
                    // cleanest API to get it
                    SafPermissions.sanitizePersistedUriPermissions(context)
                    try {
                        val docUri = MediaStore.getDocumentUri(context, mediaUri)
                        if (docUri != null) {
                            return DocumentFileCompat.fromSingleUri(context, docUri)
                        }
                    } catch (ex: Exception) {
                        Log.w(LOG_TAG, "failed to get document URI for mediaUri=$mediaUri", ex)
                    }
                }

                val docFile = getDocumentFileByTreeDoc(context, filePath)
                if (docFile != null) return docFile

                // try to strip user info, if any
                if (mediaUri.userInfo != null) {
                    val genericMediaUri = MediaStoreUriHelper.stripMediaUriUserInfo(mediaUri)
                    Log.d(LOG_TAG, "retry getDocumentFile for mediaUri=$mediaUri without userInfo: $genericMediaUri")
                    return getDocumentFileForExistingFile(context, filePath = filePath, mediaUri = genericMediaUri)
                }
            }

            // good old `File`
            return DocumentFileCompat.fromFile(File(filePath))
        } catch (ex: SecurityException) {
            Log.w(LOG_TAG, "failed to get document file from mediaUri=$mediaUri", ex)
        }
        return null
    }

    fun getDocumentFileForNewFile(context: Context, filePath: String, mimeType: String): DocumentFileCompat? {
        try {
            if (!FilePermissions.canEdit(context, filePath)) {
                val docFile = getOrCreateDocumentFileByTreeDoc(context, anyPath = filePath) { parentFile, displayName ->
                    parentFile?.createFile(mimeType, displayName)
                }
                if (docFile != null) return docFile
            }

            // good old `File`
            return DocumentFileCompat.fromFile(File(filePath))
        } catch (ex: SecurityException) {
            Log.w(LOG_TAG, "failed to get document file for filePath=$filePath", ex)
        }
        return null
    }

    // returns the directory `DocumentFile` (from tree URI when scoped storage is required, `File` otherwise)
    // returns null if directory does not exist and could not be created
    fun createDirectoryDocIfAbsent(context: Context, dirPath: String): DocumentFileCompat? {
        try {
            val targetDirPath = ensureTrailingSeparator(dirPath)
            return when {
                FilePermissions.canEdit(context, targetDirPath) -> createDirectoryDocByFile(targetDirPath)
                else -> getOrCreateDocumentFileByTreeDoc(context, anyPath = targetDirPath) { parentFile, displayName ->
                    parentFile?.createDirectory(displayName)
                }
            }
        } catch (ex: Exception) {
            Log.e(LOG_TAG, "failed to create directory at path=$dirPath", ex)
            return null
        }
    }

    private fun createDirectoryDocByFile(dirPath: String): DocumentFileCompat? {
        val directory = File(dirPath)
        directory.mkdirs()
        if (!directory.exists()) {
            Log.e(LOG_TAG, "failed to create directories at path=$dirPath")
            return null
        }
        return DocumentFileCompat.fromFile(directory)
    }

    private fun getDocumentFileByTreeDoc(
        context: Context,
        anyPath: String,
    ): DocumentFileCompat? = getOrCreateDocumentFileByTreeDoc(context, anyPath, null)

    private fun getOrCreateDocumentFileByTreeDoc(
        context: Context,
        anyPath: String,
        create: ((parentFile: DocumentFileCompat?, displayName: String?) -> DocumentFileCompat?)?,
    ): DocumentFileCompat? {
        val grantedDir = PermissionManager.getAccessibleDirs(context).firstOrNull { anyPath.startsWith(it) } ?: return null
        val rootTreeDocumentUri = convertDirPathToTreeDocumentUri(context, grantedDir) ?: return null

        var parentFile: DocumentFileCompat? = DocumentFileCompat.fromTreeUri(context, rootTreeDocumentUri) ?: return null
        var currentPath = ensureTrailingSeparator(grantedDir)
        val pathIterator = getPathStepIterator(anyPath = anyPath, root = grantedDir)

        while (pathIterator?.hasNext() == true) {
            val displayName = pathIterator.next()
            var treeDocFile = findDocumentFileIgnoreCase(parentFile, displayName)
            currentPath = ensureTrailingSeparator(currentPath + displayName)

            if (treeDocFile == null && File(currentPath).exists()) {
                // `DocumentsProvider` may be temporarily buggy and fail to list children directories.
                // Better to fail fast and revoke directory access, so that the user is aware
                // of the issue when trying again with `ACTION_OPEN_DOCUMENT_TREE`.
                // Otherwise, we would try to recreate the existing (but unlisted) directory,
                // and the document provider will create a new one with a "(1)" suffix.
                Log.e(LOG_TAG, "failed to get document file for existing path=$currentPath from granted dir=$grantedDir. Revoking granted dir...")
                SafPermissions.revokeDirectoryAccess(context, grantedDir)
                throw Exception("failed to get document file for existing path=$currentPath from grantedDir=$grantedDir")
            }

            if (treeDocFile == null || !treeDocFile.exists()) {
                treeDocFile = create?.invoke(parentFile, displayName)
                if (treeDocFile == null) {
                    Log.e(LOG_TAG, "failed to create tree document file with name=$displayName from parent=$parentFile")
                    return null
                }
            }
            parentFile = treeDocFile
        }
        return parentFile
    }

    // variation on `DocumentFileCompat.findFile()` to allow case-insensitive search
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

    fun isInDownloadPath(context: Context, anyPath: String): Boolean {
        val volumePath = getVolumePath(context, anyPath) ?: return false
        val downloadDirPath = ensureTrailingSeparator(File(volumePath, Environment.DIRECTORY_DOWNLOADS).path)
        // effective download path may have a different case
        return anyPath.lowercase().startsWith(downloadDirPath.lowercase())
    }

    // As of Glide v4.12.0, a special loader `QMediaStoreUriLoader` is automatically used
    // to work around a bug from Android 10 (API 29) where metadata redaction corrupts HEIC images.
    // This loader relies on `MediaStore.setRequireOriginal` but this yields a `SecurityException`
    // for some non image/video content URIs (e.g. `downloads`, `file`)
    fun getGlideSafeUri(context: Context, contentAddress: ContentAddress, sizeBytes: Long? = null): Uri {
        val mimeType = contentAddress.mimeType
        val uri = contentAddress.uri

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && MediaStoreUriHelper.isMediaStoreContentUri(uri)) {
            val uriPath = uri.path
            when {
                uriPath?.contains("/downloads/") == true -> {
                    // e.g. `content://media/external_primary/downloads/...`
                    MediaStoreUriHelper.getMediaUri(uri, mimeType)?.let { imageVideoUri -> return imageVideoUri }
                }

                uriPath?.contains("/file/") == true -> {
                    // e.g. `content://media/external/file/...`
                    // create an ad-hoc temporary file for decoding only
                    try {
                        return Uri.fromFile(createTempFile(context, uri, sizeBytes))
                    } catch (ex: Exception) {
                        Log.e(LOG_TAG, "failed to create temporary file from uri=$uri", ex)
                    }
                }

                uri.userInfo != null -> return MediaStoreUriHelper.stripMediaUriUserInfo(uri)
            }
        }
        return uri
    }

    fun getSafeInputUri(context: Context, uri: Uri): Uri {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && MediaStoreUriHelper.isMediaStoreContentUri(uri)) {
            return MediaStoreUriHelper.sanitizeInputUri(context, uri)
        }
        return uri
    }

    fun getSafeOutputUri(context: Context, contentAddress: ContentAddress): Uri {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && MediaStoreUriHelper.isMediaStoreContentUri(contentAddress.uri)) {
            return MediaStoreUriHelper.sanitizeOutputUri(context, contentAddress)
        }
        return contentAddress.uri
    }

    fun openInputStream(context: Context, uri: Uri): InputStream? {
        val safeUri = getSafeInputUri(context, uri)
        return try {
            return if (uri.isFileScheme) {
                FileInputStream(uri.path)
            } else if (uri.isDataScheme) {
                val uriString = uri.toString()
                val index = uriString.indexOf(DATA_URI_BASE64_SEPARATOR)
                if (index == -1) throw Exception("unsupported data URI encoding for uri=$uri")
                Base64.decode(uriString, index + DATA_URI_BASE64_SEPARATOR.length).inputStream()
            } else {
                context.contentResolver.openInputStream(safeUri)
            }
        } catch (ex: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open input stream from safeUri=$safeUri for uri=$uri", ex)
            null
        }
    }

    fun openOutputStream(context: Context, contentAddress: ContentAddress, mode: String): OutputStream {
        val safeUri = getSafeOutputUri(context, contentAddress)
        return try {
            context.contentResolver.openOutputStream(safeUri, mode) ?: throw ContentProviderCrash(
                "failed to open output stream because provider recently crashed" +
                        ", from mode=$mode safeUri=$safeUri for $contentAddress"
            )
        } catch (ex: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            when (ex) {
                is FileNotFoundException if (ex.message ?: "").startsWith("open failed: EROFS (Read-only file system)") -> {
                    throw ReadOnlyFileSystemException("failed to open output stream from mode=$mode safeUri=$safeUri for $contentAddress", ex)
                }

                is ContentProviderCrash -> throw ex
                else -> throw OutputStreamException("failed to open output stream from mode=$mode safeUri=$safeUri for $contentAddress", ex)
            }
        }
    }

    fun openInputFileDescriptor(context: Context, uri: Uri): ParcelFileDescriptor? {
        val safeUri = getSafeInputUri(context, uri)
        return try {
            context.contentResolver.openFileDescriptor(safeUri, "r")
        } catch (ex: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open input file descriptor from safeUri=$safeUri for uri=$uri", ex)
            throw FileDescriptorException("failed to open input file descriptor from safeUri=$safeUri for uri=$uri", ex)
        }
    }

    fun openOutputFileDescriptor(context: Context, contentAddress: ContentAddress, mode: String): ParcelFileDescriptor? {
        val safeUri = if (MediaStorePermissions.canEdit(context, contentAddress)) {
            getSafeOutputUri(context, contentAddress)
        } else {
            val uri = contentAddress.uri
            val path = contentAddress.path ?: throw IllegalArgumentException("null path for $contentAddress")
            getDocumentFileForExistingFile(context, filePath = path, mediaUri = uri)?.uri ?: throw Exception("failed to get document file for $contentAddress")
        }
        return try {
            context.contentResolver.openFileDescriptor(safeUri, mode)
        } catch (ex: Exception) {
            // among various other exceptions,
            // opening a file marked pending and owned by another package throws an `IllegalStateException`
            Log.w(LOG_TAG, "failed to open output file descriptor from safeUri=$safeUri for $contentAddress", ex)
            throw FileDescriptorException("failed to open output file descriptor from safeUri=$safeUri for $contentAddress", ex)
        }
    }

    fun openMetadataRetriever(context: Context, contentAddress: ContentAddress): MediaMetadataRetriever? {
        val safeUri = getSafeInputUri(context, contentAddress.uri)
        return try {
            MediaMetadataRetriever().apply {
                // on Android 12 preview, setting the data source works but yields an internal IOException
                // (`Input file descriptor already original`), whether we provide the original URI or not
                setDataSource(context, safeUri)
            }
        } catch (_: Exception) {
            // unsupported format
            Log.w(LOG_TAG, "failed to initialize MediaMetadataRetriever for effectiveUri=$safeUri $contentAddress")
            null
        }
    }

    private fun getTempDirectory(context: Context): File = File(context.cacheDir, "temp")

    fun createTempFile(context: Context): File {
        val directory = getTempDirectory(context)
        directory.mkdirs()
        if (!directory.exists()) {
            throw IOException("failed to create directories at path=$directory")
        }
        val tempFile = File.createTempFile("aves", null, directory)
        // `deleteOnExit` is unreliable, but it does not hurt
        tempFile.deleteOnExit()
        return tempFile
    }

    // auto closes the provided input stream
    fun createTempFile(context: Context, inputStream: InputStream?, streamLength: Long?): File {
        return createTempFile(context).apply {
            copyFrom(inputStream, streamLength)
        }
    }

    fun createTempFile(context: Context, uri: Uri, streamLength: Long?): File {
        return createTempFile(context, openInputStream(context, uri), streamLength)
    }

    fun createTempFile(context: Context, bytes: ByteArray): File {
        return createTempFile(context, ByteArrayInputStream(bytes), bytes.size.toLong())
    }

    fun deleteTempDirectory(context: Context): Boolean {
        val directory = getTempDirectory(context)
        return directory.exists() && directory.deleteRecursively()
    }

    // convenience methods

    fun ensureTrailingSeparator(dirPath: String): String {
        return if (dirPath.endsWith(File.separator)) dirPath else dirPath + File.separator
    }

    fun removeTrailingSeparator(dirPath: String): String {
        return if (dirPath.endsWith(File.separator)) dirPath.dropLast(1) else dirPath
    }
}
