package deckers.thibault.aves.model.provider

import android.content.ContentResolver
import android.net.Uri
import android.provider.MediaStore
import java.util.*

object ImageProviderFactory {
    fun getProvider(uri: Uri): ImageProvider? {
        return when (uri.scheme?.lowercase(Locale.ROOT)) {
            ContentResolver.SCHEME_CONTENT -> {
                // a URI's authority is [userinfo@]host[:port]
                // but we only want the host when comparing to Media Store's "authority"
                return when (uri.host?.lowercase(Locale.ROOT)) {
                    MediaStore.AUTHORITY -> MediaStoreImageProvider()
                    else -> ContentImageProvider()
                }
            }
            ContentResolver.SCHEME_FILE -> FileImageProvider()
            else -> null
        }
    }
}