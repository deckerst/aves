package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.session.PlaybackState
import android.net.Uri
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Log
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.utils.FlutterUtils
import deckers.thibault.aves.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class MediaSessionHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    private val sessions = HashMap<Uri, MediaSessionCompat>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "update" -> ioScope.launch { safeSuspend(call, result, ::update) }
            "release" -> ioScope.launch { safe(call, result, ::release) }
            else -> result.notImplemented()
        }
    }

    private suspend fun update(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val title = call.argument<String>("title")
        val durationMillis = call.argument<Number>("durationMillis")?.toLong()
        val stateString = call.argument<String>("state")
        val positionMillis = call.argument<Number>("positionMillis")?.toLong()
        val playbackSpeed = call.argument<Number>("playbackSpeed")?.toFloat()

        if (uri == null || title == null || durationMillis == null || stateString == null || positionMillis == null || playbackSpeed == null) {
            result.error("update-args", "missing arguments", null)
            return
        }

        val state = when (stateString) {
            STATE_STOPPED -> PlaybackStateCompat.STATE_STOPPED
            STATE_PAUSED -> PlaybackStateCompat.STATE_PAUSED
            STATE_PLAYING -> PlaybackStateCompat.STATE_PLAYING
            else -> {
                result.error("update-state", "unknown state=$stateString", null)
                return
            }
        }

        var actions = PlaybackStateCompat.ACTION_PLAY_PAUSE or PlaybackStateCompat.ACTION_SEEK_TO
        actions = if (state == PlaybackState.STATE_PLAYING) {
            actions or PlaybackStateCompat.ACTION_PAUSE or PlaybackStateCompat.ACTION_STOP
        } else {
            actions or PlaybackStateCompat.ACTION_PLAY
        }

        val playbackState = PlaybackStateCompat.Builder()
            .setState(
                state,
                positionMillis,
                playbackSpeed,
                System.currentTimeMillis()
            )
            .setActions(actions)
            .build()

        var session = sessions[uri]
        if (session == null) {
            session = MediaSessionCompat(context, "aves-$uri")
            sessions[uri] = session

            val metadata = MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE, title)
                .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE, title)
                .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, durationMillis)
                .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_URI, uri.toString())
                .build()
            session.setMetadata(metadata)

            val callback: MediaSessionCompat.Callback = object : MediaSessionCompat.Callback() {
                override fun onPlay() {
                    super.onPlay()
                    Log.d(LOG_TAG, "TLAD onPlay uri=$uri")
                }

                override fun onPause() {
                    super.onPause()
                    Log.d(LOG_TAG, "TLAD onPause uri=$uri")
                }

                override fun onStop() {
                    super.onStop()
                    Log.d(LOG_TAG, "TLAD onStop uri=$uri")
                }

                override fun onSeekTo(pos: Long) {
                    super.onSeekTo(pos)
                    Log.d(LOG_TAG, "TLAD onSeekTo uri=$uri pos=$pos")
                }
            }
            FlutterUtils.runOnUiThread {
                session.setCallback(callback)
            }
        }

        session.setPlaybackState(playbackState)

        if (!session.isActive) {
            session.isActive = true
        }

        result.success(null)
    }

    private fun release(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }

        if (uri == null) {
            result.error("release-args", "missing arguments", null)
            return
        }

        sessions[uri]?.release()

        result.success(null)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaSessionHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_session"

        const val STATE_STOPPED = "stopped"
        const val STATE_PAUSED = "paused"
        const val STATE_PLAYING = "playing"
    }
}