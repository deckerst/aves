package deckers.thibault.aves.utils

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import android.webkit.MimeTypeMap
import com.commonsware.cwac.document.DocumentFileCompat
import deckers.thibault.aves.utils.LogUtils.createTag
import deckers.thibault.aves.utils.PermissionManager.getGrantedDirForPath
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream
import java.util.*
import java.util.regex.Pattern

object StorageUtils {
    private val LOG_TAG = createTag(StorageUtils::class.java)

    /**
     * Volume paths
     */

    // volume paths, with trailing "/"
    private var mStorageVolumePaths: Array<String>? = null

    // primary volume path, with trailing "/"
    private var mPrimaryVolumePath: String? = null

    val primaryVolumePath: String
        get() {
            if (mPrimaryVolumePath == null) {
                mPrimaryVolumePath = findPrimaryVolumePath()
            }
            return mPrimaryVolumePath!!
        }

    @JvmStatic
    fun getVolumePaths(context: Context): Array<String> {
        if (mStorageVolumePaths == null) {
            mStorageVolumePaths = findVolumePaths(context)
        }
        return mStorageVolumePaths!!
    }

    @JvmStatic
    fun getVolumePath(context: Context, anyPath: String): String? {
        return getVolumePaths(context).firstOrNull { anyPath.startsWith(it) }
    }

    private fun getPathStepIterator(context: Context, anyPath: String, root: String?): Iterator<String?>? {
        val rootLength = (root ?: getVolumePath(context, anyPath))?.length ?: return null

        var filename: String? = null
        var relativePath: String? = null
        val lastSeparatorIndex = anyPath.lastIndexOf(File.separator) + 1
        if (lastSeparatorIndex > rootLength) {
            filename = anyPath.substring(lastSeparatorIndex)
            relativePath = anyPath.substring(rootLength, lastSeparatorIndex)
        }
        relativePath ?: return null

        val pathSteps = relativePath.split(File.separator).filter { it.isNotEmpty() }.toMutableList()
        if (filename?.isNotEmpty() == true) {
            pathSteps.add(filename)
        }
        return pathSteps.iterator()
    }

