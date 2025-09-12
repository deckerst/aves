package deckers.thibault.aves

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.SizeF
import android.widget.RemoteViews
import androidx.core.graphics.createBitmap
import androidx.core.net.toUri
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.calls.DeviceHandler
import deckers.thibault.aves.channel.calls.MediaFetchObjectHandler
import deckers.thibault.aves.channel.calls.MediaStoreHandler
import deckers.thibault.aves.channel.calls.StorageHandler
import deckers.thibault.aves.channel.streams.darttoplatform.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.darttoplatform.MediaStoreStreamHandler
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.nio.ByteBuffer
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import kotlin.math.roundToInt

class HomeWidgetProvider : AppWidgetProvider() {
    private val defaultScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d(LOG_TAG, "Widget onUpdate widgetIds=${appWidgetIds.contentToString()}")
        val pendingResult = goAsync()
        defaultScope.launch {
            for (widgetId in appWidgetIds) {
                val widgetInfo = appWidgetManager.getAppWidgetOptions(widgetId)

                val backgroundProps = getProps(context, widgetId, widgetInfo, drawEntryImage = false)
                updateWidgetImage(context, appWidgetManager, widgetId, backgroundProps)

                val imageProps = getProps(context, widgetId, widgetInfo, drawEntryImage = true, reuseEntry = false)
                updateWidgetImage(context, appWidgetManager, widgetId, imageProps)
            }
            try {
                pendingResult?.finish()
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to finish update for widgetIds=${appWidgetIds.contentToString()}", e)
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
            updateWidgetImage(context, appWidgetManager, widgetId, imageProps)
        }
    }

    private fun getDevicePixelRatio(): Float = Resources.getSystem().displayMetrics.density

