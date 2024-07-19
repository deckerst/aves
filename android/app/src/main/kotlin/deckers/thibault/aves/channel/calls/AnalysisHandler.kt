package deckers.thibault.aves.channel.calls

import android.content.Context
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import deckers.thibault.aves.AnalysisWorker
import deckers.thibault.aves.utils.FlutterUtils
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking


class AnalysisHandler(private val activity: FlutterFragmentActivity, private val onAnalysisCompleted: () -> Unit) : MethodChannel.MethodCallHandler {
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

        val preferences = activity.getSharedPreferences(AnalysisWorker.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
        with(preferences.edit()) {
            putLong(AnalysisWorker.PREF_CALLBACK_HANDLE_KEY, callbackHandle)
            apply()
        }
        result.success(true)
    }

    private fun startAnalysis(call: MethodCall, result: MethodChannel.Result) {
        val force = call.argument<Boolean>("force")
        if (force == null) {
            result.error("startAnalysis-args", "missing arguments", null)
            return
        }

        // can be null or empty
        val allEntryIds = call.argument<List<Int>>("entryIds")

        // work `Data` cannot occupy more than 10240 bytes when serialized
        // so we save the possibly long list of entry IDs to shared preferences
        val preferences = activity.getSharedPreferences(AnalysisWorker.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
        with(preferences.edit()) {
            putStringSet(AnalysisWorker.PREF_ENTRY_IDS_KEY, allEntryIds?.map { it.toString() }?.toSet())
            apply()
        }

        val workData = workDataOf(
            AnalysisWorker.KEY_FORCE to force,
        )

        WorkManager.getInstance(activity).beginUniqueWork(
            ANALYSIS_WORK_NAME,
            ExistingWorkPolicy.KEEP,
            OneTimeWorkRequestBuilder<AnalysisWorker>().apply { setInputData(workData) }.build(),
        ).enqueue()

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
