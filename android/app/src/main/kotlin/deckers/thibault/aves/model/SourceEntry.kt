package deckers.thibault.aves.model

import android.content.ContentResolver
import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
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
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.metadata.metadataextractor.Helper
import deckers.thibault.aves.metadata.metadataextractor.Helper.getSafeDateMillis
import deckers.thibault.aves.metadata.metadataextractor.Helper.getSafeInt
import deckers.thibault.aves.metadata.metadataextractor.Helper.getSafeLong
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.UriUtils.tryParseId
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.IOException
import androidx.exifinterface.media.ExifInterfaceFork as ExifInterface
import androidx.core.net.toUri

class SourceEntry {
    private val origin: Int
    val uri: Uri // content or file URI
    var path: String? = null // best effort to get local path
    private val sourceMimeType: String
    private var title: String? = null
    var width: Int? = null
    var height: Int? = null
    private var sourceRotationDegrees: Int? = null
    private var sizeBytes: Long? = null
    private var dateAddedSecs: Long? = null
    private var dateModifiedSecs: Long? = null
    private var sourceDateTakenMillis: Long? = null
    private var durationMillis: Long? = null

    private var foundExif: Boolean = false

    constructor(origin: Int, uri: Uri, sourceMimeType: String) {
        this.origin = origin
        this.uri = uri
        this.sourceMimeType = sourceMimeType
    }

    constructor(map: FieldMap) {
        origin = map["origin"] as Int
        uri = (map["uri"] as String).toUri()
        path = map["path"] as String?
        sourceMimeType = map["sourceMimeType"] as String
        width = map["width"] as Int?
        height = map["height"] as Int?
        sourceRotationDegrees = map["sourceRotationDegrees"] as Int?
        sizeBytes = toLong(map["sizeBytes"])
        title = map["title"] as String?
        dateAddedSecs = toLong(map["dateAddedSecs"])
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

    fun toMap(): FieldMap {
        return hashMapOf(
            "origin" to origin,
            "uri" to uri.toString(),
            "path" to path,
            "sourceMimeType" to sourceMimeType,
            "width" to width,
            "height" to height,
            "sourceRotationDegrees" to (sourceRotationDegrees ?: 0),
            "sizeBytes" to sizeBytes,
            "title" to title,
            "dateAddedSecs" to dateAddedSecs,
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
        get() = if (uri.scheme == ContentResolver.SCHEME_CONTENT) uri.tryParseId() else null

    val isSized: Boolean
        get() = (width ?: 0) > 0 && (height ?: 0) > 0

    private val hasDuration: Boolean
        get() = (durationMillis ?: 0) > 0

    val isVideo: Boolean
        get() = MimeTypes.isVideo(sourceMimeType)

    val isSvg: Boolean
        get() = sourceMimeType == MimeTypes.SVG

    // metadata retrieval
    // expects entry with: uri, mimeType
    // finds: width, height, orientation/rotation, date, title, duration
    fun fillPreCatalogMetadata(context: Context): SourceEntry {
        if (isSvg) return this
        if (isVideo) {
            fillVideoByMediaMetadataRetriever(context)
            if (isSized && hasDuration) return this
            fillByMetadataExtractor(context)
        } else {
            fillByMetadataExtractor(context)
            if (isSized && foundExif) return this
            fillByExifInterface(context)
        }
        if (!isSized) {
            when (sourceMimeType) {
                MimeTypes.TIFF -> fillByTiffDecode(context)
                else -> fillByBitmapDecode(context)
            }
        }
        return this
    }

    // finds: width, height, orientation, date, duration, title
    private fun fillVideoByMediaMetadataRetriever(context: Context) {
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return
        try {
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH) { width = it }
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT) { height = it }
            retriever.getSafeLong(MediaMetadataRetriever.METADATA_KEY_DURATION) { durationMillis = it }
            retriever.getSafeDateMillis(MediaMetadataRetriever.METADATA_KEY_DATE) { sourceDateTakenMillis = it }
            retriever.getSafeString(MediaMetadataRetriever.METADATA_KEY_TITLE) { title = it }
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { sourceRotationDegrees = it }
        } catch (e: Exception) {
            // ignore
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
    }

    // finds: width, height, orientation, date, duration
    private fun fillByMetadataExtractor(context: Context) {
        // skip raw images because `metadata-extractor` reports the decoded dimensions instead of the raw dimensions
        if (!MimeTypes.canReadWithMetadataExtractor(sourceMimeType)
            || MimeTypes.isRaw(sourceMimeType)
        ) return

        try {
            Metadata.openSafeInputStream(context, uri, sourceMimeType, sizeBytes)?.use { input ->
                val metadata = Helper.safeRead(input, sizeBytes)

                // do not switch on specific MIME types, as the reported MIME type could be wrong
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
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        foundExif = true
                        dir.getSafeInt(ExifIFD0Directory.TAG_IMAGE_WIDTH) { width = it }
                        dir.getSafeInt(ExifIFD0Directory.TAG_IMAGE_HEIGHT) { height = it }
                        dir.getSafeInt(ExifIFD0Directory.TAG_ORIENTATION) { sourceRotationDegrees = getRotationDegreesForExifCode(it) }
                        dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME, null)?.let { sourceDateTakenMillis = it }
                    }

                    // dimensions reported in EXIF do not always match the image
                    // so we fetch them from the format directory if available
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
        } catch (e: Exception) {
            // ignore
        } catch (e: NoClassDefFoundError) {
            // ignore
        } catch (e: AssertionError) {
            // ignore
        }
    }

    // finds: width, height, orientation, date
    private fun fillByExifInterface(context: Context) {
        if (!MimeTypes.canReadWithExifInterface(sourceMimeType)) return

        try {
            Metadata.openSafeInputStream(context, uri, sourceMimeType, sizeBytes)?.use { input ->
                val exif = ExifInterface(input)
                foundExif = true
                exif.getSafeInt(ExifInterface.TAG_IMAGE_WIDTH, acceptZero = false) { width = it }
                exif.getSafeInt(ExifInterface.TAG_IMAGE_LENGTH, acceptZero = false) { height = it }
                exif.getSafeInt(ExifInterface.TAG_ORIENTATION, acceptZero = false) { sourceRotationDegrees = exif.rotationDegrees }
                exif.getSafeDateMillis(ExifInterface.TAG_DATETIME, ExifInterface.TAG_SUBSEC_TIME) { sourceDateTakenMillis = it }
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
                val options = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                BitmapFactory.decodeStream(input, null, options)
                width = options.outWidth
                height = options.outHeight
            }
        } catch (e: IOException) {
            // ignore
        }
    }

    private fun fillByTiffDecode(context: Context) {
        try {
            context.contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                val fd = pfd.detachFd()
                val options = TiffBitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                TiffBitmapFactory.decodeFileDescriptor(fd, options)
                width = options.outWidth
                height = options.outHeight
            }
        } catch (e: Exception) {
            // ignore
        }
    }

    companion object {
        // convenience method
        private fun toLong(o: Any?): Long? = when (o) {
            is Int -> o.toLong()
            else -> o as? Long
        }

        // should match `EntryOrigins` on the Dart side
        const val ORIGIN_MEDIA_STORE_CONTENT = 0
        const val ORIGIN_UNKNOWN_CONTENT = 1
        const val ORIGIN_FILE = 2
        const val ORIGIN_VAULT = 3
    }
}