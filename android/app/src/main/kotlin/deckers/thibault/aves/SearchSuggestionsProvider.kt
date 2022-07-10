package deckers.thibault.aves

import android.app.SearchManager
import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Build
import android.text.format.DateFormat
import android.util.Log
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.ContextUtils.resourceUri
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class SearchSuggestionsProvider : MethodChannel.MethodCallHandler, ContentProvider() {
    private val defaultScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

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
                // shortcut adaptive icons are placed in `mipmap`, not `drawable`,
                // so that foreground is rendered at the intended scale
                val supportAdaptiveIcon = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

                val searchShortcutTitle = "${context.resources.getString(R.string.search_shortcut_short_label)} $query"
                val searchShortcutIcon = context.resourceUri(if (supportAdaptiveIcon) R.mipmap.ic_shortcut_search else R.drawable.ic_shortcut_search)
                matrixCursor.addRow(arrayOf(null, null, null, searchShortcutTitle, null, searchShortcutIcon))

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
            FlutterUtils.initFlutterEngine(context, SHARED_PREFERENCES_KEY, CALLBACK_HANDLE_KEY) {
                backgroundFlutterEngine = it
            }
        }

        val messenger = backgroundFlutterEngine!!.dartExecutor.binaryMessenger
        val backgroundChannel = MethodChannel(messenger, BACKGROUND_CHANNEL)
        backgroundChannel.setMethodCallHandler(this)

        try {
            return suspendCoroutine { cont ->
                defaultScope.launch {
                    FlutterUtils.runOnUiThread {
                        backgroundChannel.invokeMethod("getSuggestions", hashMapOf(
                            "query" to query,
                            "locale" to Locale.getDefault().toString(),
                            "use24hour" to DateFormat.is24HourFormat(context),
                        ), object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                @Suppress("unchecked_cast")
                                cont.resume(result as List<FieldMap>)
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
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to get suggestions", e)
            return ArrayList()
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
        throw UnsupportedOperationException("`insert` is not supported by this content provider")

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int =
        throw UnsupportedOperationException("`delete` is not supported by this content provider")

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?): Int =
        throw UnsupportedOperationException("`update` is not supported by this content provider")

    companion object {
        private val LOG_TAG = LogUtils.createTag<SearchSuggestionsProvider>()
        private const val BACKGROUND_CHANNEL = "deckers.thibault/aves/global_search_background"
        const val SHARED_PREFERENCES_KEY = "platform_search"
        const val CALLBACK_HANDLE_KEY = "callback_handle"

        private var backgroundFlutterEngine: FlutterEngine? = null
    }
}