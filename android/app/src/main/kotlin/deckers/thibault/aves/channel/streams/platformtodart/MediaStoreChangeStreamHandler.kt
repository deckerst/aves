package deckers.thibault.aves.channel.streams.platformtodart

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel

class MediaStoreChangeStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    private var eventSink: EventChannel.EventSink? = null
    private var handler: Handler? = null

    private val contentObserver = object : ContentObserver(null) {
        override fun onChange(selfChange: Boolean) {
            this.onChange(selfChange, null)
        }

        override fun onChange(selfChange: Boolean, uri: Uri?) {
            // warning: querying the content resolver right after a change
            // sometimes yields obsolete results
            success(uri?.toString())
        }
    }

    init {
        Log.i(LOG_TAG, "start listening to Media Store")
        try {
            context.contentResolver.apply {
                registerContentObserver(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, true, contentObserver)
                registerContentObserver(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, true, contentObserver)
            }
        } catch (e: SecurityException) {
            // Trying to register an observer may yield a security exception with this message:
            // "Failed to find provider media for user 0; expected to find a valid ContentProvider for this authority"
            Log.w(LOG_TAG, "failed to register content observer", e)
        }
    }

    fun dispose() {
        Log.i(LOG_TAG, "stop listening to Media Store")
        context.contentResolver.unregisterContentObserver(contentObserver)
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

    private fun success(uri: String?) {
        handler?.post {
            try {
                eventSink?.success(uri)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaStoreChangeStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_store_change"
    }
}