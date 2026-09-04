package deckers.thibault.aves.storage.apis

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.os.Environment
import android.os.TransactionTooLargeException
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi
import deckers.thibault.aves.MainActivity
import deckers.thibault.aves.storage.PathSegments
import deckers.thibault.aves.storage.PermissionManager
import deckers.thibault.aves.storage.StorageUtils
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import java.util.Locale
import java.util.concurrent.CompletableFuture

object MediaStorePermissions : StoragePermissions {
    private val LOG_TAG = LogUtils.createTag<MediaStorePermissions>()
    private val INSERTION_PRIMARY_DIRS_LOWER = listOf(
        Environment.DIRECTORY_DCIM,
        Environment.DIRECTORY_DOWNLOADS,
        Environment.DIRECTORY_PICTURES,
    ).map { it.lowercase(Locale.ROOT) }.toList()

    private val IMAGES_PRIMARY_DIRS_LOWER = listOf(
        Environment.DIRECTORY_DCIM,
        Environment.DIRECTORY_PICTURES,
    ).map { it.lowercase(Locale.ROOT) }.toList()

    private val VIDEOS_PRIMARY_DIRS_LOWER = listOf(
        Environment.DIRECTORY_DCIM,
        Environment.DIRECTORY_MOVIES,
        Environment.DIRECTORY_PICTURES,
    ).map { it.lowercase(Locale.ROOT) }.toList()

    fun canRequestBulkAccess(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.R
    }

    fun canRequestMediaManagement(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
    }

    fun isMediaManagementGranted(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaStore.canManageMedia(context) else false
    }

    @RequiresApi(Build.VERSION_CODES.R)
    fun requestFileAccess(activity: Activity, uris: List<Uri>, mimeTypes: List<String>): Boolean {
        val safeUris = uris.mapIndexed { index, uri -> StorageUtils.getMediaStoreScopedStorageSafeUri(uri, mimeTypes[index]) }

        val todoUris = ArrayList<Uri>()
        val pid = Binder.getCallingPid()
        val uid = Binder.getCallingUid()
        val flags = Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            activity.checkUriPermissions(safeUris, pid, uid, flags)
        } else {
            safeUris.map { activity.checkUriPermission(it, pid, uid, flags) }.toIntArray()
        }.forEachIndexed { index, permission ->
            if (permission != PackageManager.PERMISSION_GRANTED) {
                todoUris.add(safeUris[index])
            }
        }
        if (todoUris.isEmpty()) return true

        Log.i(LOG_TAG, "request user to select and grant access permission to uris=$todoUris")
        try {
            val intentSender = MediaStore.createWriteRequest(activity.contentResolver, safeUris).intentSender
            MainActivity.pendingScopedStoragePermissionCompleter = CompletableFuture<Boolean>()
            activity.startIntentSenderForResult(intentSender, MainActivity.MEDIA_WRITE_BULK_PERMISSION_REQUEST, null, 0, 0, 0, null)
        } catch (e: IllegalArgumentException) {
            if (e.message == "URI list restricted to 2000 per request") {
                throw TransactionTooLargeException(e.message)
            }
            throw e
        }

        val granted = MainActivity.pendingScopedStoragePermissionCompleter!!.join()
        MainActivity.pendingScopedStoragePermissionCompleter = null

        return granted
    }

    fun canEdit(context: Context, uri: Uri, mimeType: String): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val safeUri = StorageUtils.getMediaStoreScopedStorageSafeUri(uri, mimeType)

            val pid = Binder.getCallingPid()
            val uid = Binder.getCallingUid()
            val flags = Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            context.checkUriPermission(safeUri, pid, uid, flags) == PackageManager.PERMISSION_GRANTED
        } else {
            false
        }
    }

    fun canMoveToPath(context: Context, mimeType: String, targetDirPath: String): Boolean {
        val primaryDir = PathSegments(context, targetDirPath).getPrimaryDir()?.lowercase(Locale.ROOT)
        return if (MimeTypes.isImage(mimeType)) {
            IMAGES_PRIMARY_DIRS_LOWER.contains(primaryDir)
        } else if (MimeTypes.isVideo(mimeType)) {
            VIDEOS_PRIMARY_DIRS_LOWER.contains(primaryDir)
        } else {
            false
        }
    }

    override fun canEditWithUserInteraction(context: Context, dirPath: String, insertion: Boolean): Boolean {
        if (!canRequestBulkAccess()) return false
        if (StorageUtils.isInAppStorage(context, dirPath)) return false
        if (insertion) {
            val segments = PathSegments(context, dirPath)
            val volumePath = segments.volumePath
            if (volumePath != null) {
                val volumeUserId = PermissionManager.getVolumeUserId(volumePath)
                val appUserId = PermissionManager.getAppUserId(context)
                if (volumeUserId != null && appUserId != null && volumeUserId != appUserId) {
                    // can only insert if the directory is in the same user space as the app
                    return false
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // can only insert if the directory is one of the standard ones
                val primaryDirLower = segments.getPrimaryDir()?.lowercase(Locale.ROOT)
                return INSERTION_PRIMARY_DIRS_LOWER.contains(primaryDirLower)
            }
        }
        return true
    }
}