package deckers.thibault.aves

import android.annotation.SuppressLint
import android.app.SearchManager
import android.appwidget.AppWidgetManager
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.AvesByteSendingMethodCodec
import deckers.thibault.aves.channel.calls.*
import deckers.thibault.aves.channel.calls.window.ActivityWindowHandler
import deckers.thibault.aves.channel.calls.window.WindowHandler
import deckers.thibault.aves.channel.streams.*
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.FlutterUtils.enableSoftwareRendering
import deckers.thibault.aves.utils.FlutterUtils.isSoftwareRenderingRequired
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.getParcelableExtraCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ConcurrentHashMap

open class MainActivity : FlutterFragmentActivity() {
    private val defaultScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    private lateinit var mediaStoreChangeStreamHandler: MediaStoreChangeStreamHandler
    private lateinit var settingsChangeStreamHandler: SettingsChangeStreamHandler
    private lateinit var intentStreamHandler: IntentStreamHandler
    private lateinit var analysisStreamHandler: AnalysisStreamHandler
    internal lateinit var intentDataMap: MutableMap<String, Any?>
    private lateinit var analysisHandler: AnalysisHandler
    private lateinit var mediaSessionHandler: MediaSessionHandler

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i(LOG_TAG, "onCreate intent=$intent")

        if (isSoftwareRenderingRequired()) {
            intent.enableSoftwareRendering()
            // running the app from Android Studio automatically adds to the intent the `start-paused` flag
            // so the IDE can connect to the app, but launching on KitKat emulators fails because of a timeout
            intent.removeExtra("start-paused")
        }

        intent.extras?.takeUnless { it.isEmpty }?.let {
            Log.i(LOG_TAG, "onCreate intent extras=$it")
        }

//        StrictMode.setThreadPolicy(
//            StrictMode.ThreadPolicy.Builder()
//                .detectAll()
//                .penaltyLog()
//                .build()
//        )
//        StrictMode.setVmPolicy(
//            StrictMode.VmPolicy.Builder()
//                .detectAll()
//                .penaltyLog()
//                .build()
//        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor

        // notification: platform -> dart
        analysisStreamHandler = AnalysisStreamHandler().apply {
            EventChannel(messenger, AnalysisStreamHandler.CHANNEL).setStreamHandler(this)
        }
        errorStreamHandler = ErrorStreamHandler().apply {
            EventChannel(messenger, ErrorStreamHandler.CHANNEL).setStreamHandler(this)
        }
        val mediaCommandStreamHandler = MediaCommandStreamHandler().apply {
            EventChannel(messenger, MediaCommandStreamHandler.CHANNEL).setStreamHandler(this)
        }

