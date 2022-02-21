package deckers.thibault.aves.channel.calls

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import androidx.core.os.EnvironmentCompat
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.PermissionManager
import deckers.thibault.aves.utils.StorageUtils.getPrimaryVolumePath
import deckers.thibault.aves.utils.StorageUtils.getVolumePaths
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.io.File

class StorageHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStorageVolumes" -> ioScope.launch { safe(call, result, ::getStorageVolumes) }
            "getFreeSpace" -> ioScope.launch { safe(call, result, ::getFreeSpace) }
            "getGrantedDirectories" -> ioScope.launch { safe(call, result, ::getGrantedDirectories) }
            "getInaccessibleDirectories" -> ioScope.launch { safe(call, result, ::getInaccessibleDirectories) }
            "getRestrictedDirectories" -> ioScope.launch { safe(call, result, ::getRestrictedDirectories) }
            "revokeDirectoryAccess" -> safe(call, result, ::revokeDirectoryAccess)
            "deleteEmptyDirectories" -> ioScope.launch { safe(call, result, ::deleteEmptyDirectories) }
            "canRequestMediaFileBulkAccess" -> safe(call, result, ::canRequestMediaFileBulkAccess)
            "canInsertMedia" -> safe(call, result, ::canInsertMedia)
            else -> result.notImplemented()
        }
    }

    private fun getStorageVolumes(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val volumes = ArrayList<Map<String, Any>>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val sm = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
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
                    val isPrimary = volumePath == primaryVolumePath
                    val isRemovable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        Environment.isExternalStorageRemovable(volumeFile)
                    } else {
                        // random guess
                        !isPrimary
                    }
                    volumes.add(
                        hashMapOf(
                            "path" to volumePath,
                            "isPrimary" to isPrimary,
                            "isRemovable" to isRemovable,
                            "state" to EnvironmentCompat.getStorageState(volumeFile)
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

    private fun getGrantedDirectories(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(ArrayList(PermissionManager.getGrantedDirs(context)))
    }

    private fun getInaccessibleDirectories(call: MethodCall, result: MethodChannel.Result) {
        val dirPaths = call.argument<List<String>>("dirPaths")
        if (dirPaths == null) {
            result.error("getInaccessibleDirectories-args", "failed because of missing arguments", null)
            return
        }

        result.success(PermissionManager.getInaccessibleDirectories(context, dirPaths))
    }

    private fun getRestrictedDirectories(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(PermissionManager.getRestrictedDirectories(context))
    }

    private fun revokeDirectoryAccess(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("revokeDirectoryAccess-args", "failed because of missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            result.error("revokeDirectoryAccess-unsupported", "volume access is not allowed before Android Lollipop", null)
            return
        }

        val success = PermissionManager.revokeDirectoryAccess(context, path)
        result.success(success)
    }

    private fun deleteEmptyDirectories(call: MethodCall, result: MethodChannel.Result) {
        val dirPaths = call.argument<List<String>>("dirPaths")
        if (dirPaths == null) {
            result.error("deleteEmptyDirectories-args", "failed because of missing arguments", null)
            return
        }

        var deleted = 0
        dirPaths.forEach {
            try {
                val dir = File(it)
                if (dir.isDirectory && dir.listFiles()?.isEmpty() == true && dir.delete()) {
                    deleted++
                }
            } catch (e: SecurityException) {
                // ignore
            }
        }
        result.success(deleted)
    }

    private fun canRequestMediaFileBulkAccess(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
    }

    private fun canInsertMedia(call: MethodCall, result: MethodChannel.Result) {
        val directories = call.argument<List<FieldMap>>("directories")
        if (directories == null) {
            result.error("canInsertMedia-args", "failed because of missing arguments", null)
            return
        }

        result.success(PermissionManager.canInsertByMediaStore(directories))
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/storage"
    }
}