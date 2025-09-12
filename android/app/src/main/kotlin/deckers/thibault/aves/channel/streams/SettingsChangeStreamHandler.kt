package deckers.thibault.aves.channel.streams

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.ViewConfiguration
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel

class SettingsChangeStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    private var eventSink: EventChannel.EventSink? = null
    private var handler: Handler? = null

    private val contentObserver = object : ContentObserver(null) {
        private var accelerometerRotation: Int = 0
        private var transitionAnimationScale: Float = 1f
        private var longPressTimeoutMillis: Int = 0

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
                        Settings.System.ACCELEROMETER_ROTATION to accelerometerRotation,
                        Settings.Global.TRANSITION_ANIMATION_SCALE to transitionAnimationScale,
                        KEY_LONG_PRESS_TIMEOUT_MILLIS to longPressTimeoutMillis,
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
                val newTransitionAnimationScale = Settings.Global.getFloat(context.contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE)
                if (transitionAnimationScale != newTransitionAnimationScale) {
                    transitionAnimationScale = newTransitionAnimationScale
                    changed = true
                }
                val newLongPressTimeout = ViewConfiguration.getLongPressTimeout()
                if (longPressTimeoutMillis != newLongPressTimeout) {
                    longPressTimeoutMillis = newLongPressTimeout
                    changed = true
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get settings with error=${e.message}", null)
            }
            return changed
        }
    }

    init {
        Log.i(LOG_TAG, "start listening to system settings")
        context.contentResolver.registerContentObserver(Settings.System.CONTENT_URI, true, contentObserver)
    }

    fun dispose() {
        Log.i(LOG_TAG, "stop listening to system settings")
        context.contentResolver.unregisterContentObserver(contentObserver)
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
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
        const val CHANNEL = "deckers.thibault/aves/settings_change"

        // cf `Settings.Secure.LONG_PRESS_TIMEOUT`
        const val KEY_LONG_PRESS_TIMEOUT_MILLIS = "long_press_timeout"
    }
}