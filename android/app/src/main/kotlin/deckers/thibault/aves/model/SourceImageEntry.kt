package deckers.thibault.aves.model

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import com.drew.imaging.ImageMetadataReader
import com.drew.metadata.avi.AviDirectory
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.jpeg.JpegDirectory
import com.drew.metadata.mp4.Mp4Directory
import com.drew.metadata.mp4.media.Mp4VideoDirectory
import com.drew.metadata.photoshop.PsdHeaderDirectory
import deckers.thibault.aves.utils.MetadataHelper.getRotationDegreesForExifCode
import deckers.thibault.aves.utils.MetadataHelper.isFlippedForExifCode
import deckers.thibault.aves.utils.MetadataHelper.parseVideoMetadataDate
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isSupportedByMetadataExtractor
import deckers.thibault.aves.utils.StorageUtils
import java.io.IOException
import java.util.*

class SourceImageEntry {
    val uri: Uri // content or file URI
    var path: String? = null // best effort to get local path
    private val sourceMimeType: String
    var title: String? = null
    var width: Int? = null
    var height: Int? = null
    private var rotationDegrees: Int? = null
    private var isFlipped: Boolean? = null
    var sizeBytes: Long? = null
    var dateModifiedSecs: Long? = null
    private var sourceDateTakenMillis: Long? = null
    private var durationMillis: Long? = null

    constructor(uri: Uri, sourceMimeType: String) {
        this.uri = uri
        this.sourceMimeType = sourceMimeType
    }

    constructor(map: Map<String, Any?>) {
        uri = Uri.parse(map["uri"] as String)
        path = map["path"] as String?
        sourceMimeType = map["sourceMimeType"] as String
        width = map["width"] as Int
        height = map["height"] as Int
        rotationDegrees = map["rotationDegrees"] as Int
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
                "rotationDegrees" to (rotationDegrees ?: 0),
                "isFlipped" to (isFlipped ?: false),
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

    val hasSize: Boolean
        get() = width ?: 0 > 0 && height ?: 0 > 0

    private val hasOrientation: Boolean
        get() = rotationDegrees != null

    private val hasDuration: Boolean
        get() = durationMillis ?: 0 > 0

    private val isImage: Boolean
        get() = sourceMimeType.startsWith(MimeTypes.IMAGE)

    private val isVideo: Boolean
        get() = sourceMimeType.startsWith(MimeTypes.VIDEO)

    val isSvg: Boolean
        get() = sourceMimeType == MimeTypes.SVG

    // metadata retrieval
    // expects entry with: uri, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    fun fillPreCatalogMetadata(context: Context): SourceImageEntry {
        if (isSvg) return this
        fillByMediaMetadataRetriever(context)
        if (hasSize && hasOrientation && (!isVideo || hasDuration)) return this
        fillByMetadataExtractor(context)
        if (hasSize) return this
        fillByBitmapDecode(context)
        return this
    }

