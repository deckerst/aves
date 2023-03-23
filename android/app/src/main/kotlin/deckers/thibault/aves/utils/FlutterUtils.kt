package deckers.thibault.aves.utils

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.view.FlutterCallbackInformation
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

object FlutterUtils {
    private val LOG_TAG = LogUtils.createTag<FlutterUtils>()

    suspend fun initFlutterEngine(
        context: Context,
        sharedPreferencesKey: String,
        callbackHandleKey: String,
        engineSetter: (engine: FlutterEngine) -> Unit,
    ) {
        val callbackHandle = context.getSharedPreferences(sharedPreferencesKey, Context.MODE_PRIVATE).getLong(callbackHandleKey, 0)
        if (callbackHandle == 0L) {
            Log.e(LOG_TAG, "failed to retrieve registered callback handle for sharedPreferencesKey=$sharedPreferencesKey callbackHandleKey=$callbackHandleKey")
            return
        }

        lateinit var flutterLoader: FlutterLoader
        runOnUiThread {
            // initialization must happen on the main thread
            flutterLoader = FlutterInjector.instance().flutterLoader().apply {
                startInitialization(context)
                ensureInitializationComplete(context, null)
            }
        }

        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        if (callbackInfo == null) {
            Log.e(LOG_TAG, "failed to find callback information for sharedPreferencesKey=$sharedPreferencesKey callbackHandleKey=$callbackHandleKey")
            return
        }

        val args = DartExecutor.DartCallback(
            context.assets,
            flutterLoader.findAppBundlePath(),
            callbackInfo
        )
        runOnUiThread {
            val engine = FlutterEngine(context).apply {
                dartExecutor.executeDartCallback(args)
            }
            engineSetter(engine)
        }
    }

    suspend fun runOnUiThread(r: Runnable) {
        val mainLooper = Looper.getMainLooper()
        if (Looper.myLooper() != mainLooper) {
            suspendCoroutine<Boolean> { cont ->
                Handler(mainLooper).post {
                    r.run()
                    cont.resume(true)
                }
            }
        } else {
            r.run()
        }
    }

    fun Intent.enableSoftwareRendering() {
        putExtra("enable-software-rendering", true)
        Log.i(LOG_TAG, "Enable software rendering")
    }

    fun isSoftwareRenderingRequired() = Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT && isEmulator

    private val isEmulator: Boolean
        get() = (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
                || Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.PRODUCT.contains("sdk_google")
                || Build.PRODUCT.contains("google_sdk")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("sdk_x86")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.contains("emulator")
                || Build.PRODUCT.contains("simulator"))
}