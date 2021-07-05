package deckers.thibault.aves

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
import deckers.thibault.aves.model.provider.MediaStoreImageProvider
import deckers.thibault.aves.utils.LogUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentHashMap

class MainActivity : FlutterActivity() {
    private lateinit var mediaStoreChangeStreamHandler: MediaStoreChangeStreamHandler
    private lateinit var settingsChangeStreamHandler: SettingsChangeStreamHandler
    private lateinit var intentStreamHandler: IntentStreamHandler
    private lateinit var intentDataMap: MutableMap<String, Any?>

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i(LOG_TAG, "onCreate intent=$intent")
        super.onCreate(savedInstanceState)

        val messenger = flutterEngine!!.dartExecutor.binaryMessenger

        MethodChannel(messenger, AppAdapterHandler.CHANNEL).setMethodCallHandler(AppAdapterHandler(this))
        MethodChannel(messenger, AppShortcutHandler.CHANNEL).setMethodCallHandler(AppShortcutHandler(this))
        MethodChannel(messenger, DebugHandler.CHANNEL).setMethodCallHandler(DebugHandler(this))
        MethodChannel(messenger, EmbeddedDataHandler.CHANNEL).setMethodCallHandler(EmbeddedDataHandler(this))
        MethodChannel(messenger, ImageFileHandler.CHANNEL).setMethodCallHandler(ImageFileHandler(this))
        MethodChannel(messenger, GeocodingHandler.CHANNEL).setMethodCallHandler(GeocodingHandler(this))
        MethodChannel(messenger, MediaStoreHandler.CHANNEL).setMethodCallHandler(MediaStoreHandler(this))
        MethodChannel(messenger, MetadataHandler.CHANNEL).setMethodCallHandler(MetadataHandler(this))
        MethodChannel(messenger, StorageHandler.CHANNEL).setMethodCallHandler(StorageHandler(this))
        MethodChannel(messenger, TimeHandler.CHANNEL).setMethodCallHandler(TimeHandler())
        MethodChannel(messenger, WindowHandler.CHANNEL).setMethodCallHandler(WindowHandler(this))

        StreamsChannel(messenger, ImageByteStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageByteStreamHandler(this, args) }
        StreamsChannel(messenger, ImageOpStreamHandler.CHANNEL).setStreamHandlerFactory { args -> ImageOpStreamHandler(this, args) }
        StreamsChannel(messenger, MediaStoreStreamHandler.CHANNEL).setStreamHandlerFactory { args -> MediaStoreStreamHandler(this, args) }
        StreamsChannel(messenger, StorageAccessStreamHandler.CHANNEL).setStreamHandlerFactory { args -> StorageAccessStreamHandler(this, args) }

        // Media Store change monitoring
        mediaStoreChangeStreamHandler = MediaStoreChangeStreamHandler(this).apply {
            EventChannel(messenger, MediaStoreChangeStreamHandler.CHANNEL).setStreamHandler(this)
        }
        settingsChangeStreamHandler = SettingsChangeStreamHandler(this).apply {
            EventChannel(messenger, SettingsChangeStreamHandler.CHANNEL).setStreamHandler(this)
        }

        // intent handling
        intentStreamHandler = IntentStreamHandler().apply {
            EventChannel(messenger, IntentStreamHandler.CHANNEL).setStreamHandler(this)
        }
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            setupShortcuts()
        }
    }

    override fun onDestroy() {
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
            DOCUMENT_TREE_ACCESS_REQUEST -> {
                val treeUri = data?.data
                if (resultCode != RESULT_OK || treeUri == null) {
                    onPermissionResult(requestCode, null)
                    return
                }

                // save access permissions across reboots
                val takeFlags = (data.flags
                        and (Intent.FLAG_GRANT_READ_URI_PERMISSION
                        or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
                contentResolver.takePersistableUriPermission(treeUri, takeFlags)

                // resume pending action
                onPermissionResult(requestCode, treeUri)
            }
            DELETE_PERMISSION_REQUEST -> {
                // delete permission may be requested on Android 10+ only
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    MediaStoreImageProvider.pendingDeleteCompleter?.complete(resultCode == RESULT_OK)
                }
            }
            CREATE_FILE_REQUEST, OPEN_FILE_REQUEST -> {
                onPermissionResult(requestCode, data?.data)
            }
        }
    }

    private fun extractIntentData(intent: Intent?): MutableMap<String, Any?> {
        when (intent?.action) {
            Intent.ACTION_MAIN -> {
                intent.getStringExtra("page")?.let { page ->
                    return hashMapOf(
                        "page" to page,
                        "filters" to intent.getStringArrayExtra("filters")?.toList(),
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

        val search = ShortcutInfoCompat.Builder(this, "search")
            .setShortLabel(getString(R.string.search_shortcut_short_label))
            .setIcon(IconCompat.createWithResource(this, R.mipmap.ic_shortcut_search))
            .setIntent(
                Intent(Intent.ACTION_MAIN, null, this, MainActivity::class.java)
                    .putExtra("page", "/search")
            )
            .build()

        val videos = ShortcutInfoCompat.Builder(this, "videos")
            .setShortLabel(getString(R.string.videos_shortcut_short_label))
            .setIcon(IconCompat.createWithResource(this, R.mipmap.ic_shortcut_movie))
            .setIntent(
                Intent(Intent.ACTION_MAIN, null, this, MainActivity::class.java)
                    .putExtra("page", "/collection")
                    .putExtra("filters", arrayOf("{\"type\":\"mime\",\"mime\":\"video/*\"}"))
            )
            .build()

        ShortcutManagerCompat.setDynamicShortcuts(this, listOf(videos, search))
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MainActivity>()
        const val VIEWER_CHANNEL = "deckers.thibault/aves/viewer"
        const val DOCUMENT_TREE_ACCESS_REQUEST = 1
        const val DELETE_PERMISSION_REQUEST = 2
        const val CREATE_FILE_REQUEST = 3
        const val OPEN_FILE_REQUEST = 4

        // permission request code to pending runnable
        val pendingResultHandlers = ConcurrentHashMap<Int, PendingResultHandler>()

        fun onPermissionResult(requestCode: Int, uri: Uri?) {
            Log.d(LOG_TAG, "onPermissionResult with requestCode=$requestCode, uri=$uri")
            val handler = pendingResultHandlers.remove(requestCode) ?: return
            if (uri != null) {
                handler.onGranted(uri)
            } else {
                handler.onDenied()
            }
        }
    }
}

// onGranted: user selected a directory/file (with no guarantee that it matches the requested `path`)
// onDenied: user cancelled
data class PendingResultHandler(val path: String?, val onGranted: (uri: Uri) -> Unit, val onDenied: () -> Unit)
