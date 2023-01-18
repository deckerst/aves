package deckers.thibault.aves

import android.os.Bundle
import android.support.v4.media.MediaBrowserCompat
import androidx.media.MediaBrowserServiceCompat

// dummy service to handle media button events
// when there is no active media sessions
class MediaPlaybackService : MediaBrowserServiceCompat() {
    override fun onGetRoot(clientPackageName: String, clientUid: Int, rootHints: Bundle?): BrowserRoot? {
        return null
    }

    override fun onLoadChildren(parentId: String, result: Result<MutableList<MediaBrowserCompat.MediaItem>>) {
        val children = mutableListOf<MediaBrowserCompat.MediaItem>()
        result.sendResult(children)
    }
}