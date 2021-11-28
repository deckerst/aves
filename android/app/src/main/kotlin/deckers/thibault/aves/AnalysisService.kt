package deckers.thibault.aves

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.*
import android.util.Log
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.MainActivity.Companion.OPEN_FROM_ANALYSIS_SERVICE
import deckers.thibault.aves.channel.calls.DeviceHandler
import deckers.thibault.aves.channel.calls.GeocodingHandler
import deckers.thibault.aves.channel.calls.MediaStoreHandler
import deckers.thibault.aves.channel.calls.MetadataFetchHandler
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.MediaStoreStreamHandler
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.runBlocking
import java.util.*

class AnalysisService : MethodChannel.MethodCallHandler, Service() {
    private var backgroundFlutterEngine: FlutterEngine? = null
    private var backgroundChannel: MethodChannel? = null
    private var serviceLooper: Looper? = null
    private var serviceHandler: ServiceHandler? = null
    private val analysisServiceBinder = AnalysisServiceBinder()

    override fun onCreate() {
        Log.i(LOG_TAG, "Create analysis service")
        val context = this

        runBlocking {
            FlutterUtils.initFlutterEngine(context, SHARED_PREFERENCES_KEY, CALLBACK_HANDLE_KEY) {
                backgroundFlutterEngine = it
            }
        }

        val messenger = backgroundFlutterEngine!!.dartExecutor.binaryMessenger
        // channels for analysis
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(this))
        MethodChannel(messenger, GeocodingHandler.CHANNEL).setMethodCallHandler(GeocodingHandler(this))
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(this))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(this))
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(this, args) }
        // channel for service management
        backgroundChannel = MethodChannel(messenger, BACKGROUND_CHANNEL).apply {
            setMethodCallHandler(context)
        }

        HandlerThread("Analysis service handler", Process.THREAD_PRIORITY_BACKGROUND).apply {
            start()
            serviceLooper = looper
            serviceHandler = ServiceHandler(looper)
        }
    }

    override fun onDestroy() {
        Log.i(LOG_TAG, "Destroy analysis service")
    }

    override fun onBind(intent: Intent) = analysisServiceBinder

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val channel = NotificationChannelCompat.Builder(CHANNEL_ANALYSIS, NotificationManagerCompat.IMPORTANCE_LOW)
            .setName(getText(R.string.analysis_channel_name))
            .setShowBadge(false)
            .build()
        NotificationManagerCompat.from(this).createNotificationChannel(channel)
        startForeground(NOTIFICATION_ID, buildNotification())

        val msgData = Bundle()
        intent.extras?.let {
            msgData.putAll(it)
        }
        serviceHandler?.obtainMessage()?.let { msg ->
            msg.arg1 = startId
            msg.data = msgData
            serviceHandler?.sendMessage(msg)
        }

        return START_NOT_STICKY
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialized" -> {
                Log.d(LOG_TAG, "background channel is ready")
                result.success(null)
            }
            "updateNotification" -> {
                val title = call.argument<String>("title")
                val message = call.argument<String>("message")
                val notification = buildNotification(title, message)
                NotificationManagerCompat.from(this).notify(NOTIFICATION_ID, notification)
                result.success(null)
            }
            "refreshApp" -> {
                analysisServiceBinder.refreshApp()
                result.success(null)
            }
            "stop" -> {
                detachAndStop()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun detachAndStop() {
        analysisServiceBinder.detach()
        stopSelf()
    }

    private fun buildNotification(title: String? = null, message: String? = null): Notification {
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val stopServiceIntent = Intent(this, AnalysisService::class.java).let {
            it.putExtra(KEY_COMMAND, COMMAND_STOP)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                PendingIntent.getForegroundService(this, STOP_SERVICE_REQUEST, it, pendingIntentFlags)
            } else {
                PendingIntent.getService(this, STOP_SERVICE_REQUEST, it, pendingIntentFlags)
            }
        }
        val openAppIntent = Intent(this, MainActivity::class.java).let {
            PendingIntent.getActivity(this, OPEN_FROM_ANALYSIS_SERVICE, it, pendingIntentFlags)
        }
        val stopAction = NotificationCompat.Action.Builder(
            R.drawable.ic_outline_stop_24,
            getString(R.string.analysis_notification_action_stop),
            stopServiceIntent
        ).build()
        return NotificationCompat.Builder(this, CHANNEL_ANALYSIS)
            .setContentTitle(title ?: getText(R.string.analysis_notification_default_title))
            .setContentText(message)
            .setBadgeIconType(NotificationCompat.BADGE_ICON_NONE)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(openAppIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(stopAction)
            .build()
    }

    private inner class ServiceHandler(looper: Looper) : Handler(looper) {
        override fun handleMessage(msg: Message) {
            val data = msg.data
            when (data.getString(KEY_COMMAND)) {
                COMMAND_START -> {
                    runBlocking {
                        FlutterUtils.runOnUiThread {
                            val contentIds = data.get(KEY_CONTENT_IDS)?.takeIf { it is IntArray }?.let { (it as IntArray).toList() }
                            backgroundChannel?.invokeMethod(
                                "start", hashMapOf(
                                    "contentIds" to contentIds,
                                    "force" to data.getBoolean(KEY_FORCE),
                                )
                            )
                        }
                    }
                }
                COMMAND_STOP -> {
                    // unconditionally stop the service
                    runBlocking {
                        FlutterUtils.runOnUiThread {
                            backgroundChannel?.invokeMethod("stop", null)
                        }
                    }
                    detachAndStop()
                }
                else -> {
                }
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisService>()
        private const val BACKGROUND_CHANNEL = "deckers.thibault/aves/analysis_service_background"
        const val SHARED_PREFERENCES_KEY = "analysis_service"
        const val CALLBACK_HANDLE_KEY = "callback_handle"

        const val NOTIFICATION_ID = 1
        const val STOP_SERVICE_REQUEST = 1
        const val CHANNEL_ANALYSIS = "analysis"

        const val KEY_COMMAND = "command"
        const val COMMAND_START = "start"
        const val COMMAND_STOP = "stop"
        const val KEY_CONTENT_IDS = "content_ids"
        const val KEY_FORCE = "force"
    }
}

class AnalysisServiceBinder : Binder() {
    private val listeners = hashSetOf<AnalysisServiceListener>()

    fun startListening(listener: AnalysisServiceListener) = listeners.add(listener)

    fun stopListening(listener: AnalysisServiceListener) = listeners.remove(listener)

    fun refreshApp() {
        val localListeners = listeners.toSet()
        for (listener in localListeners) {
            try {
                listener.refreshApp()
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to notify listener=$listener", e)
            }
        }
    }

    fun detach() {
        val localListeners = listeners.toSet()
        for (listener in localListeners) {
            try {
                listener.detachFromActivity()
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to detach listener=$listener", e)
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisServiceBinder>()
    }
}

interface AnalysisServiceListener {
    fun refreshApp()
    fun detachFromActivity()
}