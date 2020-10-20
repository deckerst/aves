package deckers.thibault.aves.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import deckers.thibault.aves.utils.LogUtils.createTag
import deckers.thibault.aves.utils.StorageUtils.PathSegments
import java.io.File
import java.util.*
import java.util.concurrent.ConcurrentHashMap

object PermissionManager {
    private val LOG_TAG = createTag(PermissionManager::class.java)

    const val VOLUME_ACCESS_REQUEST_CODE = 1

    // permission request code to pending runnable
    private val pendingPermissionMap = ConcurrentHashMap<Int, PendingPermissionHandler>()

    @JvmStatic
    fun requestVolumeAccess(activity: Activity, path: String, onGranted: () -> Unit, onDenied: () -> Unit) {
        Log.i(LOG_TAG, "request user to select and grant access permission to volume=$path")
        pendingPermissionMap[VOLUME_ACCESS_REQUEST_CODE] = PendingPermissionHandler(path, onGranted, onDenied)

        var intent: Intent? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val sm = activity.getSystemService(StorageManager::class.java)
            intent = sm?.getStorageVolume(File(path))?.createOpenDocumentTreeIntent()
        }

        // fallback to basic open document tree intent
        if (intent == null) {
            intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        }

        ActivityCompat.startActivityForResult(activity, intent, VOLUME_ACCESS_REQUEST_CODE, null)
    }

    fun onPermissionResult(requestCode: Int, treeUri: Uri?) {
        Log.d(LOG_TAG, "onPermissionResult with requestCode=$requestCode, treeUri=$treeUri")
        val handler = pendingPermissionMap.remove(requestCode) ?: return
        (if (treeUri != null) handler.onGranted else handler.onDenied)()
    }

    @JvmStatic
    fun getGrantedDirForPath(context: Context, anyPath: String): String? {
        return getAccessibleDirs(context).firstOrNull { anyPath.startsWith(it) }
    }

    @JvmStatic
    fun getInaccessibleDirectories(context: Context, dirPaths: List<String>): List<Map<String, String>> {
        val accessibleDirs = getAccessibleDirs(context)

        // find set of inaccessible directories for each volume
        val dirsPerVolume = HashMap<String, MutableSet<String>>()
        for (dirPath in dirPaths.map { if (it.endsWith(File.separator)) it else it + File.separator }) {
            if (accessibleDirs.none { dirPath.startsWith(it) }) {
                // inaccessible dirs
                val segments = PathSegments(context, dirPath)
                segments.volumePath?.let { volumePath ->
                    val dirSet = dirsPerVolume.getOrDefault(volumePath, HashSet())
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        // request primary directory on volume from Android R
                        segments.relativeDir?.apply {
                            val primaryDir = split(File.separator).firstOrNull { it.isNotEmpty() }
                            primaryDir?.let { dirSet.add(it) }
                        }
                    } else {
                        // request volume root until Android Q
                        dirSet.add("")
                    }
                    dirsPerVolume[volumePath] = dirSet
                }
            }
        }

        // format for easier handling on Flutter
        val inaccessibleDirs = ArrayList<Map<String, String>>()
        val sm = context.getSystemService(StorageManager::class.java)
        if (sm != null) {
            for ((volumePath, relativeDirs) in dirsPerVolume) {
                var volumeDescription: String? = null
                try {
                    volumeDescription = sm.getStorageVolume(File(volumePath))?.getDescription(context)
                } catch (e: IllegalArgumentException) {
                    // ignore
                }
                for (relativeDir in relativeDirs) {
                    val dirMap = HashMap<String, String>()
                    dirMap["volumePath"] = volumePath
                    dirMap["volumeDescription"] = volumeDescription ?: ""
                    dirMap["relativeDir"] = relativeDir
                    inaccessibleDirs.add(dirMap)
                }
            }
        }
        Log.d(LOG_TAG, "getInaccessibleDirectories dirPaths=$dirPaths -> inaccessibleDirs=$inaccessibleDirs")
        return inaccessibleDirs
    }

    @JvmStatic
    fun revokeDirectoryAccess(context: Context, path: String) {
        StorageUtils.convertDirPathToTreeUri(context, path)?.let {
            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            context.contentResolver.releasePersistableUriPermission(it, flags)
        }
    }

    // returns paths matching URIs granted by the user
    @JvmStatic
    fun getGrantedDirs(context: Context): Set<String> {
        val grantedDirs = HashSet<String>()
        for (uriPermission in context.contentResolver.persistedUriPermissions) {
            val dirPath = StorageUtils.convertTreeUriToDirPath(context, uriPermission.uri)
            dirPath?.let { grantedDirs.add(it) }
        }
        return grantedDirs
    }

    // returns paths accessible to the app (granted by the user or by default)
    private fun getAccessibleDirs(context: Context): Set<String> {
        val accessibleDirs = HashSet(getGrantedDirs(context))
        // from Android R, we no longer have access permission by default on primary volume
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
            accessibleDirs.add(StorageUtils.getPrimaryVolumePath(context))
        }
        Log.d(LOG_TAG, "getAccessibleDirs accessibleDirs=$accessibleDirs")
        return accessibleDirs
    }

    // onGranted: user gave access to a directory, with no guarantee that it matches the specified `path`
    // onDenied: user cancelled
    internal data class PendingPermissionHandler(val path: String, val onGranted: () -> Unit, val onDenied: () -> Unit)
}