package deckers.thibault.aves.channel.streams

import android.annotation.SuppressLint
import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
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
        private var transitionAnimationScale: Float = 1f

        init {
            update()
        }

        override fun onChange(selfChange: Boolean) {
            this.onChange(selfChange, null)
        }

        override fun onChange(selfChange: Boolean, uri: Uri?) {
            if (update()) {
                val settings: FieldMap = hashMapOf(
                    Settings.System.ACCELEROMETER_ROTATION to accelerometerRotation,
                )
                @SuppressLint("ObsoleteSdkInt")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    settings[Settings.Global.TRANSITION_ANIMATION_SCALE] = transitionAnimationScale
                }
                success(settings)
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
                @SuppressLint("ObsoleteSdkInt")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    val newTransitionAnimationScale = Settings.Global.getFloat(context.contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE)
                    if (transitionAnimationScale != newTransitionAnimationScale) {
                        transitionAnimationScale = newTransitionAnimationScale
                        changed = true
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get settings with error=${e.message}", null)
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

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

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
        const val CHANNEL = "deckers.thibault/aves/settings_change"
    }
}