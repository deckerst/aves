package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
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
import com.drew.metadata.iptc.IptcDirectory
import com.drew.metadata.mp4.media.Mp4UuidBoxDirectory
import com.drew.metadata.webp.WebpDirectory
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.metadata.ExifInterfaceHelper.describeAll
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDouble
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeRational
import deckers.thibault.aves.metadata.Geotiff
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
import deckers.thibault.aves.metadata.MetadataExtractorHelper.isGeoTiff
import deckers.thibault.aves.metadata.XMP
import deckers.thibault.aves.metadata.XMP.getSafeDateMillis
import deckers.thibault.aves.metadata.XMP.getSafeLocalizedText
import deckers.thibault.aves.model.provider.FieldMap
import deckers.thibault.aves.model.provider.FileImageProvider
import deckers.thibault.aves.model.provider.ImageProvider
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
import java.io.File
import java.util.*
import kotlin.math.roundToLong

class MetadataHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAllMetadata" -> GlobalScope.launch { getAllMetadata(call, Coresult(result)) }
            "getCatalogMetadata" -> GlobalScope.launch { getCatalogMetadata(call, Coresult(result)) }
            "getOverlayMetadata" -> GlobalScope.launch { getOverlayMetadata(call, Coresult(result)) }
            "getEmbeddedPictures" -> GlobalScope.launch { getEmbeddedPictures(call, Coresult(result)) }
            "getExifThumbnails" -> GlobalScope.launch { getExifThumbnails(call, Coresult(result)) }
            "getXmpThumbnails" -> GlobalScope.launch { getXmpThumbnails(call, Coresult(result)) }
            "extractXmpDataProp" -> GlobalScope.launch { extractXmpDataProp(call, Coresult(result)) }
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
                        if (mimeType == MimeTypes.TIFF && dir is ExifIFD0Directory) {
                            dirMap.putAll(dir.tags.map {
                                val name = if (it.hasTagName()) {
                                    it.tagName
                                } else {
                                    Geotiff.getTagName(it.tagType) ?: it.tagName
                                }
                                Pair(name, it.description)
                            })
                        } else {
                            dirMap.putAll(dir.tags.map { Pair(it.tagName, it.description) })
                        }
                        if (dir is XmpDirectory) {
                            try {
                                for (prop in dir.xmpMeta) {
                                    if (prop is XMPPropertyInfo) {
                                        val path = prop.path
                                        if (path?.isNotEmpty() == true) {
                                            val value = if (XMP.isDataPath(path)) "[skipped]" else prop.value
                                            if (value?.isNotEmpty() == true) {
                                                dirMap[path] = value
                                            }
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
    // set `KEY_XMP_SUBJECTS` from these fields (by precedence):
    // - XMP / dc:subject
    // - IPTC / keywords
    private fun getCatalogMetadataByMetadataExtractor(uri: Uri, mimeType: String, path: String?, sizeBytes: Long?): Map<String, Any> {
        val metadataMap = HashMap<String, Any>()

        var flags = 0
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
                            if (isFlippedForExifCode(orientation)) flags = flags or MASK_IS_FLIPPED
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
                                metadataMap[KEY_XMP_SUBJECTS] = values.joinToString(separator = XMP_SUBJECTS_SEPARATOR)
                            }
                            xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.TITLE_PROP_NAME) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            if (!metadataMap.containsKey(KEY_XMP_TITLE_DESCRIPTION)) {
                                xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.DESCRIPTION_PROP_NAME) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            }
                            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                xmpMeta.getSafeDateMillis(XMP.XMP_SCHEMA_NS, XMP.CREATE_DATE_PROP_NAME) { metadataMap[KEY_DATE_MILLIS] = it }
                            }

                            // identification of panorama (aka photo sphere)
                            if (XMP.panoramaRequiredProps.all { xmpMeta.doesPropertyExist(XMP.GPANO_SCHEMA_NS, it) }) {
                                flags = flags or MASK_IS_360
                            }
                        } catch (e: XMPException) {
                            Log.w(LOG_TAG, "failed to read XMP directory for uri=$uri", e)
                        }
                    }

                    // XMP fallback to IPTC
                    if (!metadataMap.containsKey(KEY_XMP_SUBJECTS)) {
                        for (dir in metadata.getDirectoriesOfType(IptcDirectory::class.java)) {
                            dir.keywords?.let { metadataMap[KEY_XMP_SUBJECTS] = it.joinToString(separator = XMP_SUBJECTS_SEPARATOR) }
                        }
                    }

                    // identification of animated GIF & WEBP, GeoTIFF
                    when (mimeType) {
                        MimeTypes.GIF -> {
                            if (metadata.containsDirectoryOfType(GifAnimationDirectory::class.java)) flags = flags or MASK_IS_ANIMATED
                        }
                        MimeTypes.WEBP -> {
                            for (dir in metadata.getDirectoriesOfType(WebpDirectory::class.java)) {
                                dir.getSafeBoolean(WebpDirectory.TAG_IS_ANIMATION) {
                                    if (it) flags = flags or MASK_IS_ANIMATED
                                }
                            }
                        }
                        MimeTypes.TIFF -> {
                            for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                                if (dir.isGeoTiff()) flags = flags or MASK_IS_GEOTIFF
                            }
                        }
                    }

                    // identification of spherical video (aka 360° video)
                    if (metadata.getDirectoriesOfType(Mp4UuidBoxDirectory::class.java).any {
                            it.getString(Mp4UuidBoxDirectory.TAG_UUID) == Metadata.SPHERICAL_VIDEO_V1_UUID
                        }) {
                        flags = flags or MASK_IS_360
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
                        if (exif.isFlipped) flags = flags or MASK_IS_FLIPPED
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
        metadataMap[KEY_FLAGS] = flags
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

    private fun extractXmpDataProp(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val dataPropPath = call.argument<String>("propPath")
        if (mimeType == null || uri == null || dataPropPath == null) {
            result.error("extractXmpDataProp-args", "failed because of missing arguments", null)
            return
        }

        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
                    // data can be large and stored in "Extended XMP",
                    // which is returned as a second XMP directory
                    val xmpDirs = metadata.getDirectoriesOfType(XmpDirectory::class.java)
                    try {
                        val ns = XMP.namespaceForDataPath(dataPropPath)
                        val mimePropPath = XMP.mimeTypePathForDataPath(dataPropPath)
                        val embedMimeType = xmpDirs.map { it.xmpMeta.getPropertyString(ns, mimePropPath) }.first { it != null }
                        val embedBytes = xmpDirs.map { it.xmpMeta.getPropertyBase64(ns, dataPropPath) }.first { it != null }
                        val embedFile = File.createTempFile("aves", null, context.cacheDir).apply {
                            deleteOnExit()
                            outputStream().use { outputStream ->
                                embedBytes.inputStream().use { inputStream ->
                                    inputStream.copyTo(outputStream)
                                }
                            }
                        }
                        val embedUri = Uri.fromFile(embedFile)
                        val embedFields: FieldMap = hashMapOf(
                            "uri" to embedUri.toString(),
                            "mimeType" to embedMimeType,
                        )
                        if (isImage(embedMimeType) || isVideo(embedMimeType)) {
                            GlobalScope.launch {
                                FileImageProvider().fetchSingle(context, embedUri, embedMimeType, object : ImageProvider.ImageOpCallback {
                                    override fun onSuccess(fields: FieldMap) {
                                        embedFields.putAll(fields)
                                        result.success(embedFields)
                                    }

                                    override fun onFailure(throwable: Throwable) = result.error("extractXmpDataProp-failure", "failed to get entry for uri=$embedUri mime=$embedMimeType", throwable.message)
                                })
                            }
                        } else {
                            result.success(embedFields)
                        }
                        return
                    } catch (e: XMPException) {
                        result.error("extractXmpDataProp-args", "failed to read XMP directory for uri=$uri prop=$dataPropPath", e.message)
                        return
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            }
        }
        result.error("extractXmpDataProp-empty", "failed to extract file from XMP uri=$uri prop=$dataPropPath", null)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag(MetadataHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/metadata"

        // catalog metadata
        private const val KEY_MIME_TYPE = "mimeType"
        private const val KEY_DATE_MILLIS = "dateMillis"
        private const val KEY_FLAGS = "flags"
        private const val KEY_ROTATION_DEGREES = "rotationDegrees"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
        private const val KEY_XMP_SUBJECTS = "xmpSubjects"
        private const val KEY_XMP_TITLE_DESCRIPTION = "xmpTitleDescription"

        private const val MASK_IS_ANIMATED = 1 shl 0
        private const val MASK_IS_FLIPPED = 1 shl 1
        private const val MASK_IS_GEOTIFF = 1 shl 2
        private const val MASK_IS_360 = 1 shl 3
        private const val XMP_SUBJECTS_SEPARATOR = ";"

        // overlay metadata
        private const val KEY_APERTURE = "aperture"
        private const val KEY_EXPOSURE_TIME = "exposureTime"
        private const val KEY_FOCAL_LENGTH = "focalLength"
        private const val KEY_ISO = "iso"
    }
}