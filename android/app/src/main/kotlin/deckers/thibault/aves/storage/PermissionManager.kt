package deckers.thibault.aves.storage

import android.content.Context
import deckers.thibault.aves.storage.apis.FilePermissions
import deckers.thibault.aves.storage.apis.MediaStorePermissions
import deckers.thibault.aves.storage.apis.SafPermissions
import deckers.thibault.aves.storage.apis.StorageApi
import java.util.regex.Pattern

object PermissionManager {
    private val VOLUME_USER_ID_PATTERN = Pattern.compile("(?i)^/storage/emulated/([0-9]+)")
    const val USER_ID_DUAL_MESSENGER = 95 // Samsung Dual Messenger user ID

    fun getVolumeUserId(volumePath: String): Int? {
        val matcher = VOLUME_USER_ID_PATTERN.matcher(volumePath)
        return if (matcher.find()) matcher.group(1)?.toIntOrNull() else null
    }

    fun getAppUserId(context: Context): Int? {
        // `Context.getUserId()` and `UserHandle.myUserId()` are restricted APIs,
        // so we derive it from the app external files directory
        context.getExternalFilesDir(null)?.let { externalFilesDir ->
            StorageUtils.getVolumePath(context, externalFilesDir.absolutePath)?.let { volumePath ->
                return getVolumeUserId(volumePath)
            }
        }
        return null
    }

    // returns paths accessible to the app (granted by the user or by default)
    fun getAccessibleDirs(context: Context): Set<String> {
        return hashSetOf<String>().apply {
            addAll(SafPermissions.getGrantedDirectories(context))
            addAll(FilePermissions.getAccessibleDirectories(context))
        }
    }

    fun getPreferredEditionApis(): List<StorageApi> {
        return if (MediaStorePermissions.canRequestMediaManagement()) {
            listOf(StorageApi.FILE, StorageApi.MEDIA_STORE, StorageApi.SAF)
        } else {
            listOf(StorageApi.FILE, StorageApi.SAF, StorageApi.MEDIA_STORE)
        }
    }

    fun getStorageEditionApis(context: Context, dirPaths: List<String>, insertion: Boolean): Map<PathSegments, List<StorageApi>> {
        val preferredEditionApis = getPreferredEditionApis()
        val storageAccess = HashMap<PathSegments, List<StorageApi>>()
        dirPaths.forEach { dirPath ->
            val apis = preferredEditionApis.filter { api ->
                api.getPermissionDelegate().canEditWithUserInteraction(context, dirPath, insertion)
            }.toList()
            storageAccess[PathSegments(context, dirPath)] = apis
        }

        return storageAccess
    }
}