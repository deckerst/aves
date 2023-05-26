package deckers.thibault.aves

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
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
import deckers.thibault.aves.channel.calls.DeviceHandler
import deckers.thibault.aves.channel.calls.GeocodingHandler
import deckers.thibault.aves.channel.calls.MediaStoreHandler
import deckers.thibault.aves.channel.calls.MetadataFetchHandler
import deckers.thibault.aves.channel.calls.StorageHandler
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.MediaStoreStreamHandler
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.runBlocking
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class AnalysisWorker(context: Context, parameters: WorkerParameters) : CoroutineWorker(context, parameters) {
    private var workCont: Continuation<Any?>? = null
    private var flutterEngine: FlutterEngine? = null
    private var backgroundChannel: MethodChannel? = null

    override suspend fun doWork(): Result {
        createNotificationChannel()
        setForeground(createForegroundInfo())
        suspendCoroutine { cont ->
            workCont = cont
            onStart()
        }
        return Result.success()
    }

    private fun onStart() {
        Log.i(LOG_TAG, "Start analysis worker")
        runBlocking {
            FlutterUtils.initFlutterEngine(applicationContext, SHARED_PREFERENCES_KEY, CALLBACK_HANDLE_KEY) {
                flutterEngine = it
            }
        }

        try {
            initChannels(applicationContext)

            runBlocking {
                FlutterUtils.runOnUiThread {
                    backgroundChannel?.invokeMethod(
                        "start", hashMapOf(
                            "entryIds" to inputData.getIntArray(KEY_ENTRY_IDS)?.toList(),
                            "force" to inputData.getBoolean(KEY_FORCE, false),
                            "progressTotal" to inputData.getInt(KEY_PROGRESS_TOTAL, 0),
                            "progressOffset" to inputData.getInt(KEY_PROGRESS_OFFSET, 0),
                        )
                    )
                }
            }
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

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialized" -> {
                Log.d(LOG_TAG, "Analysis background channel is ready")
                result.success(null)
            }

            "updateNotification" -> {
                val title = call.argument<String>("title")
                val message = call.argument<String>("message")
                setForegroundAsync(createForegroundInfo(title, message))
                result.success(null)
            }

            "stop" -> {
                workCont?.resume(null)
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
        val icon = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) R.drawable.ic_notification else R.mipmap.ic_launcher_round
        val notification = NotificationCompat.Builder(applicationContext, NOTIFICATION_CHANNEL)
            .setContentTitle(title ?: applicationContext.getText(R.string.analysis_notification_default_title))
            .setContentText(message)
            .setBadgeIconType(NotificationCompat.BADGE_ICON_NONE)
            .setSmallIcon(icon)
            .setContentIntent(openAppIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(stopAction)
            .build()
        return ForegroundInfo(NOTIFICATION_ID, notification)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisWorker>()
        private const val BACKGROUND_CHANNEL = "deckers.thibault/aves/analysis_service_background"
        const val SHARED_PREFERENCES_KEY = "analysis_service"
        const val CALLBACK_HANDLE_KEY = "callback_handle"

        const val NOTIFICATION_CHANNEL = "analysis"
        const val NOTIFICATION_ID = 1

        const val KEY_ENTRY_IDS = "entry_ids"
        const val KEY_FORCE = "force"
        const val KEY_PROGRESS_TOTAL = "progress_total"
        const val KEY_PROGRESS_OFFSET = "progress_offset"
    }
}
