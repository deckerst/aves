package deckers.thibault.aves.channel.streams.platformtodart

import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.utils.LogUtils

class WindowChangeStreamHandler : BaseStreamHandler() {
    fun notifyCutoutInsetsChange() = success(CODE_CUTOUT_INSETS)
    fun notifyWindowModeChange() = success(CODE_WINDOW_MODE)

    override val logTag = LOG_TAG

    companion object {
        private val LOG_TAG = LogUtils.createTag<ErrorStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/window_change"

        private const val CODE_CUTOUT_INSETS = "cutout_insets"
        private const val CODE_WINDOW_MODE = "window_mode"
    }
}