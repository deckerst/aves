package deckers.thibault.aves.model.provider

import android.content.ContentResolver
import android.content.Context
import android.net.Uri
import deckers.thibault.aves.storage.MediaStoreUriHelper
import java.util.Locale

object ImageProviderFactory {
    fun getProvider(context: Context, uri: Uri): ImageProvider? {
        return when (uri.scheme?.lowercase(Locale.ROOT)) {
            ContentResolver.SCHEME_CONTENT -> {
                if (MediaStoreUriHelper.isMediaStoreContentUri(uri)) {
                    MediaStoreImageProvider()
                } else if (AvesEmbeddedMediaProvider.provides(context, uri)) {
                    AvesEmbeddedMediaProvider()
                } else {
                    UnknownContentProvider()
                }
            }

            ContentResolver.SCHEME_FILE -> FileImageProvider()
            else -> null
        }
    }
}