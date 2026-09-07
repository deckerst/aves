package deckers.thibault.aves.channel.streams.platformtodart

import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.utils.LogUtils

class MessageStreamHandler : BaseStreamHandler() {
    fun notifyDebug(message: String) = send(LEVEL_DEBUG, message)

    fun notifyError(message: String) = send(LEVEL_ERROR, message)

    private fun send(level: String, message: String) {
        success(
            hashMapOf(
                "level" to level,
                "message" to message,
            )
        )
    }

    override val logTag = LOG_TAG

    companion object {
        private val LOG_TAG = LogUtils.createTag<MessageStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/platform_messages"
        private const val LEVEL_DEBUG = "DEBUG"
        private const val LEVEL_ERROR = "ERROR"
    }
}