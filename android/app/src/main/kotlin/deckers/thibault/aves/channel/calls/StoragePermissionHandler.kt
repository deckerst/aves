package deckers.thibault.aves.channel.calls

import android.content.Context
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.storage.PermissionManager
import deckers.thibault.aves.storage.StorageUtils.ensureTrailingSeparator
import deckers.thibault.aves.storage.apis.MediaStorePermissions
import deckers.thibault.aves.storage.apis.SafPermissions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class StoragePermissionHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getEditionApis" -> safe(call, result, ::getEditionApis)
            "getSafDirectoryToRequest" -> ioScope.launch { safe(call, result, ::getSafDirectoryToRequest) }
            "getSafGrantedDirectories" -> ioScope.launch { safe(call, result, ::getSafGrantedDirectories) }
            "revokeSafDirectoryAccess" -> safe(call, result, ::revokeSafDirectoryAccess)
            "canRequestMediaStoreBulkAccess" -> safe(call, result, ::canRequestMediaStoreBulkAccess)
            else -> result.notImplemented()
        }
    }

    private fun getEditionApis(call: MethodCall, result: MethodChannel.Result) {
        var dirPaths = call.argument<List<String>>("dirPaths")
        val insertion = call.argument<Boolean>("insertion")
        if (dirPaths == null || insertion == null) {
            result.error("getEditionApis-args", "missing arguments", null)
            return
        }

        dirPaths = dirPaths.map(::ensureTrailingSeparator).toList()
        val apisByPathSegments = PermissionManager.getStorageEditionApis(context, dirPaths, insertion)
        result.success(apisByPathSegments.map { (pathSegments, apis) ->
            hashMapOf(
                "dir" to pathSegments.toMap(),
                "apis" to apis.map { api -> api.toKey() }.toList(),
            )
        }.toList())
    }

    private fun getSafDirectoryToRequest(call: MethodCall, result: MethodChannel.Result) {
        var dirPath = call.argument<String>("dirPath")
        if (dirPath == null) {
            result.error("getSafDirectoryToRequest-args", "missing arguments", null)
            return
        }

        dirPath = ensureTrailingSeparator(dirPath)
        val pathSegments = SafPermissions.getDirectoryToRequest(context, dirPath)
        if (pathSegments != null) {
            result.success(pathSegments.toMap())
        } else {
            result.error("getSafDirectoryToRequest-restricted", "Directory cannot be accessed via SAF at path=$dirPath", null)
        }
    }

    private fun getSafGrantedDirectories(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val dirPaths = SafPermissions.getGrantedDirectories(context)
        result.success(dirPaths.toList())
    }

    private fun revokeSafDirectoryAccess(call: MethodCall, result: MethodChannel.Result) {
        var dirPath = call.argument<String>("dirPath")
        if (dirPath == null) {
            result.error("revokeSafDirectoryAccess-args", "missing arguments", null)
            return
        }

        dirPath = ensureTrailingSeparator(dirPath)
        val success = SafPermissions.revokeDirectoryAccess(context, dirPath)
        result.success(success)
    }

    private fun canRequestMediaStoreBulkAccess(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(MediaStorePermissions.canRequestBulkAccess())
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/storage_permission"
    }
}