        // dart -> platform -> dart
        // - need Context
        analysisHandler = AnalysisHandler(this, ::onAnalysisCompleted)
        mediaSessionHandler = MediaSessionHandler(this, mediaCommandStreamHandler)
        MethodChannel(messenger, AnalysisHandler.CHANNEL).setMethodCallHandler(analysisHandler)
        MethodChannel(messenger, AppAdapterHandler.CHANNEL).setMethodCallHandler(AppAdapterHandler(this))
        MethodChannel(messenger, DebugHandler.CHANNEL).setMethodCallHandler(DebugHandler(this))
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler(this))
        MethodChannel(messenger, EmbeddedDataHandler.CHANNEL).setMethodCallHandler(EmbeddedDataHandler(this))
        MethodChannel(messenger, GeocodingHandler.CHANNEL).setMethodCallHandler(GeocodingHandler(this))
        MethodChannel(messenger, GlobalSearchHandler.CHANNEL).setMethodCallHandler(GlobalSearchHandler(this))
        MethodChannel(messenger, HomeWidgetHandler.CHANNEL).setMethodCallHandler(HomeWidgetHandler(this))
        MethodChannel(messenger, MediaFetchBytesHandler.CHANNEL, AvesByteSendingMethodCodec.INSTANCE).setMethodCallHandler(MediaFetchBytesHandler(this))
        MethodChannel(messenger, MediaFetchObjectHandler.CHANNEL).setMethodCallHandler(MediaFetchObjectHandler(this))
        MethodChannel(messenger, MediaSessionHandler.CHANNEL).setMethodCallHandler(mediaSessionHandler)
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(this))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(this))
        MethodChannel(messenger, SecurityHandler.CHANNEL).setMethodCallHandler(SecurityHandler(this))
        MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(this))
        // - need ContextWrapper
        MethodChannel(messenger, AccessibilityHandler.CHANNEL).setMethodCallHandler(AccessibilityHandler(this))
        MethodChannel(messenger, MediaEditHandler.CHANNEL).setMethodCallHandler(MediaEditHandler(this))
        MethodChannel(messenger, MetadataEditHandler.CHANNEL).setMethodCallHandler(MetadataEditHandler(this))
        // - need Activity
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(ActivityWindowHandler(this))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(this, args) }
        // - need Activity
        StreamsChannel(messenger, ImageOpStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageOpStreamHandler(this, args) }
        StreamsChannel(messenger, ActivityResultStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ActivityResultStreamHandler(this, args) }

        // change monitoring: platform -> dart
        mediaStoreChangeStreamHandler = MediaStoreChangeStreamHandler(this).apply {
            EventChannel(messenger, MediaStoreChangeStreamHandler.CHANNEL).setStreamHandler(this)
        }
        settingsChangeStreamHandler = SettingsChangeStreamHandler(this).apply {
            EventChannel(messenger, SettingsChangeStreamHandler.CHANNEL).setStreamHandler(this)
        }

        // intent handling
        // notification: platform -> dart
        intentStreamHandler = IntentStreamHandler().apply {
            EventChannel(messenger, IntentStreamHandler.CHANNEL).setStreamHandler(this)
        }
        // intent detail & result: dart -> platform
        intentDataMap = extractIntentData(intent)
        MethodChannel(messenger, INTENT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntentData" -> {
                    result.success(intentDataMap)
                    intentDataMap.clear()
                }

                "submitPickedItems" -> submitPickedItems(call)
                "submitPickedCollectionFilters" -> submitPickedCollectionFilters(call)
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            defaultScope.launch { setupShortcuts() }
        }
    }

    override fun onStart() {
        Log.i(LOG_TAG, "onStart")
        super.onStart()
        analysisHandler.attachToActivity()

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
        mediaSessionHandler.dispose()
        mediaStoreChangeStreamHandler.dispose()
        settingsChangeStreamHandler.dispose()
        try {
            super.onDestroy()
        } catch (e: Exception) {
            // on Android 11, app may crash as follows:
            // `Fatal Exception:`
            // `java.lang.RuntimeException: Unable to destroy activity {deckers.thibault.aves/deckers.thibault.aves.MainActivity}:`
            // `java.lang.IllegalArgumentException: NetworkCallback was not registered`
            // related to this error:
            // `Package android does not belong to 10162`
            // cf https://issuetracker.google.com/issues/175055271
            Log.e(LOG_TAG, "failed while destroying activity", e)
        }
    }

    override fun onNewIntent(intent: Intent) {
        Log.i(LOG_TAG, "onNewIntent intent=$intent")
        intent.extras?.takeUnless { it.isEmpty }?.let {
            Log.i(LOG_TAG, "onNewIntent intent extras=$it")
        }
        super.onNewIntent(intent)
        intentStreamHandler.notifyNewIntent(extractIntentData(intent))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            DOCUMENT_TREE_ACCESS_REQUEST -> onDocumentTreeAccessResult(requestCode, resultCode, data)
            DELETE_SINGLE_PERMISSION_REQUEST,
            MEDIA_WRITE_BULK_PERMISSION_REQUEST -> onScopedStoragePermissionResult(resultCode)

            CREATE_FILE_REQUEST,
            OPEN_FILE_REQUEST -> onStorageAccessResult(requestCode, data?.data)

            PICK_COLLECTION_FILTERS_REQUEST -> onCollectionFiltersPickResult(resultCode, data)
            EDIT_REQUEST -> onEditResult(resultCode, data)
        }
    }

    private fun onCollectionFiltersPickResult(resultCode: Int, intent: Intent?) {
        val filters = if (resultCode == RESULT_OK) extractFiltersFromIntent(intent) else null
        pendingCollectionFilterPickHandler?.let { it(filters) }
    }

    private fun onEditResult(resultCode: Int, intent: Intent?) {
        val fields: FieldMap? = if (resultCode == RESULT_OK) hashMapOf(
            "uri" to intent?.data.toString(),
            "mimeType" to intent?.type,
        ) else null
        pendingEditIntentHandler?.let { it(fields) }
    }

    private fun onDocumentTreeAccessResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        val treeUri = intent?.data
        if (resultCode != RESULT_OK || treeUri == null) {
            onStorageAccessResult(requestCode, null)
            return
        }

        val canPersist = (intent.flags and Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION) != 0
        @SuppressLint("WrongConstant")
        if (canPersist) {
            // save access permissions across reboots
            val takeFlags = (intent.flags
                    and (Intent.FLAG_GRANT_READ_URI_PERMISSION
                    or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
            try {
                contentResolver.takePersistableUriPermission(treeUri, takeFlags)
            } catch (e: SecurityException) {
                Log.w(LOG_TAG, "failed to take persistable URI permission for uri=$treeUri", e)
            }
        }

        // resume pending action
        onStorageAccessResult(requestCode, treeUri)
    }

    private fun onScopedStoragePermissionResult(resultCode: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            pendingScopedStoragePermissionCompleter?.complete(resultCode == RESULT_OK)
        }
    }

    open fun extractIntentData(intent: Intent?): MutableMap<String, Any?> {
        when (val action = intent?.action) {
            Intent.ACTION_MAIN -> {
                if (intent.getBooleanExtra(EXTRA_KEY_SAFE_MODE, false)) {
                    return hashMapOf(
                        INTENT_DATA_KEY_SAFE_MODE to true,
                    )
                }
                intent.getStringExtra(EXTRA_KEY_PAGE)?.let { page ->
                    val filters = extractFiltersFromIntent(intent)
                    return hashMapOf(
                        INTENT_DATA_KEY_PAGE to page,
                        INTENT_DATA_KEY_FILTERS to filters,
                    )
                }
            }

            Intent.ACTION_VIEW,
            Intent.ACTION_SEND,
            "com.android.camera.action.REVIEW",
            "com.android.camera.action.SPLIT_SCREEN_REVIEW" -> {
                (intent.data ?: intent.getParcelableExtraCompat<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                    // MIME type is optional
                    val type = intent.type ?: intent.resolveType(this)
                    return hashMapOf(
                        INTENT_DATA_KEY_ACTION to INTENT_ACTION_VIEW,
                        INTENT_DATA_KEY_MIME_TYPE to type,
                        INTENT_DATA_KEY_URI to uri.toString(),
                    )
                }
            }

            Intent.ACTION_EDIT -> {
                (intent.data ?: intent.getParcelableExtraCompat<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                    // MIME type is optional
                    val type = intent.type ?: intent.resolveType(this)
                    return hashMapOf(
                        INTENT_DATA_KEY_ACTION to INTENT_ACTION_EDIT,
                        INTENT_DATA_KEY_MIME_TYPE to type,
                        INTENT_DATA_KEY_URI to uri.toString(),
                    )
                }
            }

            Intent.ACTION_GET_CONTENT, Intent.ACTION_PICK -> {
                return hashMapOf(
                    INTENT_DATA_KEY_ACTION to INTENT_ACTION_PICK_ITEMS,
                    INTENT_DATA_KEY_MIME_TYPE to intent.type,
                    INTENT_DATA_KEY_ALLOW_MULTIPLE to (intent.extras?.getBoolean(Intent.EXTRA_ALLOW_MULTIPLE) ?: false),
                )
            }

            Intent.ACTION_SEARCH -> {
                val viewUri = intent.dataString
                return if (viewUri != null) hashMapOf(
                    INTENT_DATA_KEY_ACTION to INTENT_ACTION_VIEW,
                    INTENT_DATA_KEY_MIME_TYPE to intent.getStringExtra(SearchManager.EXTRA_DATA_KEY),
                    INTENT_DATA_KEY_URI to viewUri,
                ) else hashMapOf(
                    INTENT_DATA_KEY_ACTION to INTENT_ACTION_SEARCH,
                    INTENT_DATA_KEY_QUERY to intent.getStringExtra(SearchManager.QUERY),
                )
            }

            INTENT_ACTION_PICK_COLLECTION_FILTERS -> {
                val initialFilters = extractFiltersFromIntent(intent)
                return hashMapOf(
                    INTENT_DATA_KEY_ACTION to action,
                    INTENT_DATA_KEY_FILTERS to initialFilters,
                )
            }

            INTENT_ACTION_WIDGET_OPEN -> {
                val widgetId = intent.getIntExtra(EXTRA_KEY_WIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
                if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                    return hashMapOf(
                        INTENT_DATA_KEY_ACTION to action,
                        INTENT_DATA_KEY_WIDGET_ID to widgetId,
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

    private fun extractFiltersFromIntent(intent: Intent?): List<String>? {
        intent ?: return null

        val filters = intent.getStringArrayExtra(EXTRA_KEY_FILTERS_ARRAY)?.toList()
        if (filters != null) return filters

        // fallback for shortcuts created on API <26
        val filterString = intent.getStringExtra(EXTRA_KEY_FILTERS_STRING)
        if (filterString != null) {
            return filterString.split(EXTRA_STRING_ARRAY_SEPARATOR)
        }

        return null
    }

    private fun submitPickedItems(call: MethodCall) {
        val pickedUris = call.argument<List<String>>("uris")
        if (!pickedUris.isNullOrEmpty()) {
            val toUri = { uriString: String -> AppAdapterHandler.getShareableUri(this, Uri.parse(uriString)) }
            val intent = Intent().apply {
                val firstUri = toUri(pickedUris.first())
                if (pickedUris.size == 1) {
                    data = firstUri
                } else {
                    clipData = ClipData.newUri(contentResolver, null, firstUri).apply {
                        pickedUris.drop(1).forEach {
                            addItem(ClipData.Item(toUri(it)))
                        }
                    }
                }
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            setResult(RESULT_OK, intent)
        } else {
            setResult(RESULT_CANCELED)
        }
        finish()
    }

    private fun submitPickedCollectionFilters(call: MethodCall) {
        val filters = call.argument<List<String>>("filters")
        if (filters != null) {
            val intent = Intent()
                .putExtra(EXTRA_KEY_FILTERS_ARRAY, filters.toTypedArray())
                .putExtra(EXTRA_KEY_FILTERS_STRING, filters.joinToString(EXTRA_STRING_ARRAY_SEPARATOR))
            setResult(RESULT_OK, intent)
        } else {
            setResult(RESULT_CANCELED)
        }
        finish()
    }

    @RequiresApi(Build.VERSION_CODES.N_MR1)
    private fun setupShortcuts() {
        // do not use 'route' as extra key, as the Flutter framework acts on it

        // shortcut adaptive icons are placed in `mipmap`, not `drawable`,
        // so that foreground is rendered at the intended scale
        val supportAdaptiveIcon = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

        val search = ShortcutInfoCompat.Builder(this, "search")
            .setShortLabel(getString(R.string.search_shortcut_short_label))
            .setIcon(IconCompat.createWithResource(this, if (supportAdaptiveIcon) R.mipmap.ic_shortcut_search else R.drawable.ic_shortcut_search))
            .setIntent(
                Intent(Intent.ACTION_MAIN, null, this, MainActivity::class.java)
                    .putExtra(EXTRA_KEY_PAGE, "/search")
            )
            .build()

        val videos = ShortcutInfoCompat.Builder(this, "videos")
            .setShortLabel(getString(R.string.videos_shortcut_short_label))
            .setIcon(IconCompat.createWithResource(this, if (supportAdaptiveIcon) R.mipmap.ic_shortcut_movie else R.drawable.ic_shortcut_movie))
            .setIntent(
                Intent(Intent.ACTION_MAIN, null, this, MainActivity::class.java)
                    .putExtra(EXTRA_KEY_PAGE, "/collection")
                    .putExtra("filters", arrayOf("{\"type\":\"mime\",\"mime\":\"video/*\"}"))
            )
            .build()

        val safeMode = ShortcutInfoCompat.Builder(this, "safeMode")
            .setShortLabel(getString(R.string.safe_mode_shortcut_short_label))
            .setIcon(IconCompat.createWithResource(this, if (supportAdaptiveIcon) R.mipmap.ic_shortcut_safe_mode else R.drawable.ic_shortcut_safe_mode))
            .setIntent(
                Intent(Intent.ACTION_MAIN, null, this, MainActivity::class.java)
                    .putExtra(EXTRA_KEY_SAFE_MODE, true)
            )
            .build()

        val shortcutInfoList = listOf(videos, search, safeMode)
        ShortcutManagerCompat.setDynamicShortcuts(this, shortcutInfoList)
        Log.i(LOG_TAG, "set shortcuts: ${shortcutInfoList.joinToString(", ") { v -> v.id }}")
    }

    private fun onAnalysisCompleted() {
        analysisStreamHandler.notifyCompletion()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MainActivity>()
        const val INTENT_CHANNEL = "deckers.thibault/aves/intent"
        const val EXTRA_STRING_ARRAY_SEPARATOR = "###"
        const val DOCUMENT_TREE_ACCESS_REQUEST = 1
        const val OPEN_FROM_ANALYSIS_SERVICE = 2
        const val CREATE_FILE_REQUEST = 3
        const val OPEN_FILE_REQUEST = 4
        const val DELETE_SINGLE_PERMISSION_REQUEST = 5
        const val MEDIA_WRITE_BULK_PERMISSION_REQUEST = 6
        const val PICK_COLLECTION_FILTERS_REQUEST = 7
        const val EDIT_REQUEST = 8

        const val INTENT_ACTION_EDIT = "edit"
        const val INTENT_ACTION_PICK_ITEMS = "pick_items"
        const val INTENT_ACTION_PICK_COLLECTION_FILTERS = "pick_collection_filters"
        const val INTENT_ACTION_SCREEN_SAVER = "screen_saver"
        const val INTENT_ACTION_SCREEN_SAVER_SETTINGS = "screen_saver_settings"
        const val INTENT_ACTION_SEARCH = "search"
        const val INTENT_ACTION_SET_WALLPAPER = "set_wallpaper"
        const val INTENT_ACTION_VIEW = "view"
        const val INTENT_ACTION_WIDGET_OPEN = "widget_open"
        const val INTENT_ACTION_WIDGET_SETTINGS = "widget_settings"

        const val INTENT_DATA_KEY_ACTION = "action"
        const val INTENT_DATA_KEY_ALLOW_MULTIPLE = "allowMultiple"
        const val INTENT_DATA_KEY_FILTERS = "filters"
        const val INTENT_DATA_KEY_MIME_TYPE = "mimeType"
        const val INTENT_DATA_KEY_PAGE = "page"
        const val INTENT_DATA_KEY_QUERY = "query"
        const val INTENT_DATA_KEY_SAFE_MODE = "safeMode"
        const val INTENT_DATA_KEY_URI = "uri"
        const val INTENT_DATA_KEY_WIDGET_ID = "widgetId"

        const val EXTRA_KEY_PAGE = "page"
        const val EXTRA_KEY_FILTERS_ARRAY = "filters"
        const val EXTRA_KEY_FILTERS_STRING = "filtersString"
        const val EXTRA_KEY_SAFE_MODE = "safeMode"
        const val EXTRA_KEY_WIDGET_ID = "widgetId"

        // request code to pending runnable
        val pendingStorageAccessResultHandlers = ConcurrentHashMap<Int, PendingStorageAccessResultHandler>()

        var pendingScopedStoragePermissionCompleter: CompletableFuture<Boolean>? = null

        var pendingCollectionFilterPickHandler: ((filters: List<String>?) -> Unit)? = null

        var pendingEditIntentHandler: ((fields: FieldMap?) -> Unit)? = null

        private fun onStorageAccessResult(requestCode: Int, uri: Uri?) {
            Log.i(LOG_TAG, "onStorageAccessResult with requestCode=$requestCode, uri=$uri")
            val handler = pendingStorageAccessResultHandlers.remove(requestCode) ?: return
            if (uri != null) {
                handler.onGranted(uri)
            } else {
                handler.onDenied()
            }
        }

        private var errorStreamHandler: ErrorStreamHandler? = null

        suspend fun notifyError(error: String) {
            Log.e(LOG_TAG, "notifyError error=$error")
            errorStreamHandler?.notifyError(error)
        }
    }
}

// onGranted: user selected a directory/file (with no guarantee that it matches the requested `path`)
// onDenied: user cancelled
data class PendingStorageAccessResultHandler(val path: String?, val onGranted: (uri: Uri) -> Unit, val onDenied: () -> Unit)
