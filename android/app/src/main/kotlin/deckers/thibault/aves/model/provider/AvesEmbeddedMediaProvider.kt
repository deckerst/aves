package deckers.thibault.aves.model.provider

import android.content.ContentResolver
import android.content.Context
import android.net.Uri
import java.util.Locale

class AvesEmbeddedMediaProvider : UnknownContentProvider() {
    override val reliableProviderMimeType: Boolean
        get() = true

    companion object {
        fun provides(context: Context, uri: Uri): Boolean {
            if (uri.scheme?.lowercase(Locale.ROOT) != ContentResolver.SCHEME_CONTENT) return false
            return uri.authority == "${context.applicationContext.packageName}.file_provider"
        }
    }
}