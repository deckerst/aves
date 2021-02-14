package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.utils.PermissionManager
import deckers.thibault.aves.utils.StorageUtils.getPrimaryVolumePath
import deckers.thibault.aves.utils.StorageUtils.getVolumePaths
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.util.*

class StorageHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStorageVolumes" -> safe(call, result, ::getStorageVolumes)
            "getFreeSpace" -> safe(call, result, ::getFreeSpace)
            "getGrantedDirectories" -> safe(call, result, ::getGrantedDirectories)
            "getInaccessibleDirectories" -> safe(call, result, ::getInaccessibleDirectories)
            "revokeDirectoryAccess" -> safe(call, result, ::revokeDirectoryAccess)
            "scanFile" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::scanFile) }
            else -> result.notImplemented()
        }
    }

    private fun getStorageVolumes(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        val volumes = ArrayList<Map<String, Any>>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val sm = context.getSystemService(StorageManager::class.java)
            if (sm != null) {
                for (volumePath in getVolumePaths(context)) {
                    try {
                        sm.getStorageVolume(File(volumePath))?.let {
                            volumes.add(
                                hashMapOf(
                                    "path" to volumePath,
                                    "description" to it.getDescription(context),
                                    "isPrimary" to it.isPrimary,
                                    "isRemovable" to it.isRemovable,
                                    "state" to it.state,
                                )
                            )
                        }
                    } catch (e: IllegalArgumentException) {
                        // ignore
                    }
                }
            }
        } else {
            val primaryVolumePath = getPrimaryVolumePath(context)
            for (volumePath in getVolumePaths(context)) {
                val volumeFile = File(volumePath)
                try {
                    volumes.add(
                        hashMapOf(
                            "path" to volumePath,
                            "isPrimary" to (volumePath == primaryVolumePath),
                            "isRemovable" to Environment.isExternalStorageRemovable(volumeFile),
                            "state" to Environment.getExternalStorageState(volumeFile)
                        )
                    )
                } catch (e: IllegalArgumentException) {
                    // ignore
                }
            }
        }
        result.success(volumes)
    }

    private fun getFreeSpace(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("getFreeSpace-args", "failed because of missing arguments", null)
            return
        }

        // `StorageStatsManager` `getFreeBytes()` is only available from API 26,
        // and non-primary volume UUIDs cannot be used with it
        val file = File(path)
        try {
            result.success(file.freeSpace)
        } catch (e: SecurityException) {
            result.error("getFreeSpace-security", "failed because of missing access", e.message)
        }
    }

    private fun getGrantedDirectories(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result) {
        result.success(ArrayList(PermissionManager.getGrantedDirs(context)))
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