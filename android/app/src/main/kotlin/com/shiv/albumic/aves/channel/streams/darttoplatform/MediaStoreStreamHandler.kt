package com.shiv.albumic.channel.streams.darttoplatform

import android.content.Context
import com.shiv.albumic.channel.streams.BaseStreamHandler
import com.shiv.albumic.model.provider.MediaStoreImageProvider
import com.shiv.albumic.utils.LogUtils
import kotlinx.coroutines.launch

class MediaStoreStreamHandler(private val context: Context, arguments: Any?) : BaseStreamHandler() {
    // knownEntries: map of contentId -> dateModifiedMillis
    private var knownEntries: Map<Long?, Long?>? = null
    private var directory: String? = null

    init {
        if (arguments is Map<*, *>) {
            knownEntries = (arguments["knownEntries"] as? Map<*, *>?)?.map { (it.key as Number?)?.toLong() to (it.value as Number?)?.toLong() }?.toMap()
            directory = arguments["directory"] as String?
        }
    }

    override val logTag = LOG_TAG

    override fun onCall(args: Any?) {
        ioScope.launch { safe(::fetchAll) }
    }

    private fun fetchAll() {
        MediaStoreImageProvider().fetchAll(context, knownEntries ?: emptyMap(), directory) { success(it) }
        endOfStream()
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MediaStoreStreamHandler>()
        const val CHANNEL = "deckers.thibault/aves/media_store_stream"
    }
}
