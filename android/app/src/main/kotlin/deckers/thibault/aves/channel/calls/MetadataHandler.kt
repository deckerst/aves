package deckers.thibault.aves.channel.calls

import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPUtils
import com.adobe.internal.xmp.properties.XMPPropertyInfo
import com.drew.imaging.ImageMetadataReader
import com.drew.imaging.ImageProcessingException
import com.drew.lang.Rational
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
import com.drew.metadata.file.FileTypeDirectory
import com.drew.metadata.gif.GifAnimationDirectory
import com.drew.metadata.webp.WebpDirectory
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.utils.*
import deckers.thibault.aves.utils.ExifInterfaceHelper.describeAll
import deckers.thibault.aves.utils.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.utils.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.utils.MediaMetadataRetrieverHelper.getSafeDescription
import deckers.thibault.aves.utils.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.utils.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.utils.Metadata.isFlippedForExifCode
import deckers.thibault.aves.utils.Metadata.parseVideoMetadataDate
import deckers.thibault.aves.utils.MetadataExtractorHelper.getSafeBoolean
import deckers.thibault.aves.utils.MetadataExtractorHelper.getSafeDateMillis
import deckers.thibault.aves.utils.MetadataExtractorHelper.getSafeDescription
import deckers.thibault.aves.utils.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.utils.MetadataExtractorHelper.getSafeRational
import deckers.thibault.aves.utils.MimeTypes.getMimeTypeForExtension
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isSupportedByMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.XMP.getSafeLocalizedText
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.IOException
import java.util.*
import kotlin.math.roundToLong

class MetadataHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAllMetadata" -> Thread { getAllMetadata(call, MethodResultWrapper(result)) }.start()
            "getCatalogMetadata" -> Thread { getCatalogMetadata(call, MethodResultWrapper(result)) }.start()
            "getOverlayMetadata" -> Thread { getOverlayMetadata(call, MethodResultWrapper(result)) }.start()
            "getContentResolverMetadata" -> Thread { getContentResolverMetadata(call, MethodResultWrapper(result)) }.start()
            "getExifInterfaceMetadata" -> Thread { getExifInterfaceMetadata(call, MethodResultWrapper(result)) }.start()
            "getMediaMetadataRetrieverMetadata" -> Thread { getMediaMetadataRetrieverMetadata(call, MethodResultWrapper(result)) }.start()
            "getEmbeddedPictures" -> Thread { getEmbeddedPictures(call, MethodResultWrapper(result)) }.start()
            "getExifThumbnails" -> Thread { getExifThumbnails(call, MethodResultWrapper(result)) }.start()
            "getXmpThumbnails" -> Thread { getXmpThumbnails(call, MethodResultWrapper(result)) }.start()
            else -> result.notImplemented()
        }
    }

    private fun getAllMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = Uri.parse(call.argument("uri"))
        if (mimeType == null || uri == null) {
            result.error("getAllMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, MutableMap<String, String>>()
        var foundExif = false
        var foundXmp = false

        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                StorageUtils.openInputStream(context, uri).use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    foundExif = metadata.containsDirectoryOfType(ExifDirectoryBase::class.java)
                    foundXmp = metadata.containsDirectoryOfType(XmpDirectory::class.java)

                    for (dir in metadata.directories.filter { it.tagCount > 0 && it !is FileTypeDirectory }) {
                        // directory name
                        val dirName = dir.name ?: ""
                        val dirMap = metadataMap.getOrDefault(dirName, HashMap())
                        metadataMap[dirName] = dirMap

                        // tags
                        dirMap.putAll(dir.tags.map { Pair(it.tagName, it.description) })
                        if (dir is XmpDirectory) {
                            try {
                                val xmpMeta = dir.xmpMeta.apply { sort() }
                                for (prop in xmpMeta) {
                                    if (prop is XMPPropertyInfo) {
                                        val path = prop.path
                                        val value = prop.value
                                        if (path?.isNotEmpty() == true && value?.isNotEmpty() == true) {
                                            dirMap[path] = value
                                        }
                                    }
                                }
                            } catch (e: XMPException) {
                                Log.w(LOG_TAG, "failed to read XMP directory for uri=$uri", e)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            }
        }

        if (!foundExif) {
            // fallback to read EXIF via ExifInterface
            try {
                StorageUtils.openInputStream(context, uri).use { input ->
                    val allTags = describeAll(ExifInterface(input)).toMutableMap()
                    if (foundXmp) {
                        // do not overwrite XMP parsed by metadata-extractor
                        // with raw XMP found by ExifInterface
                        allTags.remove(Metadata.DIR_XMP)
                    }
                    metadataMap.putAll(allTags.mapValues { it.value.toMutableMap() })
                }
            } catch (e: IOException) {
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for uri=$uri", e)
            }
        }

        val mediaDir = getAllMetadataByMediaMetadataRetriever(uri)
        if (mediaDir.isNotEmpty()) {
            metadataMap[Metadata.DIR_MEDIA] = mediaDir
        }

        if (metadataMap.isNotEmpty()) {
            result.success(metadataMap)
        } else {
            result.error("getAllMetadata-failure", "failed to get metadata for uri=$uri", null)
        }
    }

    private fun getAllMetadataByMediaMetadataRetriever(uri: Uri): MutableMap<String, String> {
        val dirMap = HashMap<String, String>()
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return dirMap
        try {
            for ((code, name) in MediaMetadataRetrieverHelper.allKeys) {
                retriever.getSafeDescription(code, context) { dirMap[name] = it }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get video metadata by MediaMetadataRetriever for uri=$uri", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
        return dirMap
    }

    private fun getCatalogMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = Uri.parse(call.argument("uri"))
        val extension = call.argument<String>("extension")
        if (mimeType == null || uri == null) {
            result.error("getCatalogMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap(getCatalogMetadataByMetadataExtractor(uri, mimeType, extension))
        if (isVideo(mimeType)) {
            metadataMap.putAll(getVideoCatalogMetadataByMediaMetadataRetriever(uri))
        }

        // report success even when empty
        result.success(metadataMap)
    }

    private fun getCatalogMetadataByMetadataExtractor(uri: Uri, mimeType: String, extension: String?): Map<String, Any> {
        val metadataMap = HashMap<String, Any>()

        var foundExif = false

        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                StorageUtils.openInputStream(context, uri).use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    foundExif = metadata.containsDirectoryOfType(ExifDirectoryBase::class.java)

                    // File type
                    for (dir in metadata.getDirectoriesOfType(FileTypeDirectory::class.java)) {
                        // `metadata-extractor` sometimes detect the the wrong mime type (e.g. `pef` file as `tiff`)
                        // the content resolver / media store sometimes report the wrong mime type (e.g. `png` file as `jpeg`)
                        // `context.getContentResolver().getType()` sometimes return incorrect value
                        // `MediaMetadataRetriever.setDataSource()` sometimes fail with `status = 0x80000000`
                        if (dir.containsTag(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)) {
                            val detectedMimeType = dir.getString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)
                            if (detectedMimeType != null && detectedMimeType != mimeType) {
                                // file extension is unreliable, but we use it as a tie breaker
                                val extensionMimeType = extension?.toLowerCase(Locale.ROOT)?.let { getMimeTypeForExtension(it) }
                                if (extensionMimeType == null || detectedMimeType == extensionMimeType) {
                                    metadataMap[KEY_MIME_TYPE] = detectedMimeType
                                }
                            }
                        }
                    }

                    // EXIF
                    for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                        dir.getSafeDateMillis(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL) { metadataMap[KEY_DATE_MILLIS] = it }
                    }
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                            dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME) { metadataMap[KEY_DATE_MILLIS] = it }
                        }
                        dir.getSafeInt(ExifIFD0Directory.TAG_ORIENTATION) {
                            val orientation = it
                            metadataMap[KEY_IS_FLIPPED] = isFlippedForExifCode(orientation)
                            metadataMap[KEY_ROTATION_DEGREES] = getRotationDegreesForExifCode(orientation)
                        }
                    }

                    // GPS
                    for (dir in metadata.getDirectoriesOfType(GpsDirectory::class.java)) {
                        val geoLocation = dir.geoLocation
                        if (geoLocation != null) {
                            metadataMap[KEY_LATITUDE] = geoLocation.latitude
                            metadataMap[KEY_LONGITUDE] = geoLocation.longitude
                        }
                    }

                    // XMP
                    for (dir in metadata.getDirectoriesOfType(XmpDirectory::class.java)) {
                        val xmpMeta = dir.xmpMeta
                        try {
                            if (xmpMeta.doesPropertyExist(XMP.DC_SCHEMA_NS, XMP.SUBJECT_PROP_NAME)) {
                                val count = xmpMeta.countArrayItems(XMP.DC_SCHEMA_NS, XMP.SUBJECT_PROP_NAME)
                                val values = (1 until count + 1).map { xmpMeta.getArrayItem(XMP.DC_SCHEMA_NS, XMP.SUBJECT_PROP_NAME, it).value }
                                metadataMap[KEY_XMP_SUBJECTS] = values.joinToString(separator = ";")
                            }
                            xmpMeta.getSafeLocalizedText(XMP.TITLE_PROP_NAME) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            if (!metadataMap.containsKey(KEY_XMP_TITLE_DESCRIPTION)) {
                                xmpMeta.getSafeLocalizedText(XMP.DESCRIPTION_PROP_NAME) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            }
                        } catch (e: XMPException) {
                            Log.w(LOG_TAG, "failed to read XMP directory for uri=$uri", e)
                        }
                    }

                    // Animated GIF & WEBP
                    when (mimeType) {
                        MimeTypes.GIF -> {
                            metadataMap[KEY_IS_ANIMATED] = metadata.containsDirectoryOfType(GifAnimationDirectory::class.java)
                        }
                        MimeTypes.WEBP -> {
                            for (dir in metadata.getDirectoriesOfType(WebpDirectory::class.java)) {
                                dir.getSafeBoolean(WebpDirectory.TAG_IS_ANIMATION) { metadataMap[KEY_IS_ANIMATED] = it }
                            }
                        }
                        else -> {
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get catalog metadata by metadata-extractor for uri=$uri, mimeType=$mimeType", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to get catalog metadata by metadata-extractor for uri=$uri, mimeType=$mimeType", e)
            }
        }

        if (!foundExif) {
            // fallback to read EXIF via ExifInterface
            try {
                StorageUtils.openInputStream(context, uri).use { input ->
                    val exif = ExifInterface(input)
                    exif.getSafeDateMillis(ExifInterface.TAG_DATETIME_ORIGINAL) { metadataMap[KEY_DATE_MILLIS] = it }
                    if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                        exif.getSafeDateMillis(ExifInterface.TAG_DATETIME) { metadataMap[KEY_DATE_MILLIS] = it }
                    }
                    exif.getSafeInt(ExifInterface.TAG_ORIENTATION, acceptZero = false) {
                        metadataMap[KEY_IS_FLIPPED] = exif.isFlipped
                        metadataMap[KEY_ROTATION_DEGREES] = exif.rotationDegrees
                    }
                    val latLong = exif.latLong
                    if (latLong != null && latLong.size == 2) {
                        metadataMap[KEY_LATITUDE] = latLong[0]
                        metadataMap[KEY_LONGITUDE] = latLong[1]
                    }
                }
            } catch (e: IOException) {
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for uri=$uri", e)
            }
        }
        return metadataMap
    }

    private fun getVideoCatalogMetadataByMediaMetadataRetriever(uri: Uri): Map<String, Any> {
        val metadataMap = HashMap<String, Any>()
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return metadataMap
        try {
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { metadataMap[KEY_ROTATION_DEGREES] = it }

            val dateString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE)
            if (dateString != null) {
                val dateMillis = parseVideoMetadataDate(dateString)
                // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
                if (dateMillis > 0) {
                    metadataMap[KEY_DATE_MILLIS] = dateMillis
                }
            }

            val locationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_LOCATION)
            if (locationString != null) {
                val locationMatcher = Metadata.VIDEO_LOCATION_PATTERN.matcher(locationString)
                if (locationMatcher.find() && locationMatcher.groupCount() >= 2) {
                    val latitudeString = locationMatcher.group(1)
                    val longitudeString = locationMatcher.group(2)
                    if (latitudeString != null && longitudeString != null) {
                        try {
                            val latitude = latitudeString.toDoubleOrNull() ?: 0
                            val longitude = longitudeString.toDoubleOrNull() ?: 0
                            // keep `0.0` as `0.0`, not `0`
                            if (latitude != 0.0 || longitude != 0.0) {
                                metadataMap[KEY_LATITUDE] = latitude
                                metadataMap[KEY_LONGITUDE] = longitude
                            }
                        } catch (e: NumberFormatException) {
                            // ignore
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get catalog metadata by MediaMetadataRetriever for uri=$uri", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
        return metadataMap
    }

    private fun getOverlayMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = Uri.parse(call.argument("uri"))
        if (mimeType == null || uri == null) {
            result.error("getOverlayMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, Any>()
        if (isVideo(mimeType) || !isSupportedByMetadataExtractor(mimeType)) {
            result.success(metadataMap)
            return
        }
        try {
            StorageUtils.openInputStream(context, uri).use { input ->
                val metadata = ImageMetadataReader.readMetadata(input)
                for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                    dir.getSafeDescription(ExifSubIFDDirectory.TAG_FNUMBER) { metadataMap[KEY_APERTURE] = it }
                    dir.getSafeDescription(ExifSubIFDDirectory.TAG_FOCAL_LENGTH) { metadataMap[KEY_FOCAL_LENGTH] = it }
                    dir.getSafeDescription(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT) { metadataMap[KEY_ISO] = "ISO$it" }
                    dir.getSafeRational(ExifSubIFDDirectory.TAG_EXPOSURE_TIME) {
                        // TAG_EXPOSURE_TIME as a string is sometimes a ratio, sometimes a decimal
                        // so we explicitly request it as a rational (e.g. 1/100, 1/14, 71428571/1000000000, 4000/1000, 2000000000/500000000)
                        // and process it to make sure the numerator is `1` when the ratio value is less than 1
                        val num = it.numerator
                        val denom = it.denominator
                        metadataMap[KEY_EXPOSURE_TIME] = when {
                            num >= denom -> it.toSimpleString(true) + "″"
                            num != 1L && num != 0L -> Rational(1, (denom / num.toDouble()).roundToLong()).toString()
                            else -> it.toString()
                        }
                    }
                }
                result.success(metadataMap)
            }
        } catch (e: Exception) {
            result.error("getOverlayMetadata-exception", "failed to get metadata for uri=$uri", e.message)
        } catch (e: NoClassDefFoundError) {
            result.error("getOverlayMetadata-exception", "failed to get metadata for uri=$uri", e.message)
        }
    }

    private fun getContentResolverMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = Uri.parse(call.argument("uri"))
        if (mimeType == null || uri == null) {
            result.error("getContentResolverMetadata-args", "failed because of missing arguments", null)
            return
        }

        val id = ContentUris.parseId(uri)
        var contentUri = when {
            isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
            isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
            else -> uri
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            contentUri = MediaStore.setRequireOriginal(contentUri)
        }

        val cursor = context.contentResolver.query(contentUri, null, null, null, null)
        if (cursor != null && cursor.moveToFirst()) {
            val metadataMap = HashMap<String, Any?>()
            val columnCount = cursor.columnCount
            val columnNames = cursor.columnNames
            for (i in 0 until columnCount) {
                val key = columnNames[i]
                try {
                    metadataMap[key] = when (cursor.getType(i)) {
                        Cursor.FIELD_TYPE_NULL -> null
                        Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(i)
                        Cursor.FIELD_TYPE_FLOAT -> cursor.getFloat(i)
                        Cursor.FIELD_TYPE_STRING -> cursor.getString(i)
                        Cursor.FIELD_TYPE_BLOB -> cursor.getBlob(i)
                        else -> null
                    }
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to get value for key=$key", e)
                }
            }
            cursor.close()
            result.success(metadataMap)
        } else {
            result.error("getContentResolverMetadata-null", "failed to get cursor for contentUri=$contentUri", null)
        }
    }

    private fun getExifInterfaceMetadata(call: MethodCall, result: MethodChannel.Result) {
        val uri = Uri.parse(call.argument("uri"))
        if (uri == null) {
            result.error("getExifInterfaceMetadata-args", "failed because of missing arguments", null)
            return
        }

        try {
            StorageUtils.openInputStream(context, uri).use { input ->
                val exif = ExifInterface(input)
                val metadataMap = HashMap<String, String?>()
                for (tag in ExifInterfaceHelper.allTags.keys.filter { exif.hasAttribute(it) }) {
                    metadataMap[tag] = exif.getAttribute(tag)
                }
                result.success(metadataMap)
            }
        } catch (e: IOException) {
            result.error("getExifInterfaceMetadata-failure", "failed to get exif for uri=$uri", e.message)
        }
    }

    private fun getMediaMetadataRetrieverMetadata(call: MethodCall, result: MethodChannel.Result) {
        val uri = Uri.parse(call.argument("uri"))
        if (uri == null) {
            result.error("getMediaMetadataRetrieverMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        val retriever = StorageUtils.openMetadataRetriever(context, uri)
        if (retriever != null) {
            try {
                for ((code, name) in MediaMetadataRetrieverHelper.allKeys) {
                    retriever.extractMetadata(code)?.let { metadataMap[name] = it }
                }
            } catch (e: Exception) {
                // ignore
            } finally {
                // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                retriever.release()
            }
        }
        result.success(metadataMap)
    }

    private fun getEmbeddedPictures(call: MethodCall, result: MethodChannel.Result) {
        val uri = Uri.parse(call.argument("uri"))
        if (uri == null) {
            result.error("getEmbeddedPictures-args", "failed because of missing arguments", null)
            return
        }

        val pictures = ArrayList<ByteArray>()
        val retriever = StorageUtils.openMetadataRetriever(context, uri)
        if (retriever != null) {
            try {
                retriever.embeddedPicture?.let { pictures.add(it) }
            } catch (e: Exception) {
                // ignore
            } finally {
                // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                retriever.release()
            }
        }
        result.success(pictures)
    }

    private fun getExifThumbnails(call: MethodCall, result: MethodChannel.Result) {
        val uri = Uri.parse(call.argument("uri"))
        if (uri == null) {
            result.error("getExifThumbnails-args", "failed because of missing arguments", null)
            return
        }

        val thumbnails = ArrayList<ByteArray>()
        try {
            StorageUtils.openInputStream(context, uri).use { input ->
                ExifInterface(input).thumbnailBytes?.let { thumbnails.add(it) }
            }
        } catch (e: IOException) {
            // ignore
        }
        result.success(thumbnails)
    }

    private fun getXmpThumbnails(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = Uri.parse(call.argument("uri"))
        if (mimeType == null || uri == null) {
            result.error("getXmpThumbnails-args", "failed because of missing arguments", null)
            return
        }

        val thumbnails = ArrayList<ByteArray>()
        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                StorageUtils.openInputStream(context, uri).use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    for (dir in metadata.getDirectoriesOfType(XmpDirectory::class.java)) {
                        val xmpMeta = dir.xmpMeta
                        try {
                            if (xmpMeta.doesPropertyExist(XMP.XMP_SCHEMA_NS, XMP.THUMBNAIL_PROP_NAME)) {
                                val count = xmpMeta.countArrayItems(XMP.XMP_SCHEMA_NS, XMP.THUMBNAIL_PROP_NAME)
                                for (i in 1 until count + 1) {
                                    val structName = "${XMP.THUMBNAIL_PROP_NAME}[$i]"
                                    val image = xmpMeta.getStructField(XMP.XMP_SCHEMA_NS, structName, XMP.IMG_SCHEMA_NS, XMP.THUMBNAIL_IMAGE_PROP_NAME)
                                    if (image != null) {
                                        thumbnails.add(XMPUtils.decodeBase64(image.value))
                                    }
                                }
                            }
                        } catch (e: XMPException) {
                            Log.w(LOG_TAG, "failed to read XMP directory for uri=$uri", e)
                        }
                    }
                }
            } catch (e: IOException) {
                Log.w(LOG_TAG, "failed to extract xmp thumbnail", e)
            } catch (e: ImageProcessingException) {
                Log.w(LOG_TAG, "failed to extract xmp thumbnail", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to extract xmp thumbnail", e)
            }
        }
        result.success(thumbnails)
    }

    companion object {
        private val LOG_TAG = Utils.createLogTag(MetadataHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/metadata"

        // catalog metadata
        private const val KEY_MIME_TYPE = "mimeType"
        private const val KEY_DATE_MILLIS = "dateMillis"
        private const val KEY_IS_ANIMATED = "isAnimated"
        private const val KEY_IS_FLIPPED = "isFlipped"
        private const val KEY_ROTATION_DEGREES = "rotationDegrees"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
        private const val KEY_XMP_SUBJECTS = "xmpSubjects"
        private const val KEY_XMP_TITLE_DESCRIPTION = "xmpTitleDescription"

        // overlay metadata
        private const val KEY_APERTURE = "aperture"
        private const val KEY_EXPOSURE_TIME = "exposureTime"
        private const val KEY_FOCAL_LENGTH = "focalLength"
        private const val KEY_ISO = "iso"
    }
}