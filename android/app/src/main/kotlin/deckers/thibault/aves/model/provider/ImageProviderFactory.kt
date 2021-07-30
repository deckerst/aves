package deckers.thibault.aves.model.provider

import android.content.ContentResolver
import android.net.Uri
import deckers.thibault.aves.utils.StorageUtils
import java.util.*

object ImageProviderFactory {
    fun getProvider(uri: Uri): ImageProvider? {
        return when (uri.scheme?.lowercase(Locale.ROOT)) {
            ContentResolver.SCHEME_CONTENT -> {
                if (StorageUtils.isMediaStoreContentUri(uri)) {
                    MediaStoreImageProvider()
                } else {
                    ContentImageProvider()
                }
            }
            ContentResolver.SCHEME_FILE -> FileImageProvider()
            else -> null
        }
    }
}