package deckers.thibault.aves

import android.annotation.SuppressLint
import android.app.SearchManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import app.loup.streams_channel.StreamsChannel
import deckers.thibault.aves.channel.calls.*
import deckers.thibault.aves.channel.streams.*
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ConcurrentHashMap

class MainActivity : FlutterActivity() {
    private lateinit var mediaStoreChangeStreamHandler: MediaStoreChangeStreamHandler
    private lateinit var settingsChangeStreamHandler: SettingsChangeStreamHandler
    private lateinit var intentStreamHandler: IntentStreamHandler
    private lateinit var analysisStreamHandler: AnalysisStreamHandler
    private lateinit var intentDataMap: MutableMap<String, Any?>
    private lateinit var analysisHandler: AnalysisHandler

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i(LOG_TAG, "onCreate intent=$intent")
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

        val messenger = flutterEngine!!.dartExecutor.binaryMessenger

        // dart -> platform -> dart
        // - need Context
        analysisHandler = AnalysisHandler(this, ::onAnalysisCompleted)
        MethodChannel(messenger, AnalysisHandler.CHANNEL).setMethodCallHandler(analysisHandler)
        MethodChannel(messenger, AppAdapterHandler.CHANNEL).setMethodCallHandler(AppAdapterHandler(this))
        MethodChannel(messenger, DebugHandler.CHANNEL).setMethodCallHandler(DebugHandler(this))
        MethodChannel(messenger, DeviceHandler.CHANNEL).setMethodCallHandler(DeviceHandler())
        MethodChannel(messenger, EmbeddedDataHandler.CHANNEL).setMethodCallHandler(EmbeddedDataHandler(this))
        MethodChannel(messenger, GeocodingHandler.CHANNEL).setMethodCallHandler(GeocodingHandler(this))
        MethodChannel(messenger, GlobalSearchHandler.CHANNEL).setMethodCallHandler(GlobalSearchHandler(this))
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(this))
        MethodChannel(messenger, MetadataFetchHandler.CHANNEL).setMethodCallHandler(MetadataFetchHandler(this))
        MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(this))
        // - need Activity
        MethodChannel(messenger, AccessibilityHandler.CHANNEL).setMethodCallHandler(AccessibilityHandler(this))
        MethodChannel(messenger, MediaFileHandler.CHANNEL).setMethodCallHandler(MediaFileHandler(this))
        MethodChannel(messenger, MetadataEditHandler.CHANNEL).setMethodCallHandler(MetadataEditHandler(this))
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(WindowHandler(this))

        // result streaming: dart -> platform ->->-> dart
        // - need Context
        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(this, args) }
        // - need Activity
        StreamsChannel(messenger, ImageOpStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageOpStreamHandler(this, args) }
        StreamsChannel(messenger, StorageAccessStreamHandler.CHANNEL).setStreamHandlerFactory { args -> StorageAccessStreamHandler(this, args) }

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
        // detail fetch: dart -> platform
        intentDataMap = extractIntentData(intent)
        MethodChannel(messenger, VIEWER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntentData" -> {
                    result.success(intentDataMap)
                    intentDataMap.clear()
                }
                "pick" -> pick(call)
            }
        }

        // notification: platform -> dart
        analysisStreamHandler = AnalysisStreamHandler().apply {
            EventChannel(messenger, AnalysisStreamHandler.CHANNEL).setStreamHandler(this)
        }

        // notification: platform -> dart
        errorStreamHandler = ErrorStreamHandler().apply {
            EventChannel(messenger, ErrorStreamHandler.CHANNEL).setStreamHandler(this)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            setupShortcuts()
        }
    }

    override fun onStart() {
        Log.i(LOG_TAG, "onStart")
        super.onStart()
        analysisHandler.attachToActivity()
    }

    override fun onStop() {
        Log.i(LOG_TAG, "onStop")
        analysisHandler.detachFromActivity()
        super.onStop()
    }

    override fun onDestroy() {
        Log.i(LOG_TAG, "onDestroy")
        mediaStoreChangeStreamHandler.dispose()
        settingsChangeStreamHandler.dispose()
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        Log.i(LOG_TAG, "onNewIntent intent=$intent")
        super.onNewIntent(intent)
        intentStreamHandler.notifyNewIntent(extractIntentData(intent))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        when (requestCode) {
            DOCUMENT_TREE_ACCESS_REQUEST -> onDocumentTreeAccessResult(data, resultCode, requestCode)
            DELETE_SINGLE_PERMISSION_REQUEST,
            MEDIA_WRITE_BULK_PERMISSION_REQUEST -> onScopedStoragePermissionResult(resultCode)
            CREATE_FILE_REQUEST,
            OPEN_FILE_REQUEST,
            SELECT_DIRECTORY_REQUEST -> onStorageAccessResult(requestCode, data?.data)
        }
    }

    @SuppressLint("WrongConstant")
    private fun onDocumentTreeAccessResult(data: Intent?, resultCode: Int, requestCode: Int) {
        val treeUri = data?.data
        if (resultCode != RESULT_OK || treeUri == null) {
            onStorageAccessResult(requestCode, null)
            return
        }

        // save access permissions across reboots
        val takeFlags = (data.flags
                and (Intent.FLAG_GRANT_READ_URI_PERMISSION
                or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
        contentResolver.takePersistableUriPermission(treeUri, takeFlags)

        // resume pending action
        onStorageAccessResult(requestCode, treeUri)
    }

    private fun onScopedStoragePermissionResult(resultCode: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            pendingScopedStoragePermissionCompleter?.complete(resultCode == RESULT_OK)
        }
    }

    private fun extractIntentData(intent: Intent?): MutableMap<String, Any?> {
        when (intent?.action) {
            Intent.ACTION_MAIN -> {
                intent.getStringExtra("page")?.let { page ->
                    var filters = intent.getStringArrayExtra("filters")?.toList()
                    if (filters == null) {
                        // fallback for shortcuts created on API < 26
                        val filterString = intent.getStringExtra("filtersString")
                        if (filterString != null) {
                            filters = filterString.split(EXTRA_STRING_ARRAY_SEPARATOR)
                        }
                    }
                    return hashMapOf(
                        "page" to page,
                        "filters" to filters,
                    )
                }
            }
            Intent.ACTION_VIEW, Intent.ACTION_SEND, "com.android.camera.action.REVIEW" -> {
                (intent.data ?: (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri))?.let { uri ->
                    return hashMapOf(
                        "action" to "view",
                        "uri" to uri.toString(),
                        "mimeType" to intent.type, // MIME type is optional
                    )
                }
            }
            Intent.ACTION_GET_CONTENT, Intent.ACTION_PICK -> {
                return hashMapOf(
                    "action" to "pick",
                    "mimeType" to intent.type,
                )
            }
            Intent.ACTION_SEARCH -> {
                val viewUri = intent.dataString
                return if (viewUri != null) hashMapOf(
                    "action" to "view",
                    "uri" to viewUri,
                    "mimeType" to intent.getStringExtra(SearchManager.EXTRA_DATA_KEY),
                ) else hashMapOf(
                    "action" to "search",
                    "query" to intent.getStringExtra(SearchManager.QUERY),
                )
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

    private fun pick(call: MethodCall) {
        val pickedUri = call.argument<String>("uri")
        if (pickedUri != null) {
            val intent = Intent().apply {
                data = Uri.parse(pickedUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
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
                    .putExtra("page", "/search")
            )
            .build()

        val videos = ShortcutInfoCompat.Builder(this, "videos")
            .setShortLabel(getString(R.string.videos_shortcut_short_label))
            .setIcon(IconCompat.createWithResource(this, if (supportAdaptiveIcon) R.mipmap.ic_shortcut_movie else R.drawable.ic_shortcut_movie))
            .setIntent(
                Intent(Intent.ACTION_MAIN, null, this, MainActivity::class.java)
                    .putExtra("page", "/collection")
                    .putExtra("filters", arrayOf("{\"type\":\"mime\",\"mime\":\"video/*\"}"))
            )
            .build()

        ShortcutManagerCompat.setDynamicShortcuts(this, listOf(videos, search))
    }

    private fun onAnalysisCompleted() {
        analysisStreamHandler.notifyCompletion()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MainActivity>()
        const val VIEWER_CHANNEL = "deckers.thibault/aves/viewer"
        const val EXTRA_STRING_ARRAY_SEPARATOR = "###"
        const val DOCUMENT_TREE_ACCESS_REQUEST = 1
        const val OPEN_FROM_ANALYSIS_SERVICE = 2
        const val CREATE_FILE_REQUEST = 3
        const val OPEN_FILE_REQUEST = 4
        const val SELECT_DIRECTORY_REQUEST = 5
        const val DELETE_SINGLE_PERMISSION_REQUEST = 6
        const val MEDIA_WRITE_BULK_PERMISSION_REQUEST = 7

        // request code to pending runnable
        val pendingStorageAccessResultHandlers = ConcurrentHashMap<Int, PendingStorageAccessResultHandler>()

        var pendingScopedStoragePermissionCompleter: CompletableFuture<Boolean>? = null

        private fun onStorageAccessResult(requestCode: Int, uri: Uri?) {
            Log.d(LOG_TAG, "onStorageAccessResult with requestCode=$requestCode, uri=$uri")
            val handler = pendingStorageAccessResultHandlers.remove(requestCode) ?: return
            if (uri != null) {
                handler.onGranted(uri)
            } else {
                handler.onDenied()
            }
        }

        var errorStreamHandler: ErrorStreamHandler? = null

        fun notifyError(error: String) = errorStreamHandler?.notifyError(error)
    }
}

// onGranted: user selected a directory/file (with no guarantee that it matches the requested `path`)
// onDenied: user cancelled
data class PendingStorageAccessResultHandler(val path: String?, val onGranted: (uri: Uri) -> Unit, val onDenied: () -> Unit)
