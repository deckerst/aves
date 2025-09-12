package deckers.thibault.aves.channel.streams.platformtodart

import android.os.Handler
import android.os.Looper
import android.support.v4.media.session.MediaSessionCompat
import android.util.Log
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.EventChannel

class MediaCommandStreamHandler : EventChannel.StreamHandler, MediaSessionCompat.Callback() {
    // cannot use `lateinit` because we cannot guarantee
    // its initialization in `onListen` at the right time
    private var eventSink: EventChannel.EventSink? = null
    private var handler: Handler? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
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

    override fun onSkipToNext() {
        super.onSkipToNext()
        success(hashMapOf(KEY_COMMAND to COMMAND_SKIP_TO_NEXT))
    }

    override fun onSkipToPrevious() {
        super.onSkipToPrevious()
        success(hashMapOf(KEY_COMMAND to COMMAND_SKIP_TO_PREVIOUS))
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
        const val COMMAND_SKIP_TO_NEXT = "skip_to_next"
        const val COMMAND_SKIP_TO_PREVIOUS = "skip_to_previous"
        const val COMMAND_STOP = "stop"
        const val COMMAND_SEEK = "seek"
    }
}