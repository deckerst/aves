package deckers.thibault.aves.channel.streams.platformtodart

import deckers.thibault.aves.channel.streams.BaseStreamHandler
import deckers.thibault.aves.utils.LogUtils

class IntentStreamHandler : BaseStreamHandler() {
    fun notifyNewIntent(intentData: MutableMap<String, Any?>?) = success(intentData)

    override val logTag = LOG_TAG

    companion object {
        private val LOG_TAG = LogUtils.createTag<IntentStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/new_intent_stream"
    }
}