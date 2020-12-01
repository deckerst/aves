package deckers.thibault.aves.channel.calls

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPUtils
import com.adobe.internal.xmp.properties.XMPPropertyInfo
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import com.drew.imaging.ImageMetadataReader
import com.drew.lang.Rational
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
import com.drew.metadata.file.FileTypeDirectory
import com.drew.metadata.gif.GifAnimationDirectory
import com.drew.metadata.webp.WebpDirectory
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.metadata.ExifInterfaceHelper
import deckers.thibault.aves.metadata.ExifInterfaceHelper.describeAll
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDouble
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeRational
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDescription
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.metadata.Metadata.isFlippedForExifCode
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeBoolean
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeRational
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeString
import deckers.thibault.aves.metadata.XMP
import deckers.thibault.aves.metadata.XMP.getSafeDateMillis
import deckers.thibault.aves.metadata.XMP.getSafeLocalizedText
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isMultimedia
import deckers.thibault.aves.utils.MimeTypes.isSupportedByExifInterface
import deckers.thibault.aves.utils.MimeTypes.isSupportedByMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.tiffExtensionPattern
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.IOException
import java.util.*
import kotlin.math.roundToLong

class MetadataHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAllMetadata" -> GlobalScope.launch { getAllMetadata(call, Coresult(result)) }
            "getCatalogMetadata" -> GlobalScope.launch { getCatalogMetadata(call, Coresult(result)) }
            "getOverlayMetadata" -> GlobalScope.launch { getOverlayMetadata(call, Coresult(result)) }
            "getContentResolverMetadata" -> GlobalScope.launch { getContentResolverMetadata(call, Coresult(result)) }
            "getExifInterfaceMetadata" -> GlobalScope.launch { getExifInterfaceMetadata(call, Coresult(result)) }
            "getMediaMetadataRetrieverMetadata" -> GlobalScope.launch { getMediaMetadataRetrieverMetadata(call, Coresult(result)) }
            "getBitmapFactoryInfo" -> GlobalScope.launch { getBitmapFactoryInfo(call, Coresult(result)) }
            "getMetadataExtractorSummary" -> GlobalScope.launch { getMetadataExtractorSummary(call, Coresult(result)) }
            "getEmbeddedPictures" -> GlobalScope.launch { getEmbeddedPictures(call, Coresult(result)) }
            "getExifThumbnails" -> GlobalScope.launch { getExifThumbnails(call, Coresult(result)) }
            "getXmpThumbnails" -> GlobalScope.launch { getXmpThumbnails(call, Coresult(result)) }
            else -> result.notImplemented()
        }
    }

    private fun getAllMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getAllMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, MutableMap<String, String>>()
        var foundExif = false
        var foundXmp = false

        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
                    foundExif = metadata.containsDirectoryOfType(ExifDirectoryBase::class.java)
                    foundXmp = metadata.containsDirectoryOfType(XmpDirectory::class.java)

                    for (dir in metadata.directories.filter { it.tagCount > 0 && it !is FileTypeDirectory }) {
                        // directory name
                        var dirName = dir.name
                        // optional parent to distinguish child directories of the same type
                        dir.parent?.name?.let { dirName = "$it/$dirName" }

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

        if (!foundExif && isSupportedByExifInterface(mimeType, sizeBytes)) {
            // fallback to read EXIF via ExifInterface
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val exif = ExifInterface(input)
                    val allTags = describeAll(exif).toMutableMap()
                    if (foundXmp) {
                        // do not overwrite XMP parsed by metadata-extractor
                        // with raw XMP found by ExifInterface
                        allTags.remove(Metadata.DIR_XMP)
                    }
                    metadataMap.putAll(allTags.mapValues { it.value.toMutableMap() })
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for uri=$uri", e)
            }
        }

        if (isMultimedia(mimeType)) {
            val mediaDir = getAllMetadataByMediaMetadataRetriever(uri)
            if (mediaDir.isNotEmpty()) {
                metadataMap[Metadata.DIR_MEDIA] = mediaDir
            }
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
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val path = call.argument<String>("path")
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getCatalogMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap(getCatalogMetadataByMetadataExtractor(uri, mimeType, path, sizeBytes))
        if (isVideo(mimeType)) {
            metadataMap.putAll(getVideoCatalogMetadataByMediaMetadataRetriever(uri))
        }

        // report success even when empty
        result.success(metadataMap)
    }

    // set `KEY_DATE_MILLIS` from these fields (by precedence):
    // - Exif / DATETIME_ORIGINAL
    // - Exif / DATETIME
    // - XMP / xmp:CreateDate
    // set `KEY_XMP_TITLE_DESCRIPTION` from these fields (by precedence):
    // - XMP / dc:title
    // - XMP / dc:description
    private fun getCatalogMetadataByMetadataExtractor(uri: Uri, mimeType: String, path: String?, sizeBytes: Long?): Map<String, Any> {
        val metadataMap = HashMap<String, Any>()

        var foundExif = false

        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
                    foundExif = metadata.containsDirectoryOfType(ExifDirectoryBase::class.java)

                    // File type
                    for (dir in metadata.getDirectoriesOfType(FileTypeDirectory::class.java)) {
                        // * `metadata-extractor` sometimes detect the the wrong mime type (e.g. `pef` file as `tiff`)
                        // * the content resolver / media store sometimes report the wrong mime type (e.g. `png` file as `jpeg`, `tiff` as `srw`)
                        // * `context.getContentResolver().getType()` sometimes return incorrect value
                        // * `MediaMetadataRetriever.setDataSource()` sometimes fail with `status = 0x80000000`
                        // * file extension is unreliable
                        // In the end, `metadata-extractor` is the most reliable, except for `tiff` (false positives, false negatives),
                        // in which case we trust the file extension
                        // cf https://github.com/drewnoakes/metadata-extractor/issues/296
                        if (path?.matches(tiffExtensionPattern) == true) {
                            metadataMap[KEY_MIME_TYPE] = MimeTypes.TIFF
                        } else {
                            dir.getSafeString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE) {
                                if (it != MimeTypes.TIFF) {
                                    metadataMap[KEY_MIME_TYPE] = it
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
                            xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.TITLE_PROP_NAME) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            if (!metadataMap.containsKey(KEY_XMP_TITLE_DESCRIPTION)) {
                                xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.DESCRIPTION_PROP_NAME) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            }
                            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                xmpMeta.getSafeDateMillis(XMP.XMP_SCHEMA_NS, XMP.CREATE_DATE_PROP_NAME) { metadataMap[KEY_DATE_MILLIS] = it }
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

        if (!foundExif && isSupportedByExifInterface(mimeType, sizeBytes)) {
            // fallback to read EXIF via ExifInterface
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
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
                    if (latLong?.size == 2) {
                        metadataMap[KEY_LATITUDE] = latLong[0]
                        metadataMap[KEY_LONGITUDE] = latLong[1]
                    }
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
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
            retriever.getSafeDateMillis(MediaMetadataRetriever.METADATA_KEY_DATE) { metadataMap[KEY_DATE_MILLIS] = it }

            val locationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_LOCATION)
            if (locationString != null) {
                val matcher = Metadata.VIDEO_LOCATION_PATTERN.matcher(locationString)
                if (matcher.find() && matcher.groupCount() >= 2) {
                    val latitude = matcher.group(1)?.toDoubleOrNull()
                    val longitude = matcher.group(2)?.toDoubleOrNull()
                    if (latitude != null && longitude != null) {
                        metadataMap[KEY_LATITUDE] = latitude
                        metadataMap[KEY_LONGITUDE] = longitude
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
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getOverlayMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, Any>()
        if (isVideo(mimeType)) {
            result.success(metadataMap)
            return
        }

        val saveExposureTime: (value: Rational) -> Unit = {
            // `TAG_EXPOSURE_TIME` as a string is sometimes a ratio, sometimes a decimal
            // so we explicitly request it as a rational (e.g. 1/100, 1/14, 71428571/1000000000, 4000/1000, 2000000000/500000000)
            // and process it to make sure the numerator is `1` when the ratio value is less than 1
            val num = it.numerator
            val denom = it.denominator
            metadataMap[KEY_EXPOSURE_TIME] = when {
                num >= denom -> "${it.toSimpleString(true)}″"
                num != 1L && num != 0L -> Rational(1, (denom / num.toDouble()).roundToLong()).toString()
                else -> it.toString()
            }
        }

        var foundExif = false
        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
                    for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                        foundExif = true
                        dir.getSafeRational(ExifSubIFDDirectory.TAG_FNUMBER) { metadataMap[KEY_APERTURE] = it.numerator.toDouble() / it.denominator }
                        dir.getSafeRational(ExifSubIFDDirectory.TAG_EXPOSURE_TIME, saveExposureTime)
                        dir.getSafeRational(ExifSubIFDDirectory.TAG_FOCAL_LENGTH) { metadataMap[KEY_FOCAL_LENGTH] = it.numerator.toDouble() / it.denominator }
                        dir.getSafeInt(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT) { metadataMap[KEY_ISO] = it }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            }
        }

        if (!foundExif && isSupportedByExifInterface(mimeType, sizeBytes)) {
            // fallback to read EXIF via ExifInterface
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val exif = ExifInterface(input)
                    exif.getSafeDouble(ExifInterface.TAG_F_NUMBER) { metadataMap[KEY_APERTURE] = it }
                    exif.getSafeRational(ExifInterface.TAG_EXPOSURE_TIME, saveExposureTime)
                    exif.getSafeDouble(ExifInterface.TAG_FOCAL_LENGTH) { metadataMap[KEY_FOCAL_LENGTH] = it }
                    exif.getSafeInt(ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY) { metadataMap[KEY_ISO] = it }
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for uri=$uri", e)
            }
        }

        result.success(metadataMap)
    }

    private fun getContentResolverMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (mimeType == null || uri == null) {
            result.error("getContentResolverMetadata-args", "failed because of missing arguments", null)
            return
        }

        var contentUri: Uri = uri
        if (uri.scheme == ContentResolver.SCHEME_CONTENT && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)) {
            try {
                val id = ContentUris.parseId(uri)
                contentUri = when {
                    isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    else -> uri
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    contentUri = MediaStore.setRequireOriginal(contentUri)
                }
            } catch (e: NumberFormatException) {
                // ignore
            }
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
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getExifInterfaceMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String?>()
        if (isSupportedByExifInterface(mimeType, sizeBytes, strict = false)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val exif = ExifInterface(input)
                    for (tag in ExifInterfaceHelper.allTags.keys.filter { exif.hasAttribute(it) }) {
                        metadataMap[tag] = exif.getAttribute(tag)
                    }
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                result.error("getExifInterfaceMetadata-failure", "failed to get exif for uri=$uri", e.message)
                return
            }
        }
        result.success(metadataMap)
    }

    private fun getMediaMetadataRetrieverMetadata(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
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

    private fun getBitmapFactoryInfo(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (uri == null) {
            result.error("getBitmapDecoderInfo-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        try {
            StorageUtils.openInputStream(context, uri)?.use { input ->
                val options = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                BitmapFactory.decodeStream(input, null, options)
                options.outMimeType?.let { metadataMap["MimeType"] = it }
                options.outWidth.takeIf { it >= 0 }?.let { metadataMap["Width"] = it.toString() }
                options.outHeight.takeIf { it >= 0 }?.let { metadataMap["Height"] = it.toString() }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    options.outColorSpace?.let { metadataMap["ColorSpace"] = it.toString() }
                    options.outConfig?.let { metadataMap["Config"] = it.toString() }
                }
            }
        } catch (e: IOException) {
            // ignore
        }
        result.success(metadataMap)
    }

    private fun getMetadataExtractorSummary(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getMetadataExtractorSummary-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
                    metadataMap["mimeType"] = metadata.getDirectoriesOfType(FileTypeDirectory::class.java).joinToString { dir ->
                        if (dir.containsTag(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)) {
                            dir.getString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)
                        } else ""
                    }
                    metadataMap["typeName"] = metadata.getDirectoriesOfType(FileTypeDirectory::class.java).joinToString { dir ->
                        if (dir.containsTag(FileTypeDirectory.TAG_DETECTED_FILE_TYPE_NAME)) {
                            dir.getString(FileTypeDirectory.TAG_DETECTED_FILE_TYPE_NAME)
                        } else ""
                    }
                    for (dir in metadata.directories) {
                        val dirName = dir.name ?: ""
                        var index = 0
                        while (metadataMap.containsKey("$dirName ($index)")) index++
                        var value = "${dir.tagCount} tags"
                        dir.parent?.let { value += ", parent: ${it.name}" }
                        metadataMap["$dirName ($index)"] = value
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            }
        }
        result.success(metadataMap)
    }

    private fun getEmbeddedPictures(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
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
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getExifThumbnails-args", "failed because of missing arguments", null)
            return
        }

        val thumbnails = ArrayList<ByteArray>()
        if (isSupportedByExifInterface(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val exif = ExifInterface(input)
                    val orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                    exif.thumbnailBitmap?.let { bitmap ->
                        TransformationUtils.rotateImageExif(BitmapUtils.getBitmapPool(context), bitmap, orientation)?.let {
                            thumbnails.add(it.getBytes(canHaveAlpha = false, recycle = false))
                        }
                    }
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
            }
        }
        result.success(thumbnails)
    }

    private fun getXmpThumbnails(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getXmpThumbnails-args", "failed because of missing arguments", null)
            return
        }

        val thumbnails = ArrayList<ByteArray>()
        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
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
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to extract xmp thumbnail", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to extract xmp thumbnail", e)
            }
        }
        result.success(thumbnails)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag(MetadataHandler::class.java)
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