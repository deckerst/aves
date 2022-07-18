package deckers.thibault.aves

import android.service.dreams.DreamService
import android.util.Log
import android.view.View
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.calls.*
import deckers.thibault.aves.channel.calls.window.ServiceWindowHandler
import deckers.thibault.aves.channel.calls.window.WindowHandler
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.MediaStoreStreamHandler
import deckers.thibault.aves.utils.LogUtils
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.plugin.common.MethodChannel

// for FlutterView-level integration, cf https://docs.flutter.dev/development/add-to-app/android/add-flutter-view
class ScreenSaverService : DreamService() {
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null

    override fun onAttachedToWindow() {
        Log.i(LOG_TAG, "onAttachedToWindow")
        super.onAttachedToWindow()
        initDream()
        createEngine()
        setContentView(createView())
    }

    override fun onDreamingStarted() {
        Log.i(LOG_TAG, "onDreamingStarted")
        super.onDreamingStarted()
        onStart()
    }

    override fun onDreamingStopped() {
        Log.i(LOG_TAG, "onDreamingStopped")
        release()
        super.onDreamingStopped()
    }

    override fun onDetachedFromWindow() {
        Log.i(LOG_TAG, "onDetachedFromWindow")
        destroyView()
        super.onDetachedFromWindow()
    }

    private fun initDream() {
        isInteractive = false
        isFullscreen = true
    }

    private fun createEngine() {
        flutterEngine = flutterEngine ?: FlutterEngine(this, null, false)
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine!!)
        initChannels()
    }

    private fun createView(): View {
        flutterView = FlutterView(this, FlutterSurfaceView(this)).apply {
            id = FlutterActivity.FLUTTER_VIEW_ID
            attachToFlutterEngine(flutterEngine!!)
        }
        return flutterView!!
    }

    private fun destroyView() {
        flutterEngine?.lifecycleChannel?.appIsDetached()
        flutterView?.detachFromFlutterEngine()
    }

    private fun release() {
        destroyView()
        flutterEngine = null
        flutterView = null
    }

    private fun onStart() {
        flutterEngine!!.apply {
            if (!dartExecutor.isExecutingDart) {
                navigationChannel.setInitialRoute(DEFAULT_INITIAL_ROUTE)
                val appBundlePathOverride = FlutterInjector.instance().flutterLoader().findAppBundlePath()
                val entrypoint = DartEntrypoint(appBundlePathOverride, DEFAULT_DART_ENTRYPOINT)
                dartExecutor.executeDartEntrypoint(entrypoint)
            }
            lifecycleChannel.appIsResumed()
        }
    }

    private fun initChannels() {
        val messenger = flutterEngine!!.dartExecutor

        // dart -> platform -> dart
        // - need Context
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(this))
        MethodChannel(messenger, EmbeddedDataHandler.CHANNEL).setMethodCallHandler(EmbeddedDataHandler(this))
        MethodChannel(messenger, MediaFetchHandler.CHANNEL).setMethodCallHandler(MediaFetchHandler(this))
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(this))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(this))
        // - need ContextWrapper
        MethodChannel(messenger, AccessibilityHandler.CHANNEL).setMethodCallHandler(AccessibilityHandler(this))
        // - need Service
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(ServiceWindowHandler(this))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(this, args) }

        // intent handling
        // detail fetch: dart -> platform
        MethodChannel(messenger, MainActivity.INTENT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntentData" -> {
                    result.success(intentDataMap)
                }
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ScreenSaverService>()
        private val intentDataMap: Map<String, Any?> = hashMapOf(
            MainActivity.INTENT_DATA_KEY_ACTION to MainActivity.INTENT_ACTION_SCREEN_SAVER,
        )

        // from `FlutterActivityLaunchConfigs`
        const val DEFAULT_DART_ENTRYPOINT = "main"
        const val DEFAULT_INITIAL_ROUTE = "/"
    }
}