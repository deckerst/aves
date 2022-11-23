package deckers.thibault.aves

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.AvesByteSendingMethodCodec
import deckers.thibault.aves.channel.calls.*
import deckers.thibault.aves.channel.calls.window.ActivityWindowHandler
import deckers.thibault.aves.channel.calls.window.WindowHandler
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.FlutterUtils.enableSoftwareRendering
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.getParcelableExtraCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WallpaperActivity : FlutterActivity() {
    private lateinit var intentDataMap: MutableMap<String, Any?>

    override fun onCreate(savedInstanceState: Bundle?) {
        if (FlutterUtils.isSoftwareRenderingRequired()) {
            intent.enableSoftwareRendering()
        }
        super.onCreate(savedInstanceState)

        Log.i(LOG_TAG, "onCreate intent=$intent")
        intent.extras?.takeUnless { it.isEmpty }?.let {
            Log.i(LOG_TAG, "onCreate intent extras=$it")
        }
        intentDataMap = extractIntentData(intent)

        initChannels(this)
    }

    override fun onStart() {
        Log.i(LOG_TAG, "onStart")
        super.onStart()

        // as of Flutter v3.0.1, the window `viewInsets` and `viewPadding`
        // are incorrect on startup in some environments (e.g. API 29 emulator),
        // so we manually request to apply the insets to update the window metrics
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            Handler(Looper.getMainLooper()).postDelayed({
                window.decorView.requestApplyInsets()
            }, 100)
        }
    }

    private fun initChannels(activity: Activity) {
        val messenger = flutterEngine!!.dartExecutor

        // dart -> platform -> dart
        // - need Context
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(activity))
        MethodChannel(messenger, EmbeddedDataHandler.CHANNEL).setMethodCallHandler(EmbeddedDataHandler(activity))
        MethodChannel(messenger, MediaFetchBytesHandler.CHANNEL, AvesByteSendingMethodCodec.INSTANCE).setMethodCallHandler(MediaFetchBytesHandler(activity))
        MethodChannel(messenger, MediaFetchObjectHandler.CHANNEL).setMethodCallHandler(MediaFetchObjectHandler(activity))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(activity))
        MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(activity))
        // - need ContextWrapper
        MethodChannel(messenger, AccessibilityHandler.CHANNEL).setMethodCallHandler(AccessibilityHandler(activity))
        MethodChannel(messenger, WallpaperHandler.CHANNEL).setMethodCallHandler(WallpaperHandler(activity))
        // - need Activity
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(ActivityWindowHandler(activity))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(activity, args) }

        // intent handling
        // detail fetch: dart -> platform
        MethodChannel(messenger, MainActivity.INTENT_CHANNEL).setMethodCallHandler { call, result -> onMethodCall(call, result) }
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getIntentData" -> {
                result.success(intentDataMap)
                intentDataMap.clear()
            }
        }
    }

    private fun extractIntentData(intent: Intent?): MutableMap<String, Any?> {
        when (intent?.action) {
            Intent.ACTION_ATTACH_DATA, Intent.ACTION_SET_WALLPAPER -> {
                (intent.data ?: intent.getParcelableExtraCompat<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                    // MIME type is optional
                    val type = intent.type ?: intent.resolveType(context)
                    return hashMapOf(
                        MainActivity.INTENT_DATA_KEY_ACTION to MainActivity.INTENT_ACTION_SET_WALLPAPER,
                        MainActivity.INTENT_DATA_KEY_MIME_TYPE to type,
                        MainActivity.INTENT_DATA_KEY_URI to uri.toString(),
                    )
                }
            }
            Intent.ACTION_RUN -> {
                // flutter run
            }
            else -> {
                Log.w(LOG_TAG, "unhandled intent action=${intent?.action}")
            }
        }
        return HashMap()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<WallpaperActivity>()
    }
}
