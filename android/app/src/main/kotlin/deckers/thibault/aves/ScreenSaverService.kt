package deckers.thibault.aves

import android.service.dreams.DreamService
import android.view.View
import android.view.ViewTreeObserver
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.calls.AccessibilityHandler
import deckers.thibault.aves.channel.calls.DeviceHandler
import deckers.thibault.aves.channel.calls.MediaFileHandler
import deckers.thibault.aves.channel.calls.MediaStoreHandler
import deckers.thibault.aves.channel.calls.window.ServiceWindowHandler
import deckers.thibault.aves.channel.calls.window.WindowHandler
import deckers.thibault.aves.channel.streams.ImageByteStreamHandler
import deckers.thibault.aves.channel.streams.MediaStoreStreamHandler
import deckers.thibault.aves.utils.LogUtils
import io.flutter.FlutterInjector
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel

// for FlutterView-level integration, cf https://docs.flutter.dev/development/add-to-app/android/add-flutter-view
class ScreenSaverService : DreamService() {
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var activePreDrawListener: ViewTreeObserver.OnPreDrawListener? = null
    private var isFlutterUiDisplayed = false
    private var isFirstFrameRendered = false
    private var isAttached = false

    private val flutterUiDisplayListener: FlutterUiDisplayListener = object : FlutterUiDisplayListener {
        override fun onFlutterUiDisplayed() {
            isFlutterUiDisplayed = true
            isFirstFrameRendered = true
        }

        override fun onFlutterUiNoLongerDisplayed() {
            isFlutterUiDisplayed = false
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        onAttach()

        val messenger = flutterEngine!!.dartExecutor.binaryMessenger

        // dart -> platform -> dart
        // - need Context
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(this))
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(this))
        // - need ContextWrapper
        MethodChannel(messenger, AccessibilityHandler.CHANNEL).setMethodCallHandler(AccessibilityHandler(this))
        MethodChannel(messenger, MediaFileHandler.CHANNEL).setMethodCallHandler(MediaFileHandler(this))
        // - need Service
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(ServiceWindowHandler(this))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(this, args) }

        // intent handling
        // detail fetch: dart -> platform
        MethodChannel(messenger, WallpaperActivity.VIEWER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntentData" -> {
                    result.success(intentDataMap)
                    intentDataMap.clear()
                }
            }
        }

        // dream setup
        isInteractive = false
        isFullscreen = true
        setContentView(createFlutterView())
    }

    override fun onDreamingStarted() {
        super.onDreamingStarted()
        onStart()
    }

    override fun onDreamingStopped() {
        onDestroyView()
        super.onDreamingStopped()
    }

    override fun onDetachedFromWindow() {
        release()
        super.onDetachedFromWindow()
    }

    // from `FlutterActivityAndFragmentDelegate`

    private fun createFlutterView(): View {
        Log.d(LOG_TAG, "Creating FlutterView.")
        val flutterSurfaceView = FlutterSurfaceView(this)
        val pFlutterView = FlutterView(this, flutterSurfaceView)
        flutterView = pFlutterView

        // Add listener to be notified when Flutter renders its first frame.
        pFlutterView.addOnFirstFrameRenderedListener(flutterUiDisplayListener)
        Log.d(LOG_TAG, "Attaching FlutterEngine to FlutterView.")
        pFlutterView.attachToFlutterEngine(flutterEngine!!)
        pFlutterView.id = FlutterActivity.FLUTTER_VIEW_ID
        delayFirstAndroidViewDraw(pFlutterView)
        return pFlutterView
    }

    private fun release() {
        flutterEngine = null
        flutterView = null
    }

    private fun onAttach() {
        if (flutterEngine == null) {
            Log.d(LOG_TAG, "Setting up FlutterEngine.")
            flutterEngine = FlutterEngine(
                this,
                null,
                false,
            )
        }
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine!!)
        isAttached = true
    }

    private fun onStart() {
        Log.d(LOG_TAG, "onStart()")
        doInitialFlutterViewRun()
        flutterView!!.visibility = View.VISIBLE
        flutterEngine!!.lifecycleChannel.appIsResumed()
    }

    private fun onDestroyView() {
        Log.v(LOG_TAG, "onDestroyView()")
        flutterView ?: return

        val pFlutterView = flutterView!!
        if (activePreDrawListener != null) {
            pFlutterView.viewTreeObserver.removeOnPreDrawListener(activePreDrawListener)
            activePreDrawListener = null
        }
        pFlutterView.detachFromFlutterEngine()
        pFlutterView.removeOnFirstFrameRenderedListener(flutterUiDisplayListener)

        flutterEngine!!.lifecycleChannel.appIsInactive()
    }

    private fun delayFirstAndroidViewDraw(flutterView: FlutterView) {
        if (activePreDrawListener != null) {
            flutterView.viewTreeObserver.removeOnPreDrawListener(activePreDrawListener)
        }
        activePreDrawListener = object : ViewTreeObserver.OnPreDrawListener {
            override fun onPreDraw(): Boolean {
                if (isFlutterUiDisplayed && activePreDrawListener != null) {
                    flutterView.viewTreeObserver.removeOnPreDrawListener(this)
                    activePreDrawListener = null
                }
                return isFlutterUiDisplayed
            }
        }
        flutterView.viewTreeObserver.addOnPreDrawListener(activePreDrawListener)
    }

    private fun doInitialFlutterViewRun() {
        val pFlutterEngine = flutterEngine!!
        if (pFlutterEngine.dartExecutor.isExecutingDart) {
            // No warning is logged because this situation will happen on every config
            // change if the developer does not choose to retain the Fragment instance.
            // So this is expected behavior in many cases.
            return
        }

        pFlutterEngine.navigationChannel.setInitialRoute(DEFAULT_INITIAL_ROUTE)
        val appBundlePathOverride = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        val entrypoint = DartEntrypoint(appBundlePathOverride, DEFAULT_DART_ENTRYPOINT)
        pFlutterEngine.dartExecutor.executeDartEntrypoint(entrypoint)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ScreenSaverService>()
        private val intentDataMap: MutableMap<String, Any?> = hashMapOf(
            MainActivity.INTENT_DATA_KEY_ACTION to MainActivity.INTENT_ACTION_SCREEN_SAVER,
        )

        // from `FlutterActivityLaunchConfigs`
        const val DEFAULT_DART_ENTRYPOINT = "main"
        const val DEFAULT_INITIAL_ROUTE = "/"
    }
}