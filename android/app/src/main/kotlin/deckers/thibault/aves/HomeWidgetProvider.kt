package deckers.thibault.aves

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.AvesByteSendingMethodCodec
import deckers.thibault.aves.channel.calls.*
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.MediaStoreStreamHandler
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.nio.ByteBuffer
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import kotlin.math.roundToInt

class HomeWidgetProvider : AppWidgetProvider() {
    private val defaultScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d(LOG_TAG, "Widget onUpdate widgetIds=${appWidgetIds.contentToString()}")
        for (widgetId in appWidgetIds) {
            val widgetInfo = appWidgetManager.getAppWidgetOptions(widgetId)

            defaultScope.launch {
                val backgroundProps = getProps(context, widgetId, widgetInfo, drawEntryImage = false)
                updateWidgetImage(context, appWidgetManager, widgetId, widgetInfo, backgroundProps)

                val imageProps = getProps(context, widgetId, widgetInfo, drawEntryImage = true, reuseEntry = false)
                updateWidgetImage(context, appWidgetManager, widgetId, widgetInfo, imageProps)
            }
        }
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager?, widgetId: Int, widgetInfo: Bundle?) {
        Log.d(LOG_TAG, "Widget onAppWidgetOptionsChanged widgetId=$widgetId")
        appWidgetManager ?: return
        widgetInfo ?: return

        if (imageByteFetchJob != null) {
            imageByteFetchJob?.cancel()
        }
        imageByteFetchJob = defaultScope.launch {
            delay(500)
            val imageProps = getProps(context, widgetId, widgetInfo, drawEntryImage = true, reuseEntry = true)
            updateWidgetImage(context, appWidgetManager, widgetId, widgetInfo, imageProps)
        }
    }

    private fun getDevicePixelRatio(): Float = Resources.getSystem().displayMetrics.density

    private fun getWidgetSizePx(context: Context, widgetInfo: Bundle): Pair<Int, Int> {
        val devicePixelRatio = getDevicePixelRatio()
        val isPortrait = context.resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT
        val widthKey = if (isPortrait) AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH else AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH
        val heightKey = if (isPortrait) AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT else AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT
        val widthPx = (widgetInfo.getInt(widthKey) * devicePixelRatio).roundToInt()
        val heightPx = (widgetInfo.getInt(heightKey) * devicePixelRatio).roundToInt()
        return Pair(widthPx, heightPx)
    }

    private suspend fun getProps(
        context: Context,
        widgetId: Int,
        widgetInfo: Bundle,
        drawEntryImage: Boolean,
        reuseEntry: Boolean = false,
    ): FieldMap? {
        val (widthPx, heightPx) = getWidgetSizePx(context, widgetInfo)
        if (widthPx == 0 || heightPx == 0) return null

        initFlutterEngine(context)
        val messenger = flutterEngine!!.dartExecutor
        val channel = MethodChannel(messenger, WIDGET_DRAW_CHANNEL)
        try {
            val props = suspendCoroutine<Any?> { cont ->
                defaultScope.launch {
                    FlutterUtils.runOnUiThread {
                        channel.invokeMethod("drawWidget", hashMapOf(
                            "widgetId" to widgetId,
                            "widthPx" to widthPx,
                            "heightPx" to heightPx,
                            "devicePixelRatio" to getDevicePixelRatio(),
                            "drawEntryImage" to drawEntryImage,
                            "reuseEntry" to reuseEntry,
                        ), object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                cont.resume(result)
                            }

                            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                                cont.resumeWithException(Exception("$errorCode: $errorMessage\n$errorDetails"))
                            }

                            override fun notImplemented() {
                                cont.resumeWithException(Exception("not implemented"))
                            }
                        })
                    }
                }
            }
            @Suppress("unchecked_cast")
            return props as FieldMap?
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to draw widget for widgetId=$widgetId widthPx=$widthPx heightPx=$heightPx", e)
        }
        return null
    }

    private fun updateWidgetImage(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetInfo: Bundle,
        props: FieldMap?,
    ) {
        props ?: return

        val bytes = props["bytes"] as ByteArray?
        val updateOnTap = props["updateOnTap"] as Boolean?
        if (bytes == null || updateOnTap == null) {
            Log.e(LOG_TAG, "missing arguments")
            return
        }

        val (widthPx, heightPx) = getWidgetSizePx(context, widgetInfo)
        if (widthPx == 0 || heightPx == 0) return

        try {
            val bitmap = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
            bitmap.copyPixelsFromBuffer(ByteBuffer.wrap(bytes))

            val pendingIntent = if (updateOnTap) buildUpdateIntent(context, widgetId) else buildOpenAppIntent(context, widgetId)

            val views = RemoteViews(context.packageName, R.layout.app_widget).apply {
                setImageViewBitmap(R.id.widget_img, bitmap)
                setOnClickPendingIntent(R.id.widget_img, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
            bitmap.recycle()
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to draw widget", e)
        }
    }

    private fun buildUpdateIntent(context: Context, widgetId: Int): PendingIntent {
        val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE, Uri.parse("widget://$widgetId"), context, HomeWidgetProvider::class.java)
            .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(widgetId))

        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
    }

    private fun buildOpenAppIntent(context: Context, widgetId: Int): PendingIntent {
        // set a unique URI to prevent the intent (and its extras) from being shared by different widgets
        val intent = Intent(MainActivity.INTENT_ACTION_WIDGET_OPEN, Uri.parse("widget://$widgetId"), context, MainActivity::class.java)
            .putExtra(MainActivity.EXTRA_KEY_WIDGET_ID, widgetId)

        return PendingIntent.getActivity(
            context,
            0,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<HomeWidgetProvider>()
        private const val WIDGET_DART_ENTRYPOINT = "widgetMain"
        private const val WIDGET_DRAW_CHANNEL = "deckers.thibault/aves/widget_draw"

        private var flutterEngine: FlutterEngine? = null
        private var imageByteFetchJob: Job? = null

        private suspend fun initFlutterEngine(context: Context) {
            if (flutterEngine != null) return

            FlutterUtils.runOnUiThread {
                flutterEngine = FlutterEngine(context.applicationContext)
            }
            initChannels(context)

            flutterEngine!!.apply {
                if (!dartExecutor.isExecutingDart) {
                    val appBundlePathOverride = FlutterInjector.instance().flutterLoader().findAppBundlePath()
                    val entrypoint = DartExecutor.DartEntrypoint(appBundlePathOverride, WIDGET_DART_ENTRYPOINT)
                    FlutterUtils.runOnUiThread {
                        dartExecutor.executeDartEntrypoint(entrypoint)
                    }
                }
            }
        }

        private fun initChannels(context: Context) {
            val engine = flutterEngine
            engine ?: throw Exception("Flutter engine is not initialized")

            val messenger = engine.dartExecutor

            // dart -> platform -> dart
            // - need Context
            MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(context))
            MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(context))
            MethodChannel(messenger, MediaFetchBytesHandler.CHANNEL, AvesByteSendingMethodCodec.INSTANCE).setMethodCallHandler(MediaFetchBytesHandler(context))
            MethodChannel(messenger, MediaFetchObjectHandler.CHANNEL).setMethodCallHandler(MediaFetchObjectHandler(context))
            MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(context))

            // result streaming: dart -> platform ->->-> dart
            // - need Context
            StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(context, args) }
            StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(context, args) }
        }
    }
}
