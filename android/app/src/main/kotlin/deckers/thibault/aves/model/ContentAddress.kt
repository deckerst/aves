package deckers.thibault.aves.model

import android.net.Uri

class ContentAddress(val mimeType: String, val uri: Uri, val path: String?, val pageId: Int?) {
    override fun toString(): String = "mimeType=$mimeType uri=$uri" +
            (if (path != null) " path=$path" else "") +
            (if (pageId != null) " pageId=$pageId" else "")
}