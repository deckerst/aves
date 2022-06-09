package deckers.thibault.aves

import android.content.Intent
import android.net.Uri
import android.os.*
import android.util.Log
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.calls.*
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class WallpaperActivity : FlutterActivity() {
    private lateinit var intentDataMap: MutableMap<String, Any?>

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i(LOG_TAG, "onCreate intent=$intent")
        intent.extras?.takeUnless { it.isEmpty }?.let {
            Log.i(LOG_TAG, "onCreate intent extras=$it")
        }

        super.onCreate(savedInstanceState)

        val messenger = flutterEngine!!.dartExecutor.binaryMessenger

        // dart -> platform -> dart
        // - need Context
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(this))
        MethodChannel(messenger, EmbeddedDataHandler.CHANNEL).setMethodCallHandler(EmbeddedDataHandler(this))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(this))
        // - need Activity
        MethodChannel(messenger, AccessibilityHandler.CHANNEL).setMethodCallHandler(AccessibilityHandler(this))
        MethodChannel(messenger, MediaFileHandler.CHANNEL).setMethodCallHandler(MediaFileHandler(this))
        MethodChannel(messenger, WallpaperHandler.CHANNEL).setMethodCallHandler(WallpaperHandler(this))
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(WindowHandler(this))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }

        // intent handling
        // detail fetch: dart -> platform
        intentDataMap = extractIntentData(intent)
        MethodChannel(messenger, VIEWER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntentData" -> {
                    result.success(intentDataMap)
                    intentDataMap.clear()
                }
            }
        }
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

    override fun onStop() {
        Log.i(LOG_TAG, "onStop")
        super.onStop()
    }

    override fun onDestroy() {
        Log.i(LOG_TAG, "onDestroy")
        super.onDestroy()
    }

    private fun extractIntentData(intent: Intent?): MutableMap<String, Any?> {
        when (intent?.action) {
            Intent.ACTION_ATTACH_DATA, Intent.ACTION_SET_WALLPAPER -> {
                (intent.data ?: (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri))?.let { uri ->
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
        const val VIEWER_CHANNEL = "deckers.thibault/aves/viewer"
    }
}
