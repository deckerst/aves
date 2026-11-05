package deckers.thibault.aves.model

import android.net.Uri
import androidx.core.net.toUri
import io.flutter.plugin.common.MethodCall

class ContentAddress(val mimeType: String, val uri: Uri, val path: String?, val pageId: Int?) {
    override fun toString(): String = "mimeType=$mimeType uri=$uri" +
            (if (path != null) " path=$path" else "") +
            (if (pageId != null) " pageId=$pageId" else "")

    companion object {
        fun fromMethodCall(call: MethodCall): ContentAddress? {
            val mimeType = call.argument<String>(EntryFields.MIME_TYPE)
            val uri = call.argument<String>(EntryFields.URI)?.toUri()
            val path = call.argument<String>(EntryFields.PATH)
            val pageId = call.argument<Int>(EntryFields.PAGE_ID)

            if (mimeType == null || uri == null) {
                return null
            }

            return ContentAddress(mimeType = mimeType, uri = uri, path = path, pageId = pageId)
        }

        fun fromMap(arguments: Map<*, *>): ContentAddress? {
            val mimeType = arguments[EntryFields.MIME_TYPE] as String?
            val uri = (arguments[EntryFields.URI] as String?)?.toUri()
            val path = arguments[EntryFields.PATH] as String?
            val pageId = arguments[EntryFields.PAGE_ID] as Int?

            if (mimeType == null || uri == null) {
                return null
            }

            return ContentAddress(mimeType = mimeType, uri = uri, path = path, pageId = pageId)
        }
    }
}