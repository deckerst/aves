package deckers.thibault.aves.channel.calls

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ProcessLifecycleOwner
import deckers.thibault.aves.AnalysisService
import deckers.thibault.aves.AnalysisServiceBinder
import deckers.thibault.aves.AnalysisServiceListener
import deckers.thibault.aves.utils.ContextUtils.isMyServiceRunning
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class AnalysisHandler(private val activity: Activity, private val onAnalysisCompleted: () -> Unit) : MethodChannel.MethodCallHandler, AnalysisServiceListener {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "registerCallback" -> ioScope.launch { Coresult.safe(call, result, ::registerCallback) }
            "startService" -> Coresult.safe(call, result, ::startAnalysis)
            else -> result.notImplemented()
        }
    }

    @SuppressLint("CommitPrefEdits")
    private fun registerCallback(call: MethodCall, result: MethodChannel.Result) {
        val callbackHandle = call.argument<Number>("callbackHandle")?.toLong()
        if (callbackHandle == null) {
            result.error("registerCallback-args", "missing arguments", null)
            return
        }

        activity.getSharedPreferences(AnalysisService.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            .edit()
            .putLong(AnalysisService.CALLBACK_HANDLE_KEY, callbackHandle)
            .apply()
        result.success(true)
    }

    private fun startAnalysis(call: MethodCall, result: MethodChannel.Result) {
        val force = call.argument<Boolean>("force")
        if (force == null) {
            result.error("startAnalysis-args", "missing arguments", null)
            return
        }

        // can be null or empty
        val entryIds = call.argument<List<Int>>("entryIds")

        if (!activity.isMyServiceRunning(AnalysisService::class.java)) {
            val intent = Intent(activity, AnalysisService::class.java)
                .putExtra(AnalysisService.KEY_COMMAND, AnalysisService.COMMAND_START)
                .putExtra(AnalysisService.KEY_ENTRY_IDS, entryIds?.toIntArray())
                .putExtra(AnalysisService.KEY_FORCE, force)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val appState = ProcessLifecycleOwner.get().lifecycle.currentState
                if (!appState.isAtLeast(Lifecycle.State.STARTED)) {
                    result.error("startAnalysis-background", "cannot start foreground service from background", null)
                    return
                }
                activity.startForegroundService(intent)
            } else {
                activity.startService(intent)
            }
        }
        attachToActivity()
        result.success(null)
    }

    private var attached = false

    fun attachToActivity() {
        if (activity.isMyServiceRunning(AnalysisService::class.java)) {
            val intent = Intent(activity, AnalysisService::class.java)
            activity.bindService(intent, connection, Context.BIND_AUTO_CREATE)
            attached = true
        }
    }

    override fun detachFromActivity() {
        if (attached) {
            attached = false
            activity.unbindService(connection)
        }
    }

    override fun refreshApp() {
        if (attached) {
            onAnalysisCompleted()
        }
    }

    private val connection = object : ServiceConnection {
        var binder: AnalysisServiceBinder? = null

        override fun onServiceConnected(name: ComponentName, service: IBinder) {
            Log.i(LOG_TAG, "Analysis service connected")
            binder = service as AnalysisServiceBinder
            binder?.startListening(this@AnalysisHandler)
        }

        override fun onServiceDisconnected(name: ComponentName) {
            Log.i(LOG_TAG, "Analysis service disconnected")
            binder?.stopListening(this@AnalysisHandler)
            binder = null
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisHandler>()
        const val CHANNEL = "deckers.thibault/aves/analysis"
    }
}
