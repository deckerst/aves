package deckers.thibault.aves.channel.streams

import android.os.Handler
import android.os.Looper
import android.support.v4.media.session.MediaSessionCompat
import android.util.Log
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class MediaCommandStreamHandler : EventChannel.StreamHandler, MediaSessionCompat.Callback() {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    private var eventSink: EventSink? = null
    private var handler: Handler? = null

    override fun onListen(arguments: Any?, eventSink: EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) {
        Log.i(LOG_TAG, "onCancel arguments=$arguments")
    }

    private fun success(fields: FieldMap) {
        handler?.post {
            try {
                eventSink?.success(fields)
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to use event sink", e)
            }
        }
    }

    // media session callback

    override fun onPlay() {
        super.onPlay()
        success(hashMapOf(KEY_COMMAND to COMMAND_PLAY))
    }

    override fun onPause() {
        super.onPause()
        success(hashMapOf(KEY_COMMAND to COMMAND_PAUSE))
    }

    override fun onStop() {
        super.onStop()
        success(hashMapOf(KEY_COMMAND to COMMAND_STOP))
    }

    override fun onSeekTo(pos: Long) {
        super.onSeekTo(pos)
        success(
            hashMapOf(
                KEY_COMMAND to COMMAND_SEEK,
                KEY_POSITION to pos,
            )
        )
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaCommandStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_command"

        const val KEY_COMMAND = "command"
        const val KEY_POSITION = "position"

        const val COMMAND_PLAY = "play"
        const val COMMAND_PAUSE = "pause"
        const val COMMAND_STOP = "stop"
        const val COMMAND_SEEK = "seek"
    }
}