    // expects entry with: uri, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    private fun fillByMediaMetadataRetriever(context: Context) {
        if (isImage) return
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return
        try {
            var width: String? = null
            var height: String? = null
            var rotationDegrees: String? = null
            var durationMillis: String? = null
            if (isImage) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH)
                    height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT)
                    rotationDegrees = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION)
                }
            } else if (isVideo) {
                width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                rotationDegrees = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                durationMillis = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            }
            if (width != null) {
                this.width = width.toInt()
            }
            if (height != null) {
                this.height = height.toInt()
            }
            if (rotationDegrees != null) {
                this.rotationDegrees = rotationDegrees.toInt()
            }
            if (durationMillis != null) {
                this.durationMillis = durationMillis.toLong()
            }
            val dateString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE)
            val dateMillis = parseVideoMetadataDate(dateString)
            // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
            if (dateMillis > 0) {
                sourceDateTakenMillis = dateMillis
            }
            val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            if (title != null) {
                this.title = title
            }
        } catch (e: Exception) {
            // ignore
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
    }

    // expects entry with: uri, mimeType
    // finds: width, height, orientation, date
    private fun fillByMetadataExtractor(context: Context) {
        if (!isSupportedByMetadataExtractor(sourceMimeType)) return
        try {
            StorageUtils.openInputStream(context, uri).use { input ->
                val metadata = ImageMetadataReader.readMetadata(input)

                // do not switch on specific mime types, as the reported mime type could be wrong
                // (e.g. PNG registered as JPG)
                if (isVideo) {
                    for (dir in metadata.getDirectoriesOfType(AviDirectory::class.java)) {
                        if (dir.containsTag(AviDirectory.TAG_WIDTH)) {
                            width = dir.getInt(AviDirectory.TAG_WIDTH)
                        }
                        if (dir.containsTag(AviDirectory.TAG_HEIGHT)) {
                            height = dir.getInt(AviDirectory.TAG_HEIGHT)
                        }
                        if (dir.containsTag(AviDirectory.TAG_DURATION)) {
                            durationMillis = dir.getLong(AviDirectory.TAG_DURATION)
                        }
                    }
                    for (dir in metadata.getDirectoriesOfType(Mp4VideoDirectory::class.java)) {
                        if (dir.containsTag(Mp4VideoDirectory.TAG_WIDTH)) {
                            width = dir.getInt(Mp4VideoDirectory.TAG_WIDTH)
                        }
                        if (dir.containsTag(Mp4VideoDirectory.TAG_HEIGHT)) {
                            height = dir.getInt(Mp4VideoDirectory.TAG_HEIGHT)
                        }
                    }
                    for (dir in metadata.getDirectoriesOfType(Mp4Directory::class.java)) {
                        if (dir.containsTag(Mp4Directory.TAG_DURATION)) {
                            durationMillis = dir.getLong(Mp4Directory.TAG_DURATION)
                        }
                    }
                } else {
                    for (dir in metadata.getDirectoriesOfType(JpegDirectory::class.java)) {
                        if (dir.containsTag(JpegDirectory.TAG_IMAGE_WIDTH)) {
                            width = dir.getInt(JpegDirectory.TAG_IMAGE_WIDTH)
                        }
                        if (dir.containsTag(JpegDirectory.TAG_IMAGE_HEIGHT)) {
                            height = dir.getInt(JpegDirectory.TAG_IMAGE_HEIGHT)
                        }
                    }
                    for (dir in metadata.getDirectoriesOfType(PsdHeaderDirectory::class.java)) {
                        if (dir.containsTag(PsdHeaderDirectory.TAG_IMAGE_WIDTH)) {
                            width = dir.getInt(PsdHeaderDirectory.TAG_IMAGE_WIDTH)
                        }
                        if (dir.containsTag(PsdHeaderDirectory.TAG_IMAGE_HEIGHT)) {
                            height = dir.getInt(PsdHeaderDirectory.TAG_IMAGE_HEIGHT)
                        }
                    }

                    // EXIF, if defined, should override metadata found in other directories
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        if (dir.containsTag(ExifIFD0Directory.TAG_IMAGE_WIDTH)) {
                            width = dir.getInt(ExifIFD0Directory.TAG_IMAGE_WIDTH)
                        }
                        if (dir.containsTag(ExifIFD0Directory.TAG_IMAGE_HEIGHT)) {
                            height = dir.getInt(ExifIFD0Directory.TAG_IMAGE_HEIGHT)
                        }
                        if (dir.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
                            val exifOrientation = dir.getInt(ExifIFD0Directory.TAG_ORIENTATION)
                            rotationDegrees = getRotationDegreesForExifCode(exifOrientation)
                            isFlipped = isFlippedForExifCode(exifOrientation)
                        }
                        if (dir.containsTag(ExifIFD0Directory.TAG_DATETIME)) {
                            sourceDateTakenMillis = dir.getDate(ExifIFD0Directory.TAG_DATETIME, null, TimeZone.getDefault()).time
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

    // expects entry with: uri
    // finds: width, height
    private fun fillByBitmapDecode(context: Context) {
        try {
            StorageUtils.openInputStream(context, uri).use { input ->
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