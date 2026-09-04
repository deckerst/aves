package deckers.thibault.aves.storage.apis

import android.content.Context
import android.os.Build
import deckers.thibault.aves.storage.StorageUtils

object FilePermissions : StoragePermissions {
    fun getAccessibleDirectories(context: Context): Set<String> {
        return hashSetOf<String>().apply {
            addAll(StorageUtils.getAppDirectories(context))

            // from API 21 / Android 5.0 / Lollipop, removable storage requires access permission, but directory access grant is possible
            // from API 30 / Android 11 / R, any storage requires access permission
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
                add(StorageUtils.getPrimaryVolumePath(context))
            }
        }
    }

    fun canEdit(context: Context, anyPath: String): Boolean {
        val dirs = getAccessibleDirectories(context)
        return dirs.any { anyPath.startsWith(it) }
    }

    override fun canEditWithUserInteraction(context: Context, dirPath: String, insertion: Boolean): Boolean {
        if (dirPath == StorageUtils.TRASH_PATH_PLACEHOLDER) return true
        return canEdit(context, dirPath)
    }
}