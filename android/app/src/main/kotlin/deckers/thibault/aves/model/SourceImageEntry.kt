package deckers.thibault.aves.model

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.exifinterface.media.ExifInterface
import com.drew.imaging.ImageMetadataReader
import com.drew.metadata.avi.AviDirectory
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.jpeg.JpegDirectory
import com.drew.metadata.mp4.Mp4Directory
import com.drew.metadata.mp4.media.Mp4VideoDirectory
import com.drew.metadata.photoshop.PsdHeaderDirectory
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeLong
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeString
import deckers.thibault.aves.metadata.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeLong
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import java.io.IOException

class SourceImageEntry {
    val uri: Uri // content or file URI
    var path: String? = null // best effort to get local path
    private val sourceMimeType: String
    private var title: String? = null
    var width: Int? = null
    var height: Int? = null
    private var sourceRotationDegrees: Int? = null
    private var sizeBytes: Long? = null
    private var dateModifiedSecs: Long? = null
    private var sourceDateTakenMillis: Long? = null
    private var durationMillis: Long? = null

    private var foundExif: Boolean = false

    constructor(uri: Uri, sourceMimeType: String) {
        this.uri = uri
        this.sourceMimeType = sourceMimeType
    }

    constructor(map: Map<String, Any?>) {
        uri = Uri.parse(map["uri"] as String)
        path = map["path"] as String?
        sourceMimeType = map["sourceMimeType"] as String
        width = map["width"] as Int?
        height = map["height"] as Int?
        sourceRotationDegrees = map["sourceRotationDegrees"] as Int?
        sizeBytes = toLong(map["sizeBytes"])
        title = map["title"] as String?
        dateModifiedSecs = toLong(map["dateModifiedSecs"])
        sourceDateTakenMillis = toLong(map["sourceDateTakenMillis"])
        durationMillis = toLong(map["durationMillis"])
    }

    fun initFromFile(path: String, title: String, sizeBytes: Long, dateModifiedSecs: Long) {
        this.path = path
        this.title = title
        this.sizeBytes = sizeBytes
        this.dateModifiedSecs = dateModifiedSecs
    }

    fun toMap(): Map<String, Any?> {
        return hashMapOf(
            "uri" to uri.toString(),
            "path" to path,
            "sourceMimeType" to sourceMimeType,
            "width" to width,
            "height" to height,
            "sourceRotationDegrees" to (sourceRotationDegrees ?: 0),
            "sizeBytes" to sizeBytes,
            "title" to title,
            "dateModifiedSecs" to dateModifiedSecs,
            "sourceDateTakenMillis" to sourceDateTakenMillis,
            "durationMillis" to durationMillis,
            // only for map export
            "contentId" to contentId,
        )
    }

    // ignore when the ID is not a number
    // e.g. content://com.sec.android.app.myfiles.FileProvider/device_storage/20200109_162621.jpg
    private val contentId: Long?
        get() {
            if (uri.scheme == ContentResolver.SCHEME_CONTENT) {
                try {
                    return ContentUris.parseId(uri)
                } catch (e: Exception) {
                    // ignore
                }
            }
            return null
        }

    val isSized: Boolean
        get() = width ?: 0 > 0 && height ?: 0 > 0

    private val hasDuration: Boolean
        get() = durationMillis ?: 0 > 0

    private val isVideo: Boolean
        get() = MimeTypes.isVideo(sourceMimeType)

    val isSvg: Boolean
        get() = sourceMimeType == MimeTypes.SVG

