package deckers.thibault.aves.channel.streams

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class SettingsChangeStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    private var eventSink: EventSink? = null
    private var handler: Handler? = null

    private val contentObserver = object : ContentObserver(null) {
        private var accelerometerRotation: Int = 0

        init {
            update()
        }

        override fun onChange(selfChange: Boolean) {
            this.onChange(selfChange, null)
        }

        override fun onChange(selfChange: Boolean, uri: Uri?) {
            if (update()) {
                success(
                    hashMapOf(
                        Settings.System.ACCELEROMETER_ROTATION to accelerometerRotation
                    )
                )
            }
        }

        private fun update(): Boolean {
            var changed = false
            try {
                val newAccelerometerRotation = Settings.System.getInt(context.contentResolver, Settings.System.ACCELEROMETER_ROTATION)
                if (accelerometerRotation != newAccelerometerRotation) {
                    accelerometerRotation = newAccelerometerRotation
                    changed = true
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get settings", e)
            }
            return changed
        }
    }

    init {
        context.contentResolver.apply {
            registerContentObserver(Settings.System.CONTENT_URI, true, contentObserver)
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) {}

    fun dispose() {
        context.contentResolver.unregisterContentObserver(contentObserver)
    }

    private fun success(settings: FieldMap) {
        handler?.post {
            try {
                eventSink?.success(settings)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<SettingsChangeStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/settingschange"
    }
}