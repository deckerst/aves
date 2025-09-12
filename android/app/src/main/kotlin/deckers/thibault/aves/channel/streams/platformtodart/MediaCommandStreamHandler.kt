package deckers.thibault.aves.channel.streams.platformtodart

import android.support.v4.media.session.MediaSessionCompat
import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.utils.LogUtils

class MediaCommandStreamHandler : BaseStreamHandler() {
    val callback = object : MediaSessionCompat.Callback() {
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
    }

    override val logTag = LOG_TAG

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