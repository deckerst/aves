package deckers.thibault.aves.model.provider

import android.content.Context
import android.net.Uri
import deckers.thibault.aves.utils.UriUtils.isContentScheme

class AvesEmbeddedMediaProvider : UnknownContentProvider() {
    override val reliableProviderMimeType: Boolean
        get() = true

    companion object {
        fun provides(context: Context, uri: Uri): Boolean {
            if (!uri.isContentScheme) return false
            return uri.authority == "${context.applicationContext.packageName}.file_provider"
        }
    }
}