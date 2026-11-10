package deckers.thibault.aves.storage

import android.Manifest
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.storage.StorageUtils.isInDownloadPath
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.UriUtils.isContentScheme
import deckers.thibault.aves.utils.UriUtils.tryParseId
import java.io.File
import java.util.Locale

object MediaStoreUriHelper {
    private val LOG_TAG = LogUtils.createTag<MediaStoreUriHelper>()

    fun isMediaStoreContentUri(uri: Uri?): Boolean {
        uri ?: return false
        // a URI's authority is [userinfo@]host[:port]
        // but we only want the host when comparing to Media Store's "authority"
        return uri.isContentScheme && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    fun sanitizeInputUri(context: Context, uri: Uri): Uri {
        // we get a permission denial if we require original from a provider other than the media store
        val path = uri.path
        path ?: return uri

        // from Android 11 (API 30), accessing the original URI for a `file` or `downloads` media content yields a `SecurityException`
        val imagesPath = MediaStore.Images.Media.EXTERNAL_CONTENT_URI.path!!
        val videoPath = MediaStore.Video.Media.EXTERNAL_CONTENT_URI.path!!
        if (path.startsWith(imagesPath) || path.startsWith(videoPath)) {
            // "Caller must hold ACCESS_MEDIA_LOCATION permission to access original"
            if (context.checkSelfPermission(Manifest.permission.ACCESS_MEDIA_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                return MediaStore.setRequireOriginal(uri)
            }
        }
        return uri
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    fun sanitizeOutputUri(context: Context, contentAddress: ContentAddress): Uri {
        var uri: Uri = contentAddress.uri

        // remove user id
        uri = stripMediaUriUserInfo(uri)

        // specify storage volume
        val path = contentAddress.path ?: throw IllegalArgumentException("null path for $contentAddress")
        val volumePath = StorageUtils.getVolumePath(context, path) ?: throw Exception("failed to find volume for path=$path")
        val rootContentUri = getOutputRootContentUriOnVolume(context, contentAddress.mimeType, volumePath)
        val contentId = uri.tryParseId()
        if (rootContentUri != null && contentId != null) {
            uri = ContentUris.withAppendedId(rootContentUri, contentId)
        }

        return uri
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    fun getMediaStoreVolumeName(context: Context, anyPath: String): String {
        val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as? StorageManager
        val volume = storageManager?.getStorageVolume(File(anyPath))
        volume ?: throw Exception("failed to get volume name because storage manager could not find volume for path=$anyPath")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val volumeName = volume.mediaStoreVolumeName
            volumeName ?: throw Exception("failed to get Media Store volume name because field is null")
            return volumeName
        }

        // normalization logic from Android source
        return if (volume.isPrimary) {
            MediaStore.VOLUME_EXTERNAL_PRIMARY
        } else {
            val uuid = volume.uuid
            uuid ?: throw Exception("failed to get Media Store volume name because volume UUID is null")
            uuid.lowercase(Locale.US)
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    fun getOutputRootContentUriOnVolume(context: Context, mimeType: String, anyPath: String): Uri? {
        val mediaStoreVolumeName = getMediaStoreVolumeName(context, anyPath)

        return if (isInDownloadPath(context, anyPath)) {
            MediaStore.Downloads.getContentUri(mediaStoreVolumeName)
        } else if (isImage(mimeType)) {
            MediaStore.Images.Media.getContentUri(mediaStoreVolumeName)
        } else if (isVideo(mimeType)) {
            MediaStore.Video.Media.getContentUri(mediaStoreVolumeName)
        } else {
            Log.w(LOG_TAG, "failed to find MediaStore content URI for mimeType=$mimeType, path=$anyPath")
            null
        }
    }

    // Build a typical `images` or `video` content URI from the original content ID.
    // We cannot safely apply this to a `file` content URI, as it may point to a file not indexed
    // by the Media Store (via `.nomedia`), and therefore has no matching image/video content URI.
    fun getMediaUri(uri: Uri, mimeType: String): Uri? {
        return uri.tryParseId()?.let { id ->
            return when {
                isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                else -> uri
            }
        }
    }

    /*
        Strip user info, if any
        e.g. `content://0@media/...`
          -> `content://media/...`

        `MediaStore` source indicates the following:
        ------------
        NOTE: The user-id in URI authority is ONLY required to find the correct MediaProvider
        process. Once in the correct process, the field is no longer required and may cause
        breakage in MediaProvider code. This is because per process logic is agnostic of
        user-id. Hence, strip away the user ids from URI, if present.
        ------------
     */
    fun stripMediaUriUserInfo(uri: Uri): Uri {
        if (uri.userInfo == null) return uri
        return uri.buildUpon().authority(uri.host).build()
    }
}