package deckers.thibault.aves

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.channel.calls.DeviceHandler
import deckers.thibault.aves.channel.calls.GeocodingHandler
import deckers.thibault.aves.channel.calls.MediaFetchObjectHandler
import deckers.thibault.aves.channel.calls.MediaStoreHandler
import deckers.thibault.aves.channel.calls.MetadataFetchHandler
import deckers.thibault.aves.channel.calls.StorageHandler
import deckers.thibault.aves.channel.streams.darttoplatform.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.darttoplatform.MediaStoreStreamHandler
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellableContinuation
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class AnalysisWorker(context: Context, parameters: WorkerParameters) : CoroutineWorker(context, parameters) {
    private val defaultScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private var workCont: CancellableContinuation<Any?>? = null
    private var flutterEngine: FlutterEngine? = null
    private var backgroundChannel: MethodChannel? = null

    override suspend fun doWork(): Result {
        Log.i(LOG_TAG, "Start analysis worker $id")
        createNotificationChannel()
        val foregroundInfo = createForegroundInfo()
        if (!isStopped) {
            setForeground(foregroundInfo)
            suspendCancellableCoroutine { cont ->
                workCont = cont
                cont.invokeOnCancellation {
                    Log.i(LOG_TAG, "Analysis worker got cancelled")
                    stopDartAnalysisService()
                    workCont?.resumeWithException(CancellationException())
                }
                onStart()
            }
            dispose()
        }
        return Result.success()
    }

    private suspend fun dispose() {
        Log.i(LOG_TAG, "Clean analysis worker $id")
        flutterEngine?.let {
            FlutterUtils.runOnUiThread {
                it.destroy()
            }
            flutterEngine = null
        }
    }

    private fun onStart() {
        runBlocking {
            FlutterUtils.initFlutterEngine(applicationContext, SHARED_PREFERENCES_KEY, PREF_CALLBACK_HANDLE_KEY) {
                flutterEngine = it
            }
        }

        try {
            initChannels(applicationContext)

            val preferences = applicationContext.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            val entryIdStrings = preferences.getStringSet(PREF_ENTRY_IDS_KEY, null)
            startDartAnalysisService(entryIdStrings)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to initialize worker", e)
            workCont?.resumeWithException(e)
        }
    }

    private fun initChannels(context: Context) {
        val engine = flutterEngine
        engine ?: throw Exception("Flutter engine is not initialized")

        val messenger = engine.dartExecutor

        // channels for analysis

        // dart -> platform -> dart
        // - need Context
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(context))
        MethodChannel(messenger, GeocodingHandler.CHANNEL).setMethodCallHandler(GeocodingHandler(context))
        MethodChannel(messenger, MediaFetchObjectHandler.CHANNEL).setMethodCallHandler(MediaFetchObjectHandler(context))
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(context))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(context))
        MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(context))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(context, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(context, args) }

        // channel for service management
        backgroundChannel = MethodChannel(messenger, BACKGROUND_CHANNEL).apply {
            setMethodCallHandler { call, result -> onMethodCall(call, result) }
        }
    }

    private fun startDartAnalysisService(entryIdStrings: Set<String>?) {
        runBlocking {
            FlutterUtils.runOnUiThread {
                backgroundChannel?.invokeMethod(
                    "start", hashMapOf(
                        "entryIds" to entryIdStrings?.map { Integer.parseUnsignedInt(it) }?.toList(),
                        "force" to inputData.getBoolean(KEY_FORCE, false),
                    )
                )
            }
        }
    }

    private fun stopDartAnalysisService() {
        runBlocking {
            FlutterUtils.runOnUiThread {
                backgroundChannel?.invokeMethod("stop", null)
            }
        }
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialized" -> {
                Log.d(LOG_TAG, "Analysis background channel is ready")
                result.success(null)
            }

            "updateNotification" -> defaultScope.launch { safeSuspend(call, result, ::updateNotification) }

            "stop" -> {
                workCont?.takeIf { it.isActive }?.resume(null)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannelCompat.Builder(NOTIFICATION_CHANNEL, NotificationManagerCompat.IMPORTANCE_LOW)
            .setName(applicationContext.getText(R.string.analysis_channel_name))
            .setShowBadge(false)
            .build()
        NotificationManagerCompat.from(applicationContext).createNotificationChannel(channel)
    }

    private fun createForegroundInfo(title: String? = null, message: String? = null): ForegroundInfo {
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val openAppIntent = Intent(applicationContext, MainActivity::class.java).let {
            PendingIntent.getActivity(applicationContext, MainActivity.OPEN_FROM_ANALYSIS_SERVICE, it, pendingIntentFlags)
        }
        val stopAction = NotificationCompat.Action.Builder(
            R.drawable.ic_outline_stop_24,
            applicationContext.getString(R.string.analysis_notification_action_stop),
            WorkManager.getInstance(applicationContext).createCancelPendingIntent(id)
        ).build()
        val contentTitle = title ?: applicationContext.getText(R.string.analysis_notification_default_title)
        val notification = NotificationCompat.Builder(applicationContext, NOTIFICATION_CHANNEL)
            .setContentTitle(contentTitle)
            .setTicker(contentTitle)
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_notification)
            .setOngoing(true)
            .setContentIntent(openAppIntent)
            .addAction(stopAction)
            .build()
        // from Android 14 (API 34), foreground service type is mandatory for long-running workers:
        // https://developer.android.com/guide/background/persistent/how-to/long-running
        return when {
            Build.VERSION.SDK_INT >= 35 -> ForegroundInfo(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROCESSING)
            Build.VERSION.SDK_INT == 34 -> ForegroundInfo(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            else -> ForegroundInfo(NOTIFICATION_ID, notification)
        }
    }

    private suspend fun updateNotification(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title")
        val message = call.argument<String>("message")
        setForeground(createForegroundInfo(title, message))
        result.success(null)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisWorker>()
        private const val BACKGROUND_CHANNEL = "deckers.thibault/aves/analysis_service_background"
        const val SHARED_PREFERENCES_KEY = "analysis_service"
        const val PREF_CALLBACK_HANDLE_KEY = "callback_handle"
        const val PREF_ENTRY_IDS_KEY = "entry_ids"

        const val NOTIFICATION_CHANNEL = "analysis"
        const val NOTIFICATION_ID = 1

        const val KEY_FORCE = "force"
    }
}
