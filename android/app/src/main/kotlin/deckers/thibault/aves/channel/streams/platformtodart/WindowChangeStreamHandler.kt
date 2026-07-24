package deckers.thibault.aves.channel.streams.platformtodart

import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.utils.LogUtils

class WindowChangeStreamHandler : BaseStreamHandler() {
    fun notifyCutoutInsetsChange() = success(mapOf(KEY_CODE to CODE_CUTOUT_INSETS))
    fun notifySystemBarVisibilityChange(statusBarVisible: Boolean, navBarVisible: Boolean) {
        success(mapOf(
            KEY_CODE to CODE_SYSTEM_BAR_VISIBILITY,
            "status_bar" to statusBarVisible,
            "nav_bar" to navBarVisible,
        ))
    }
    fun notifyWindowModeChange() = success(mapOf(KEY_CODE to CODE_WINDOW_MODE))

    override val logTag = LOG_TAG

    companion object {
        private val LOG_TAG = LogUtils.createTag<WindowChangeStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/window_change"

        private const val KEY_CODE = "code"

        private const val CODE_CUTOUT_INSETS = "cutout_insets"
        private const val CODE_SYSTEM_BAR_VISIBILITY = "system_bar_visibility"
        private const val CODE_WINDOW_MODE = "window_mode"
    }
}