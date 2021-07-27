package deckers.thibault.aves

import android.app.SearchManager
import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.util.Log
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class SearchSuggestionsProvider : MethodChannel.MethodCallHandler, ContentProvider() {
    override fun query(uri: Uri, projection: Array<String>?, selection: String?, selectionArgs: Array<String>?, sortOrder: String?): Cursor? {
        return selectionArgs?.firstOrNull()?.let { query ->
            // Samsung Finder does not support:
            // - resource ID as value for SUGGEST_COLUMN_ICON_1
            // - SUGGEST_COLUMN_ICON_2
            // - SUGGEST_COLUMN_RESULT_CARD_IMAGE
            val columns = arrayOf(
                SearchManager.SUGGEST_COLUMN_INTENT_DATA,
                SearchManager.SUGGEST_COLUMN_INTENT_EXTRA_DATA,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) SearchManager.SUGGEST_COLUMN_CONTENT_TYPE else "mimeType",
                SearchManager.SUGGEST_COLUMN_TEXT_1,
                SearchManager.SUGGEST_COLUMN_TEXT_2,
                SearchManager.SUGGEST_COLUMN_ICON_1,
            )

            val matrixCursor = MatrixCursor(columns)
            context?.let { context ->
                runBlocking {
                    getSuggestions(context, query).forEach {
                        val data = it["data"]
                        val mimeType = it["mimeType"]
                        val title = it["title"]
                        val subtitle = it["subtitle"]
                        val iconUri = it["iconUri"]
                        matrixCursor.addRow(arrayOf(data, mimeType, mimeType, title, subtitle, iconUri))
                    }
                }
            }
            matrixCursor
        }
    }

    private suspend fun getSuggestions(context: Context, query: String): List<FieldMap> {
        if (backgroundFlutterEngine == null) {
            initFlutterEngine(context)
        }

        val messenger = backgroundFlutterEngine!!.dartExecutor.binaryMessenger
        val backgroundChannel = MethodChannel(messenger, BACKGROUND_CHANNEL)
        backgroundChannel.setMethodCallHandler(this)

        return suspendCoroutine { cont ->
            GlobalScope.launch {
                context.runOnUiThread {
                    backgroundChannel.invokeMethod("getSuggestions", hashMapOf(
                        "query" to query,
                        "locale" to Locale.getDefault().toString(),
                    ), object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            @Suppress("UNCHECKED_CAST")
                            cont.resume(result as List<FieldMap>)
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            cont.resumeWithException(Exception("$errorCode: $errorMessage\n$errorDetails"))
                        }

                        override fun notImplemented() {
                            cont.resumeWithException(NotImplementedError("getSuggestions"))
                        }
                    })
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialized" -> {
                Log.d(LOG_TAG, "background channel is ready")
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onCreate(): Boolean = true

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri =
        throw UnsupportedOperationException()

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int =
        throw UnsupportedOperationException()

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?): Int =
        throw UnsupportedOperationException()

    companion object {
        private val LOG_TAG = LogUtils.createTag<SearchSuggestionsProvider>()
        private const val BACKGROUND_CHANNEL = "deckers.thibault/aves/global_search_background"
        const val SHARED_PREFERENCES_KEY = "platform_search"
        const val CALLBACK_HANDLE_KEY = "callback_handle"

        private var backgroundFlutterEngine: FlutterEngine? = null

        private suspend fun initFlutterEngine(context: Context) {
            val callbackHandle = context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE).getLong(CALLBACK_HANDLE_KEY, 0)
            if (callbackHandle == 0L) {
                Log.e(LOG_TAG, "failed to retrieve registered callback handle")
                return
            }

            lateinit var flutterLoader: FlutterLoader
            context.runOnUiThread {
                // initialization must happen on the main thread
                flutterLoader = FlutterInjector.instance().flutterLoader().apply {
                    startInitialization(context)
                    ensureInitializationComplete(context, null)
                }
            }

            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
            if (callbackInfo == null) {
                Log.e(LOG_TAG, "failed to find callback information")
                return
            }

            val args = DartExecutor.DartCallback(
                context.assets,
                flutterLoader.findAppBundlePath(),
                callbackInfo
            )
            context.runOnUiThread {
                // initialization must happen on the main thread
                backgroundFlutterEngine = FlutterEngine(context).apply {
                    dartExecutor.executeDartCallback(args)
                }
            }
        }

        // convenience methods

        private suspend fun Context.runOnUiThread(r: Runnable) {
            suspendCoroutine<Boolean> { cont ->
                Handler(mainLooper).post {
                    r.run()
                    cont.resume(true)
                }
            }
        }
    }
}