    // metadata retrieval
    // expects entry with: uri, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    fun fillPreCatalogMetadata(context: Context): SourceImageEntry {
        if (isSvg) return this
        if (isVideo) {
            fillVideoByMediaMetadataRetriever(context)
            if (isSized && hasDuration) return this
        }
        if (MimeTypes.isSupportedByMetadataExtractor(sourceMimeType)) {
            fillByMetadataExtractor(context)
            if (isSized && foundExif) return this
        }
        if (ExifInterface.isSupportedMimeType(sourceMimeType)) {
            fillByExifInterface(context)
            if (isSized) return this
        }
        fillByBitmapDecode(context)
        return this
    }

    // finds: width, height, orientation, date, duration, title
    private fun fillVideoByMediaMetadataRetriever(context: Context) {
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return
        try {
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH) { width = it }
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT) { height = it }
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { sourceRotationDegrees = it }
            retriever.getSafeLong(MediaMetadataRetriever.METADATA_KEY_DURATION) { durationMillis = it }
            retriever.getSafeDateMillis(MediaMetadataRetriever.METADATA_KEY_DATE) { sourceDateTakenMillis = it }
            retriever.getSafeString(MediaMetadataRetriever.METADATA_KEY_TITLE) { title = it }
        } catch (e: Exception) {
            // ignore
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
    }

    // finds: width, height, orientation, date, duration
    private fun fillByMetadataExtractor(context: Context) {
        try {
            StorageUtils.openInputStream(context, uri)?.use { input ->
                val metadata = ImageMetadataReader.readMetadata(input)

                // do not switch on specific mime types, as the reported mime type could be wrong
                // (e.g. PNG registered as JPG)
                if (isVideo) {
                    for (dir in metadata.getDirectoriesOfType(AviDirectory::class.java)) {
                        dir.getSafeInt(AviDirectory.TAG_WIDTH) { width = it }
                        dir.getSafeInt(AviDirectory.TAG_HEIGHT) { height = it }
                        dir.getSafeLong(AviDirectory.TAG_DURATION) { durationMillis = it }
                    }
                    for (dir in metadata.getDirectoriesOfType(Mp4VideoDirectory::class.java)) {
                        dir.getSafeInt(Mp4VideoDirectory.TAG_WIDTH) { width = it }
                        dir.getSafeInt(Mp4VideoDirectory.TAG_HEIGHT) { height = it }
                    }
                    for (dir in metadata.getDirectoriesOfType(Mp4Directory::class.java)) {
                        dir.getSafeInt(Mp4Directory.TAG_ROTATION) { sourceRotationDegrees = it }
                        dir.getSafeLong(Mp4Directory.TAG_DURATION) { durationMillis = it }
                    }
                } else {
                    // EXIF, if defined, should override metadata found in other directories
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        foundExif = true
                        dir.getSafeInt(ExifIFD0Directory.TAG_IMAGE_WIDTH) { width = it }
                        dir.getSafeInt(ExifIFD0Directory.TAG_IMAGE_HEIGHT) { height = it }
                        dir.getSafeInt(ExifIFD0Directory.TAG_ORIENTATION) { sourceRotationDegrees = getRotationDegreesForExifCode(it) }
                        dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME) { sourceDateTakenMillis = it }
                    }

                    if (!foundExif) {
                        for (dir in metadata.getDirectoriesOfType(JpegDirectory::class.java)) {
                            dir.getSafeInt(JpegDirectory.TAG_IMAGE_WIDTH) { width = it }
                            dir.getSafeInt(JpegDirectory.TAG_IMAGE_HEIGHT) { height = it }
                        }
                        for (dir in metadata.getDirectoriesOfType(PsdHeaderDirectory::class.java)) {
                            dir.getSafeInt(PsdHeaderDirectory.TAG_IMAGE_WIDTH) { width = it }
                            dir.getSafeInt(PsdHeaderDirectory.TAG_IMAGE_HEIGHT) { height = it }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // ignore
        } catch (e: NoClassDefFoundError) {
            // ignore
        }
    }

    // finds: width, height, orientation, date
    private fun fillByExifInterface(context: Context) {
        try {
            StorageUtils.openInputStream(context, uri)?.use { input ->
                val exif = ExifInterface(input)
                foundExif = true
                exif.getSafeInt(ExifInterface.TAG_IMAGE_WIDTH, acceptZero = false) { width = it }
                exif.getSafeInt(ExifInterface.TAG_IMAGE_LENGTH, acceptZero = false) { height = it }
                exif.getSafeInt(ExifInterface.TAG_ORIENTATION, acceptZero = false) { sourceRotationDegrees = exif.rotationDegrees }
                exif.getSafeDateMillis(ExifInterface.TAG_DATETIME) { sourceDateTakenMillis = it }
            }
        } catch (e: Exception) {
            // ExifInterface initialization can fail with a RuntimeException
            // caused by an internal MediaMetadataRetriever failure
        }
    }

    // finds: width, height
    private fun fillByBitmapDecode(context: Context) {
        try {
            StorageUtils.openInputStream(context, uri)?.use { input ->
                val options = BitmapFactory.Options()
                options.inJustDecodeBounds = true
                BitmapFactory.decodeStream(input, null, options)
                width = options.outWidth
                height = options.outHeight
            }
        } catch (e: IOException) {
            // ignore
        }
    }

    companion object {
        // convenience method
        private fun toLong(o: Any?): Long? = when (o) {
            is Int -> o.toLong()
            else -> o as? Long
        }
    }
}