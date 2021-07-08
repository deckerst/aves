package deckers.thibault.aves.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.util.Log
import androidx.annotation.RequiresApi
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.PendingResultHandler
import deckers.thibault.aves.utils.StorageUtils.PathSegments
import java.io.File
import java.util.*
import kotlin.collections.ArrayList

object PermissionManager {
    private val LOG_TAG = LogUtils.createTag<PermissionManager>()

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun requestVolumeAccess(activity: Activity, path: String, onGranted: (uri: Uri) -> Unit, onDenied: () -> Unit) {
        Log.i(LOG_TAG, "request user to select and grant access permission to path=$path")

        var intent: Intent? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val sm = activity.getSystemService(StorageManager::class.java)
            intent = sm?.getStorageVolume(File(path))?.createOpenDocumentTreeIntent()
        }

        // fallback to basic open document tree intent
        if (intent == null) {
            intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        }

        if (intent.resolveActivity(activity.packageManager) != null) {
            MainActivity.pendingResultHandlers[MainActivity.DOCUMENT_TREE_ACCESS_REQUEST] = PendingResultHandler(path, onGranted, onDenied)
            activity.startActivityForResult(intent, MainActivity.DOCUMENT_TREE_ACCESS_REQUEST)
        } else {
            Log.e(LOG_TAG, "failed to resolve activity for intent=$intent")
            onDenied()
        }
    }

    fun getGrantedDirForPath(context: Context, anyPath: String): String? {
        return getAccessibleDirs(context).firstOrNull { anyPath.startsWith(it) }
    }

    fun getInaccessibleDirectories(context: Context, dirPaths: List<String>): List<Map<String, String>> {
        val accessibleDirs = getAccessibleDirs(context)

        // find set of inaccessible directories for each volume
        val dirsPerVolume = HashMap<String, MutableSet<String>>()
        for (dirPath in dirPaths.map { if (it.endsWith(File.separator)) it else it + File.separator }) {
            if (accessibleDirs.none { dirPath.startsWith(it) }) {
                // inaccessible dirs
                val segments = PathSegments(context, dirPath)
                segments.volumePath?.let { volumePath ->
                    val dirSet = dirsPerVolume[volumePath] ?: HashSet()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        // request primary directory on volume from Android R
                        val relativeDir = segments.relativeDir
                        if (relativeDir != null) {
                            val dirSegments = relativeDir.split(File.separator).takeWhile { it.isNotEmpty() }
                            val primaryDir = dirSegments.firstOrNull()
                            if (primaryDir == Environment.DIRECTORY_DOWNLOADS && dirSegments.size > 1) {
                                // request secondary directory (if any) for restricted primary directory
                                dirSet.add(dirSegments.take(2).joinToString(File.separator))
                            } else {
                                primaryDir?.let { dirSet.add(it) }
                            }
                        } else {
                            // the requested path is the volume root itself
                            // which cannot be granted, due to Android R restrictions
                            dirSet.add("")
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
        return ArrayList<Map<String, String>>().apply {
            addAll(dirsPerVolume.flatMap { (volumePath, relativeDirs) ->
                relativeDirs.map { relativeDir ->
                    hashMapOf(
                        "volumePath" to volumePath,
                        "relativeDir" to relativeDir,
                    )
                }
            })
        }
    }

    fun getRestrictedDirectories(context: Context): List<Map<String, String>> {
        val dirs = ArrayList<Map<String, String>>()
        val sdkInt = Build.VERSION.SDK_INT

        if (sdkInt >= Build.VERSION_CODES.R) {
            // cf https://developer.android.com/about/versions/11/privacy/storage#directory-access
            val volumePaths = StorageUtils.getVolumePaths(context)
            dirs.addAll(volumePaths.map {
                hashMapOf(
                    "volumePath" to it,
                    "relativeDir" to "",
                )
            })
            dirs.addAll(volumePaths.map {
                hashMapOf(
                    "volumePath" to it,
                    "relativeDir" to Environment.DIRECTORY_DOWNLOADS,
                )
            })
        } else if (sdkInt == Build.VERSION_CODES.KITKAT || sdkInt == Build.VERSION_CODES.KITKAT_WATCH) {
            // no SD card volume access on KitKat
            val primaryVolume = StorageUtils.getPrimaryVolumePath(context)
            val nonPrimaryVolumes = StorageUtils.getVolumePaths(context).filter { it != primaryVolume }
            dirs.addAll(nonPrimaryVolumes.map {
                hashMapOf(
                    "volumePath" to it,
                    "relativeDir" to "",
                )
            })
        }
        return dirs
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun revokeDirectoryAccess(context: Context, path: String): Boolean {
        return StorageUtils.convertDirPathToTreeUri(context, path)?.let {
            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            context.contentResolver.releasePersistableUriPermission(it, flags)
            true
        } ?: false
    }

    // returns paths matching URIs granted by the user
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
        return accessibleDirs
    }
}