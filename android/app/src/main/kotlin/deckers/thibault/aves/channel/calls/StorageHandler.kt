package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import androidx.annotation.RequiresApi
import deckers.thibault.aves.utils.PermissionManager
import deckers.thibault.aves.utils.StorageUtils.getVolumePaths
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.util.*

class StorageHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStorageVolumes" -> {
                val volumes: List<Map<String, Any>> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    storageVolumes
                } else {
                    // TODO TLAD find alternative for Android <N
                    emptyList()
                }
                result.success(volumes)
            }
            "getGrantedDirectories" -> result.success(ArrayList(PermissionManager.getGrantedDirs(context)))
            "getInaccessibleDirectories" -> getInaccessibleDirectories(call, result)
            "revokeDirectoryAccess" -> revokeDirectoryAccess(call, result)
            "scanFile" -> scanFile(call, MethodResultWrapper(result))
            else -> result.notImplemented()
        }
    }

    private val storageVolumes: List<Map<String, Any>>
        @RequiresApi(api = Build.VERSION_CODES.N)
        get() {
            val volumes = ArrayList<Map<String, Any>>()
            val sm = context.getSystemService(StorageManager::class.java)
            if (sm != null) {
                for (volumePath in getVolumePaths(context)) {
                    try {
                        sm.getStorageVolume(File(volumePath))?.let {
                            val volumeMap = HashMap<String, Any>()
                            volumeMap["path"] = volumePath
                            volumeMap["description"] = it.getDescription(context)
                            volumeMap["isPrimary"] = it.isPrimary
                            volumeMap["isRemovable"] = it.isRemovable
                            volumeMap["isEmulated"] = it.isEmulated
                            volumeMap["state"] = it.state
                            volumes.add(volumeMap)
                        }
                    } catch (e: IllegalArgumentException) {
                        // ignore
                    }
                }
            }
            return volumes
        }

    private fun getInaccessibleDirectories(call: MethodCall, result: MethodChannel.Result) {
        val dirPaths = call.argument<List<String>>("dirPaths")
        if (dirPaths == null) {
            result.error("getInaccessibleDirectories-args", "failed because of missing arguments", null)
            return
        }

        val dirs = PermissionManager.getInaccessibleDirectories(context, dirPaths)
        result.success(dirs)
    }

    private fun revokeDirectoryAccess(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("revokeDirectoryAccess-args", "failed because of missing arguments", null)
            return
        }

        val success = PermissionManager.revokeDirectoryAccess(context, path)
        result.success(success)
    }

    private fun scanFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val mimeType = call.argument<String>("mimeType")
        MediaScannerConnection.scanFile(context, arrayOf(path), arrayOf(mimeType)) { _, uri: Uri? -> result.success(uri?.toString()) }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/storage"
    }
}