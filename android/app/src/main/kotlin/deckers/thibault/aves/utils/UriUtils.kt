package deckers.thibault.aves.utils

import android.content.ContentResolver
import android.net.Uri

object UriUtils {
    private const val SCHEME_DATA = "data"
    private const val SCHEME_GEO = "geo"

    val Uri.isContentScheme: Boolean
        get() = ContentResolver.SCHEME_CONTENT.equals(scheme, ignoreCase = true)

    val Uri.isFileScheme: Boolean
        get() = ContentResolver.SCHEME_FILE.equals(scheme, ignoreCase = true)

    val Uri.isDataScheme: Boolean
        get() = SCHEME_DATA.equals(scheme, ignoreCase = true)

    val Uri.isGeoScheme: Boolean
        get() = SCHEME_GEO.equals(scheme, ignoreCase = true)
}