    private fun findPrimaryVolumePath(): String {
        return ensureTrailingSeparator(Environment.getExternalStorageDirectory().absolutePath)
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
            val path = Environment.getExternalStorageDirectory().absolutePath
            val rawUserId = path.split(File.separator).lastOrNull()?.takeIf { TextUtils.isDigitsOnly(it) } ?: ""
            // /storage/emulated/0[1,2,...]
            if (TextUtils.isEmpty(rawUserId)) {
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

    // return physicalPaths based on phone model
    private val physicalPaths: Array<String>
        @SuppressLint("SdCardPath")
        get() = arrayOf(
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

    private fun getVolumeUuidForTreeUri(context: Context, anyPath: String): String? {
        val sm = context.getSystemService(StorageManager::class.java)
        if (sm != null) {
            val volume = sm.getStorageVolume(File(anyPath))
            if (volume != null) {
                if (volume.isPrimary) {
                    return "primary"
                }
                val uuid = volume.uuid
                if (uuid != null) {
                    return uuid.toUpperCase(Locale.ROOT)
                }
            }
        }
        Log.e(LOG_TAG, "failed to find volume UUID for anyPath=$anyPath")
        return null
    }

    private fun getVolumePathFromTreeUriUuid(context: Context, uuid: String): String? {
        if (uuid == "primary") {
            return primaryVolumePath
        }
        val sm = context.getSystemService(StorageManager::class.java)
        if (sm != null) {
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
        Log.e(LOG_TAG, "failed to find volume path for UUID=$uuid")
        return null
    }

    // e.g.
    // /storage/emulated/0/         -> content://com.android.externalstorage.documents/tree/primary%3A
    // /storage/10F9-3F13/Pictures/ -> content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures
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

    @JvmStatic
    fun getDocumentFile(context: Context, anyPath: String, mediaUri: Uri): DocumentFileCompat? {
        if (requireAccessPermission(anyPath)) {
            // need a document URI (not a media content URI) to open a `DocumentFile` output stream
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // cleanest API to get it
                val docUri = MediaStore.getDocumentUri(context, mediaUri)
                if (docUri != null) {
                    return DocumentFileCompat.fromSingleUri(context, docUri)
                }
            }
            // fallback for older APIs
            return getVolumePath(context, anyPath)?.let { convertDirPathToTreeUri(context, it) }?.let { getDocumentFileFromVolumeTree(context, it, anyPath) }
        }
        // good old `File`
        return DocumentFileCompat.fromFile(File(anyPath))
    }

    // returns the directory `DocumentFile` (from tree URI when scoped storage is required, `File` otherwise)
    // returns null if directory does not exist and could not be created
    @JvmStatic
    fun createDirectoryIfAbsent(context: Context, dirPath: String): DocumentFileCompat? {
        val cleanDirPath = ensureTrailingSeparator(dirPath)
        return if (requireAccessPermission(cleanDirPath)) {
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

    @JvmStatic
    fun copyFileToTemp(documentFile: DocumentFileCompat, path: String): String? {
        val extension = MimeTypeMap.getFileExtensionFromUrl(Uri.fromFile(File(path)).toString())
        try {
            val temp = File.createTempFile("aves", ".$extension")
            documentFile.copyTo(DocumentFileCompat.fromFile(temp))
            temp.deleteOnExit()
            return temp.path
        } catch (e: IOException) {
            Log.e(LOG_TAG, "failed to copy file from path=$path")
        }
        return null
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

    @JvmStatic
    fun requireAccessPermission(anyPath: String): Boolean {
        // on Android R, we should always require access permission, even on primary volume
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q) {
            return true
        }
        val onPrimaryVolume = anyPath.startsWith(primaryVolumePath)
        return !onPrimaryVolume
    }

    private fun isMediaStoreContentUri(uri: Uri?): Boolean {
        uri ?: return false
        // a URI's authority is [userinfo@]host[:port]
        // but we only want the host when comparing to Media Store's "authority"
        return ContentResolver.SCHEME_CONTENT.equals(uri.scheme, ignoreCase = true) && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)
    }

    fun openInputStream(context: Context, uri: Uri): InputStream? {
        var effectiveUri = uri
        // we get a permission denial if we require original from a provider other than the media store
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isMediaStoreContentUri(uri)) {
            effectiveUri = MediaStore.setRequireOriginal(uri)
        }

        return try {
            context.contentResolver.openInputStream(effectiveUri)
        } catch (e: FileNotFoundException) {
            Log.w(LOG_TAG, "failed to find file at uri=$effectiveUri")
            null
        }
    }

    @JvmStatic
    fun openMetadataRetriever(context: Context, uri: Uri): MediaMetadataRetriever? {
        var effectiveUri = uri
        // we get a permission denial if we require original from a provider other than the media store
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isMediaStoreContentUri(uri)) {
            effectiveUri = MediaStore.setRequireOriginal(uri)
        }

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

    private fun ensureTrailingSeparator(dirPath: String): String {
        return if (dirPath.endsWith(File.separator)) dirPath else dirPath + File.separator
    }

    // `fullPath` should match "volumePath + relativeDir + filename"
    class PathSegments(context: Context, fullPath: String) {
        var volumePath: String? = null // `volumePath` with trailing "/"
        var relativeDir: String? = null // `relativeDir` with trailing "/"
        var filename: String? = null // null for directories

        init {
            volumePath = getVolumePath(context, fullPath)
            if (volumePath != null) {
                val lastSeparatorIndex = fullPath.lastIndexOf(File.separator) + 1
                val volumePathLength = volumePath!!.length
                if (lastSeparatorIndex > volumePathLength) {
                    filename = fullPath.substring(lastSeparatorIndex)
                    relativeDir = fullPath.substring(volumePathLength, lastSeparatorIndex)
                }
            }
        }
    }
}