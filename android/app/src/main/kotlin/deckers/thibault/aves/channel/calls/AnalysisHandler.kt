package deckers.thibault.aves.channel.calls

import android.content.Context
import androidx.core.app.ComponentActivity
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import deckers.thibault.aves.AnalysisWorker
import deckers.thibault.aves.utils.FlutterUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking


class AnalysisHandler(private val activity: ComponentActivity, private val onAnalysisCompleted: () -> Unit) : MethodChannel.MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "registerCallback" -> ioScope.launch { Coresult.safe(call, result, ::registerCallback) }
            "startAnalysis" -> Coresult.safe(call, result, ::startAnalysis)
            else -> result.notImplemented()
        }
    }

    private fun registerCallback(call: MethodCall, result: MethodChannel.Result) {
        val callbackHandle = call.argument<Number>("callbackHandle")?.toLong()
        if (callbackHandle == null) {
            result.error("registerCallback-args", "missing arguments", null)
            return
        }

        activity.getSharedPreferences(AnalysisWorker.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            .edit()
            .putLong(AnalysisWorker.CALLBACK_HANDLE_KEY, callbackHandle)
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

        WorkManager.getInstance(activity).enqueueUniqueWork(
            ANALYSIS_WORK_NAME,
            ExistingWorkPolicy.KEEP,
            OneTimeWorkRequestBuilder<AnalysisWorker>().apply {
                setInputData(
                    workDataOf(
                        AnalysisWorker.KEY_ENTRY_IDS to entryIds?.toIntArray(),
                        AnalysisWorker.KEY_FORCE to force,
                    )
                )
            }.build()
        )
        attachToActivity()
        result.success(null)
    }

    private var attached = false

    fun attachToActivity() {
        if (!attached) {
            attached = true
            WorkManager.getInstance(activity).getWorkInfosForUniqueWorkLiveData(ANALYSIS_WORK_NAME).observe(activity) { list ->
                if (list.any { it.state == WorkInfo.State.SUCCEEDED }) {
                    runBlocking {
                        FlutterUtils.runOnUiThread {
                            onAnalysisCompleted()
                        }
                    }
                }
            }
        }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/analysis"
        private const val ANALYSIS_WORK_NAME = "analysis_work"
    }
}
