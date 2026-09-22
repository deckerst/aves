package com.shiv.albumic.channel.streams.platformtodart

import com.shiv.albumic.channel.streams.BaseStreamHandler
import com.shiv.albumic.utils.LogUtils

class AnalysisStreamHandler : BaseStreamHandler() {
    fun notifyCompletion() = success(true)

    override val logTag = LOG_TAG

    companion object {
        private val LOG_TAG = LogUtils.createTag<AnalysisStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/analysis_events"
    }
}
