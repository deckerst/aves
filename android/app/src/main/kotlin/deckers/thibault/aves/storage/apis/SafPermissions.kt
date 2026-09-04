package deckers.thibault.aves.storage.apis

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.UriPermission
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.util.Log
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.PendingStorageAccessResultHandler
import deckers.thibault.aves.storage.PathSegments
import deckers.thibault.aves.storage.PermissionManager
import deckers.thibault.aves.storage.StorageUtils
import deckers.thibault.aves.utils.LogUtils
import java.io.File
import java.util.Locale

object SafPermissions : StoragePermissions {
    private val LOG_TAG = LogUtils.createTag<SafPermissions>()

    fun requestDirectoryAccess(activity: Activity, path: String?, onGranted: (uri: Uri) -> Unit, onDenied: () -> Unit) {
        Log.i(LOG_TAG, "request user to select and grant access permission to path=$path")

        // `StorageVolume.createOpenDocumentTreeIntent` is an alternative,
        // and it helps with initial volume, but not with initial directory
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        if (path != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // initial URI should not be a `tree document URI`, but a simple `document URI`
            StorageUtils.convertDirPathToDocumentUri(activity, path)?.let {
                intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, it)
            }
        }

        if (intent.resolveActivity(activity.packageManager) != null) {
            MainActivity.pendingStorageAccessResultHandlers[MainActivity.DOCUMENT_TREE_ACCESS_REQUEST] = PendingStorageAccessResultHandler(path, onGranted, onDenied)
            activity.startActivityForResult(intent, MainActivity.DOCUMENT_TREE_ACCESS_REQUEST)
        } else {
            MainActivity.notifyError("failed to resolve activity for intent=$intent extras=${intent.extras}")
            onDenied()
        }
    }

    fun revokeDirectoryAccess(context: Context, dirPath: String): Boolean {
        return StorageUtils.convertDirPathToTreeDocumentUri(context, dirPath)?.let {
            releasePersistedUriPermission(context, it)
            true
        } ?: false
    }

    // returns paths matching directory URIs granted by the user
    fun getGrantedDirectories(context: Context): Set<String> {
        val grantedDirs = HashSet<String>()
        for (uriPermission in getPersistedUriPermissions(context)) {
            val dirPath = StorageUtils.convertTreeDocumentUriToDirPath(context, uriPermission.uri)
            dirPath?.let { grantedDirs.add(it) }
        }
        return grantedDirs
    }

    // save access permissions across reboots, if possible
    fun takePersistableUriPermission(context: Context, flags: Int, treeUri: Uri) {
        val canPersist = (flags and Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION) != 0
        if (canPersist) {
            val takeFlags = (flags
                    and (Intent.FLAG_GRANT_READ_URI_PERMISSION
                    or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
            try {
                @SuppressLint("WrongConstant")
                context.contentResolver.takePersistableUriPermission(treeUri, takeFlags)
            } catch (e: SecurityException) {
                Log.w(LOG_TAG, "failed to take persistable URI permission for uri=$treeUri", e)
            }
        }
    }

    private fun releasePersistedUriPermission(context: Context, uri: Uri) {
        val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        context.contentResolver.releasePersistableUriPermission(uri, flags)
    }

    fun getPersistedUriPermissions(context: Context): List<UriPermission> {
        return context.contentResolver.persistedUriPermissions
    }

    // As of Android 11, `MediaStore.getDocumentUri` fails if any of the persisted
    // URI permissions we hold points to a folder that no longer exists,
    // so we should remove these obsolete URIs before proceeding.
    fun sanitizePersistedUriPermissions(context: Context) {
        try {
            for (uriPermission in getPersistedUriPermissions(context)) {
                val uri = uriPermission.uri
                val path = StorageUtils.convertTreeDocumentUriToDirPath(context, uri)
                if (path == null || !File(path).exists()) {
                    Log.d(LOG_TAG, "revoke URI permission for obsolete uri=$uri path=$path")
                    releasePersistedUriPermission(context, uri)
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to sanitize persisted URI permissions", e)
        }
    }

    // returns volume root directories that cannot be selected via SAF picker
    fun getRestrictedPrimaryDirectories(): List<String> {
        val dirs = ArrayList<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // cf https://developer.android.com/about/versions/11/privacy/storage#directory-access
            dirs.add(Environment.DIRECTORY_DOWNLOADS)
            // depends on device, no documentation
            dirs.add("Android")
        }
        return dirs
    }

    // returns volumes that cannot be selected via SAF picker
    fun getRestrictedVolumes(context: Context): Set<String> {
        val appUserId = PermissionManager.getAppUserId(context)
        return StorageUtils.getVolumePaths(context).filter { volumePath ->
            val volumeUserId = PermissionManager.getVolumeUserId(volumePath)
            // other user storage space (e.g. Dual Messenger) is not visible
            appUserId != null && volumeUserId != null && appUserId != volumeUserId
        }.toSet()
    }

    fun isPathOnRestrictedVolume(context: Context, dirPath: String): Boolean {
        return getRestrictedVolumes(context).any(dirPath::startsWith)
    }

    fun getDirectoryToRequest(context: Context, dirPath: String): PathSegments? {
        if (isPathOnRestrictedVolume(context, dirPath)) return null

        val segments = PathSegments(context, dirPath)
        val volumePath = segments.volumePath ?: return null

        // request volume root until Android 10 (API 29)
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
            return PathSegments(volumePath, null)
        }

        // request primary directory on volume from Android 11 (API 30)
        val relativeDir = segments.relativeDir
        if (relativeDir != null) {
            val dirSegments = relativeDir.split(File.separator).takeWhile { it.isNotEmpty() }
            val primaryDir = dirSegments.firstOrNull()
            if (primaryDir != null) {
                val isPrimaryDirRestricted = getRestrictedPrimaryDirectories().map { it.lowercase(Locale.ROOT) }.contains(primaryDir.lowercase(Locale.ROOT))
                if (!isPrimaryDirRestricted) {
                    return PathSegments(volumePath, primaryDir)
                }

                // request secondary directory (if any) for restricted primary directory
                if (dirSegments.size > 1) {
                    val secondaryDir = dirSegments.take(2).joinToString(File.separator)
                    // only register directories that exist on storage, so they can be selected for access grant
                    if (File(volumePath, secondaryDir).exists()) {
                        return PathSegments(volumePath, secondaryDir)
                    }
                }
            }
        }

        return null
    }

    override fun canEditWithUserInteraction(context: Context, dirPath: String, insertion: Boolean): Boolean {
        return getDirectoryToRequest(context, dirPath) != null
    }
}