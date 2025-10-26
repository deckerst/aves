package deckers.thibault.aves.channel.streams.platformtodart

import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.utils.LogUtils

class MessageStreamHandler : BaseStreamHandler() {
    fun notifyDebug(message: String) = success(message)

    override val logTag = LOG_TAG

    companion object {
        private val LOG_TAG = LogUtils.createTag<MessageStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/platform_messages"
    }
}