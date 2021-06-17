package deckers.thibault.aves.utils

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import androidx.annotation.RequiresApi
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.utils.PermissionManager.getGrantedDirForPath
import java.io.File
import java.io.FileNotFoundException
import java.io.InputStream
import java.util.*
import java.util.regex.Pattern

object StorageUtils {
    private val LOG_TAG = LogUtils.createTag<StorageUtils>()

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
        if (mStorageVolumePaths == null) {
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

    private fun findPrimaryVolumePath(context: Context): String? {
        // we want:
        // /storage/emulated/0/
        // `Environment.getExternalStorageDirectory()` (deprecated) yields:
        // /storage/emulated/0
        // `context.getExternalFilesDir(null)` yields:
        // /storage/emulated/0/Android/data/{package_name}/files
        return context.getExternalFilesDir(null)?.let {
            val appSpecificPath = it.absolutePath
            return appSpecificPath.substring(0, appSpecificPath.indexOf("Android/data"))
        }
    }

    @SuppressLint("ObsoleteSdkInt")
    private fun findVolumePaths(context: Context): Array<String> {
        // Final set of paths
        val paths = HashSet<String>()

        // Primary emulated SD-CARD
        val rawEmulatedStorageTarget = System.getenv("EMULATED_STORAGE_TARGET") ?: ""
        if (TextUtils.isEmpty(rawEmulatedStorageTarget)) {
            // fix of empty raw emulated storage on marshmallow
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                lateinit var files: List<File>
                var validFiles: Boolean
                do {
                    // `getExternalFilesDirs` sometimes include `null` when called right after getting read access
                    // (e.g. on API 30 emulator) so we retry until the file system is ready
                    val externalFilesDirs = context.getExternalFilesDirs(null)
                    validFiles = !externalFilesDirs.contains(null)
                    if (validFiles) {
                        files = externalFilesDirs.filterNotNull()
                    } else {
                        try {
                            Thread.sleep(100)
                        } catch (e: InterruptedException) {
                            Log.e(LOG_TAG, "insomnia", e)
                        }
                    }
                } while (!validFiles)
                for (file in files) {
                    val appSpecificAbsolutePath = file.absolutePath
                    val emulatedRootPath = appSpecificAbsolutePath.substring(0, appSpecificAbsolutePath.indexOf("Android/data"))
                    paths.add(emulatedRootPath)
                }
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
    private fun getVolumeUuidForTreeUri(context: Context, anyPath: String): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.getSystemService(StorageManager::class.java)?.let { sm ->
                sm.getStorageVolume(File(anyPath))?.let { volume ->
                    if (volume.isPrimary) {
                        return "primary"
                    }
                    volume.uuid?.let { uuid ->
                        return uuid.uppercase(Locale.ROOT)
                    }
                }
            }
        }

        // fallback for <N
        getVolumePath(context, anyPath)?.let { volumePath ->
            if (volumePath == getPrimaryVolumePath(context)) {
                return "primary"
            }
            volumePath.split(File.separator).lastOrNull { it.isNotEmpty() }?.let { uuid ->
                return uuid.uppercase(Locale.ROOT)
            }
        }

        Log.e(LOG_TAG, "failed to find volume UUID for anyPath=$anyPath")
        return null
    }

    // e.g.
    // primary      -> /storage/emulated/0/
    // 10F9-3F13    -> /storage/10F9-3F13/
    private fun getVolumePathFromTreeUriUuid(context: Context, uuid: String): String? {
        if (uuid == "primary") {
            return getPrimaryVolumePath(context)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.getSystemService(StorageManager::class.java)?.let { sm ->
                for (volumePath in getVolumePaths(context)) {
                    try {
                        val volume = sm.getStorageVolume(File(volumePath))
                        if (volume != null && uuid.equals(volume.uuid, ignoreCase = true)) {
                            return volumePath
                        }
                    } catch (e: IllegalArgumentException) {
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

        Log.e(LOG_TAG, "failed to find volume path for UUID=$uuid")
        return null
    }

    // e.g.
    // /storage/emulated/0/         -> content://com.android.externalstorage.documents/tree/primary%3A
    // /storage/10F9-3F13/Pictures/ -> content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun convertDirPathToTreeUri(context: Context, dirPath: String): Uri? {
        val uuid = getVolumeUuidForTreeUri(context, dirPath)
        if (uuid != null) {
            var relativeDir = PathSegments(context, dirPath).relativeDir ?: ""
            if (relativeDir.endsWith(File.separator)) {
                relativeDir = relativeDir.substring(0, relativeDir.length - 1)
            }
            return DocumentsContract.buildTreeDocumentUri("com.android.externalstorage.documents", "$uuid:$relativeDir")
        }
        Log.e(LOG_TAG, "failed to convert dirPath=$dirPath to tree URI")
        return null
    }

    // e.g.
    // content://com.android.externalstorage.documents/tree/primary%3A              -> /storage/emulated/0/
    // content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures    -> /storage/10F9-3F13/Pictures/
    fun convertTreeUriToDirPath(context: Context, treeUri: Uri): String? {
        val encoded = treeUri.toString().substring("content://com.android.externalstorage.documents/tree/".length)
        val matcher = Pattern.compile("(.*?):(.*)").matcher(Uri.decode(encoded))
        with(matcher) {
            if (find()) {
                val uuid = group(1)
                val relativePath = group(2)
                if (uuid != null && relativePath != null) {
                    val volumePath = getVolumePathFromTreeUriUuid(context, uuid)
                    if (volumePath != null) {
                        return ensureTrailingSeparator(volumePath + relativePath)
                    }
                }
            }
        }
        Log.e(LOG_TAG, "failed to convert treeUri=$treeUri to path")
        return null
    }

    /**
     * Document files
     */

    fun getDocumentFile(context: Context, anyPath: String, mediaUri: Uri): DocumentFileCompat? {
        try {
            if (requireAccessPermission(context, anyPath) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // need a document URI (not a media content URI) to open a `DocumentFile` output stream
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && isMediaStoreContentUri(mediaUri)) {
                    // cleanest API to get it
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
                val df = getVolumePath(context, anyPath)?.let { convertDirPathToTreeUri(context, it) }?.let { getDocumentFileFromVolumeTree(context, it, anyPath) }
                if (df != null) return df

                // try to strip user info, if any
                if (mediaUri.userInfo != null) {
                    val genericMediaUri = Uri.parse(mediaUri.toString().replaceFirst("${mediaUri.userInfo}@", ""))
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
    fun createDirectoryIfAbsent(context: Context, dirPath: String): DocumentFileCompat? {
        val cleanDirPath = ensureTrailingSeparator(dirPath)
        return if (requireAccessPermission(context, cleanDirPath) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val grantedDir = getGrantedDirForPath(context, cleanDirPath) ?: return null
            val rootTreeUri = convertDirPathToTreeUri(context, grantedDir) ?: return null
            var parentFile: DocumentFileCompat? = DocumentFileCompat.fromTreeUri(context, rootTreeUri) ?: return null
            val pathIterator = getPathStepIterator(context, cleanDirPath, grantedDir)
            while (pathIterator?.hasNext() == true) {
                val dirName = pathIterator.next()
                var dirFile = findDocumentFileIgnoreCase(parentFile, dirName)
                if (dirFile == null || !dirFile.exists()) {
                    try {
                        dirFile = parentFile?.createDirectory(dirName)
                        if (dirFile == null) {
                            Log.e(LOG_TAG, "failed to create directory with name=$dirName from parent=$parentFile")
                            return null
                        }
                    } catch (e: FileNotFoundException) {
                        Log.e(LOG_TAG, "failed to create directory with name=$dirName from parent=$parentFile", e)
                        return null
                    }
                }
                parentFile = dirFile
            }
            parentFile
        } else {
            val directory = File(cleanDirPath)
            if (!directory.exists() && !directory.mkdirs()) {
                Log.e(LOG_TAG, "failed to create directories at path=$cleanDirPath")
                return null
            }
            DocumentFileCompat.fromFile(directory)
        }
    }

    private fun getDocumentFileFromVolumeTree(context: Context, rootTreeUri: Uri, anyPath: String): DocumentFileCompat? {
        var documentFile: DocumentFileCompat? = DocumentFileCompat.fromTreeUri(context, rootTreeUri) ?: return null

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

    fun requireAccessPermission(context: Context, anyPath: String): Boolean {
        // on Android R, we should always require access permission, even on primary volume
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q) {
            return true
        }
        val onPrimaryVolume = anyPath.startsWith(getPrimaryVolumePath(context))
        return !onPrimaryVolume
    }

    private fun isMediaStoreContentUri(uri: Uri?): Boolean {
        uri ?: return false
        // a URI's authority is [userinfo@]host[:port]
        // but we only want the host when comparing to Media Store's "authority"
        return ContentResolver.SCHEME_CONTENT.equals(uri.scheme, ignoreCase = true) && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)
    }

    fun getOriginalUri(uri: Uri): Uri {
        // we get a permission denial if we require original from a provider other than the media store
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isMediaStoreContentUri(uri)) {
            val path = uri.path
            path ?: return uri
            // from Android R, accessing the original URI for a file media content yields a `SecurityException`
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R || path.startsWith("/external/images/") || path.startsWith("/external/video/")) {
                return MediaStore.setRequireOriginal(uri)
            }
        }
        return uri
    }

    fun openInputStream(context: Context, uri: Uri): InputStream? {
        val effectiveUri = getOriginalUri(uri)
        return try {
            context.contentResolver.openInputStream(effectiveUri)
        } catch (e: FileNotFoundException) {
            Log.w(LOG_TAG, "failed to find file at uri=$effectiveUri")
            null
        } catch (e: SecurityException) {
            Log.w(LOG_TAG, "failed to open file at uri=$effectiveUri", e)
            null
        }
    }

    fun openMetadataRetriever(context: Context, uri: Uri): MediaMetadataRetriever? {
        val effectiveUri = getOriginalUri(uri)
        return try {
            MediaMetadataRetriever().apply {
                setDataSource(context, effectiveUri)
            }
        } catch (e: Exception) {
            // unsupported format
            null
        }
    }

    // convenience methods

    fun ensureTrailingSeparator(dirPath: String): String {
        return if (dirPath.endsWith(File.separator)) dirPath else dirPath + File.separator
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