    private fun getWidgetSizesDip(context: Context, widgetInfo: Bundle): List<SizeF> {
        var sizes: List<SizeF>? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            widgetInfo.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES, SizeF::class.java)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            @Suppress("deprecation")
            widgetInfo.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES)
        } else {
            null
        }

        if (sizes.isNullOrEmpty()) {
            val isPortrait = context.resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT
            val widthKey = if (isPortrait) AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH else AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH
            val heightKey = if (isPortrait) AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT else AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT
            val widthDip = widgetInfo.getInt(widthKey)
            val heightDip = widgetInfo.getInt(heightKey)
            sizes = listOf(SizeF(widthDip.toFloat(), heightDip.toFloat()))
        }

        return sizes
    }

    private suspend fun getProps(
        context: Context,
        widgetId: Int,
        widgetInfo: Bundle,
        drawEntryImage: Boolean,
        reuseEntry: Boolean = false,
    ): FieldMap? {
        val sizesDip = getWidgetSizesDip(context, widgetInfo)
        if (sizesDip.isEmpty()) return null

        val sizeDip = sizesDip.first()
        if (sizeDip.width == 0f || sizeDip.height == 0f) return null

        val sizesDipMap = sizesDip.map { size -> hashMapOf("widthDip" to size.width, "heightDip" to size.height) }
        val isNightModeOn = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

        val params = hashMapOf(
            "widgetId" to widgetId,
            "sizesDip" to sizesDipMap,
            "devicePixelRatio" to getDevicePixelRatio(),
            "drawEntryImage" to drawEntryImage,
            "reuseEntry" to reuseEntry,
            "isSystemThemeDark" to isNightModeOn,
        ).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                put("cornerRadiusPx", context.resources.getDimension(android.R.dimen.system_app_widget_background_radius))
            }
        }

        initFlutterEngine(context)
        try {
            val props = suspendCoroutine { cont ->
                defaultScope.launch {
                    FlutterUtils.runOnUiThread {
                        tryDrawWidget(params, cont, 0)
                    }
                }
            }
            @Suppress("unchecked_cast")
            return props as FieldMap?
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to draw widget for widgetId=$widgetId sizesPx=$sizesDip", e)
        }
        return null
    }

    private fun tryDrawWidget(params: HashMap<String, Any>, cont: Continuation<Any?>, drawRetry: Int) {
        val messenger = flutterEngine!!.dartExecutor
        val channel = MethodChannel(messenger, WIDGET_DRAW_CHANNEL)
        channel.invokeMethod("drawWidget", params, object : MethodChannel.Result {
            override fun success(result: Any?) {
                cont.resume(result)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                cont.resumeWithException(Exception("$errorCode: $errorMessage\n$errorDetails"))
            }

            override fun notImplemented() {
                if (drawRetry > DRAW_RETRY_MAX) {
                    cont.resumeWithException(Exception("not implemented"))
                } else {
                    Handler(Looper.getMainLooper()).postDelayed({
                        tryDrawWidget(params, cont, drawRetry + 1)
                    }, 2000L)
                }
            }
        })
    }

    private fun updateWidgetImage(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        props: FieldMap?,
    ) {
        props ?: return

        val bytesBySizeDip = (props["bytesBySizeDip"] as List<*>?)?.mapNotNull {
            if (it is Map<*, *>) {
                val widthDip = (it["widthDip"] as Number?)?.toFloat()
                val heightDip = (it["heightDip"] as Number?)?.toFloat()
                val bytes = it["bytes"] as ByteArray?
                if (widthDip != null && heightDip != null && bytes != null) {
                    Pair(SizeF(widthDip, heightDip), bytes)
                } else null
            } else null
        }
        val updateOnTap = props["updateOnTap"] as Boolean?
        if (bytesBySizeDip == null || updateOnTap == null) {
            Log.e(LOG_TAG, "missing arguments")
            return
        }

        if (bytesBySizeDip.isEmpty()) {
            Log.e(LOG_TAG, "empty image list")
            return
        }

        val bitmaps = ArrayList<Bitmap>()

        fun createRemoteViewsForSize(
            context: Context,
            widgetId: Int,
            sizeDip: SizeF,
            bytes: ByteArray,
            updateOnTap: Boolean,
        ): RemoteViews? {
            val devicePixelRatio = getDevicePixelRatio()
            val widthPx = (sizeDip.width * devicePixelRatio).roundToInt()
            val heightPx = (sizeDip.height * devicePixelRatio).roundToInt()

            try {
                val bitmap = createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888).also {
                    bitmaps.add(it)
                    it.copyPixelsFromBuffer(ByteBuffer.wrap(bytes))
                }

                val pendingIntent = if (updateOnTap) buildUpdateIntent(context, widgetId) else buildOpenAppIntent(context, widgetId)

                return RemoteViews(context.packageName, R.layout.app_widget).apply {
                    setImageViewBitmap(R.id.widget_img, bitmap)
                    setOnClickPendingIntent(R.id.widget_img, pendingIntent)
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "failed to draw widget", e)
            }
            return null
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // multiple rendering for all possible sizes
                val views = RemoteViews(
                    bytesBySizeDip.associateBy(
                        { (sizeDip, _) -> sizeDip },
                        { (sizeDip, bytes) -> createRemoteViewsForSize(context, widgetId, sizeDip, bytes, updateOnTap) },
                    ).filterValues { it != null }.mapValues { (_, view) -> view!! }
                )
                appWidgetManager.updateAppWidget(widgetId, views)
            } else {
                // single rendering
                val (sizeDip, bytes) = bytesBySizeDip.first()
                val views = createRemoteViewsForSize(context, widgetId, sizeDip, bytes, updateOnTap)
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to draw widget", e)
        } finally {
            bitmaps.forEach { it.recycle() }
            bitmaps.clear()
        }
    }

    private fun buildUpdateIntent(context: Context, widgetId: Int): PendingIntent {
        val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE, "widget://$widgetId".toUri(), context, HomeWidgetProvider::class.java)
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
        val intent = Intent(MainActivity.INTENT_ACTION_WIDGET_OPEN, "widget://$widgetId".toUri(), context, MainActivity::class.java)
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
        private const val DRAW_RETRY_MAX = 5

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
            MethodChannel(messenger, MediaFetchObjectHandler.CHANNEL).setMethodCallHandler(MediaFetchObjectHandler(context))
            MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(context))

            // result streaming: dart -> platform ->->-> dart
            // - need Context
            StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(context, args) }
            StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(context, args) }
        }
    }
}
