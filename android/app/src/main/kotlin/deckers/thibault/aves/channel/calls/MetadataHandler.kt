package deckers.thibault.aves.channel.calls

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPUtils
import com.adobe.internal.xmp.properties.XMPPropertyInfo
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import com.drew.imaging.ImageMetadataReader
import com.drew.lang.Rational
import com.drew.metadata.Tag
import com.drew.metadata.avi.AviDirectory
import com.drew.metadata.exif.*
import com.drew.metadata.file.FileTypeDirectory
import com.drew.metadata.gif.GifAnimationDirectory
import com.drew.metadata.iptc.IptcDirectory
import com.drew.metadata.mp4.media.Mp4UuidBoxDirectory
import com.drew.metadata.png.PngDirectory
import com.drew.metadata.webp.WebpDirectory
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.metadata.*
import deckers.thibault.aves.metadata.ExifInterfaceHelper.describeAll
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDouble
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeRational
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDescription
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.metadata.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.metadata.Metadata.isFlippedForExifCode
import deckers.thibault.aves.metadata.MetadataExtractorHelper.PNG_LAST_MODIFICATION_TIME_FORMAT
import deckers.thibault.aves.metadata.MetadataExtractorHelper.PNG_TIME_DIR_NAME
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeBoolean
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeRational
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeString
import deckers.thibault.aves.metadata.MetadataExtractorHelper.isGeoTiff
import deckers.thibault.aves.metadata.XMP.getSafeDateMillis
import deckers.thibault.aves.metadata.XMP.getSafeInt
import deckers.thibault.aves.metadata.XMP.getSafeLocalizedText
import deckers.thibault.aves.metadata.XMP.getSafeString
import deckers.thibault.aves.metadata.XMP.isPanorama
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.provider.FileImageProvider
import deckers.thibault.aves.model.provider.ImageProvider
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.isHeic
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isSupportedByExifInterface
import deckers.thibault.aves.utils.MimeTypes.isSupportedByMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.MimeTypes.tiffExtensionPattern
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.UriUtils.tryParseId
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.File
import java.text.ParseException
import java.util.*
import kotlin.math.roundToLong

class MetadataHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAllMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getAllMetadata) }
            "getCatalogMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getCatalogMetadata) }
            "getOverlayMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getOverlayMetadata) }
            "getMultiPageInfo" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getMultiPageInfo) }
            "getPanoramaInfo" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getPanoramaInfo) }
            "getContentResolverProp" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getContentResolverProp) }
            "getEmbeddedPictures" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getEmbeddedPictures) }
            "getExifThumbnails" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getExifThumbnails) }
            "extractXmpDataProp" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::extractXmpDataProp) }
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

        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    foundExif = metadata.containsDirectoryOfType(ExifDirectoryBase::class.java)
                    foundXmp = metadata.containsDirectoryOfType(XmpDirectory::class.java)

                    for (dir in metadata.directories.filter {
                        it.tagCount > 0
                                && it !is FileTypeDirectory
                                && it !is AviDirectory
                    }) {
                        // directory name
                        var dirName = dir.name

                        // exclude directories known to be redundant with info derived on the Dart side
                        // they are excluded by name instead of runtime type because excluding `Mp4Directory`
                        // would also exclude derived directories, such as `Mp4UuidBoxDirectory`
                        if (allMetadataRedundantDirNames.contains(dirName)) continue

                        // optional parent to distinguish child directories of the same type
                        dir.parent?.name?.let { dirName = "$it/$dirName" }

                        val dirMap = metadataMap[dirName] ?: HashMap()
                        metadataMap[dirName] = dirMap

                        // tags
                        val tags = dir.tags
                        if (mimeType == MimeTypes.TIFF && (dir is ExifIFD0Directory || dir is ExifThumbnailDirectory)) {
                            fun tagMapper(it: Tag): Pair<String, String> {
                                val name = if (it.hasTagName()) {
                                    it.tagName
                                } else {
                                    TiffTags.getTagName(it.tagType) ?: it.tagName
                                }
                                return Pair(name, it.description)
                            }

                            if (dir is ExifIFD0Directory && dir.isGeoTiff()) {
                                // split GeoTIFF tags in their own directory
                                val byGeoTiff = tags.groupBy { TiffTags.isGeoTiffTag(it.tagType) }
                                metadataMap["GeoTIFF"] = HashMap<String, String>().apply {
                                    byGeoTiff[true]?.map { tagMapper(it) }?.let { putAll(it) }
                                }
                                byGeoTiff[false]?.map { tagMapper(it) }?.let { dirMap.putAll(it) }
                            } else {
                                dirMap.putAll(tags.map { tagMapper(it) })
                            }
                        } else {
                            dirMap.putAll(tags.map { Pair(it.tagName, it.description) })
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
                            // remove this stat as it is not actual XMP data
                            dirMap.remove(dir.getTagName(XmpDirectory.TAG_XMP_VALUE_COUNT))
                        }

                        if (dir is Mp4UuidBoxDirectory) {
                            if (dir.getString(Mp4UuidBoxDirectory.TAG_UUID) == GSpherical.SPHERICAL_VIDEO_V1_UUID) {
                                val bytes = dir.getByteArray(Mp4UuidBoxDirectory.TAG_USER_DATA)
                                metadataMap["Spherical Video"] = HashMap(GSpherical(bytes).describe())
                                metadataMap.remove(dirName)
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

        if (!foundExif && isSupportedByExifInterface(mimeType)) {
            // fallback to read EXIF via ExifInterface
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
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

        if (isVideo(mimeType)) {
            // this is used as fallback when the video metadata cannot be found on the Dart side
            // do not include HEIC here
            val mediaDir = getAllMetadataByMediaMetadataRetriever(uri)
            if (mediaDir.isNotEmpty()) {
                metadataMap[Metadata.DIR_MEDIA] = mediaDir
            }
            // Android's `MediaExtractor` and `MediaPlayer` cannot be used for details
            // about embedded images as they do not list them as separate tracks
            // and only identify at most one
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
                retriever.getSafeDescription(code) { dirMap[name] = it }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get video metadata by MediaMetadataRetriever for uri=$uri", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
        return dirMap
    }

    // legend: ME=MetadataExtractor, EI=ExifInterface, MMR=MediaMetadataRetriever
    // set `KEY_DATE_MILLIS` from these fields (by precedence):
    // - ME / Exif / DATETIME_ORIGINAL
    // - ME / Exif / DATETIME
    // - EI / Exif / DATETIME_ORIGINAL
    // - EI / Exif / DATETIME
    // - ME / XMP / xmp:CreateDate
    // - ME / XMP / photoshop:DateCreated
    // - ME / PNG / TIME / LAST_MODIFICATION_TIME
    // - MMR / METADATA_KEY_DATE
    // set `KEY_XMP_TITLE_DESCRIPTION` from these fields (by precedence):
    // - ME / XMP / dc:title
    // - ME / XMP / dc:description
    // set `KEY_XMP_SUBJECTS` from these fields (by precedence):
    // - ME / XMP / dc:subject
    // - ME / IPTC / keywords
    private fun getCatalogMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val path = call.argument<String>("path")
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getCatalogMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, Any>()
        getCatalogMetadataByMetadataExtractor(uri, mimeType, path, sizeBytes, metadataMap)
        if (isVideo(mimeType) || isHeic(mimeType)) {
            getMultimediaCatalogMetadataByMediaMetadataRetriever(uri, mimeType, metadataMap)
        }

        // report success even when empty
        result.success(metadataMap)
    }

    private fun getCatalogMetadataByMetadataExtractor(
        uri: Uri,
        mimeType: String,
        path: String?,
        sizeBytes: Long?,
        metadataMap: HashMap<String, Any>,
    ) {
        var flags = (metadataMap[KEY_FLAGS] ?: 0) as Int
        var foundExif = false

        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
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
                                metadataMap[KEY_XMP_SUBJECTS] = values.joinToString(XMP_SUBJECTS_SEPARATOR)
                            }
                            xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.TITLE_PROP_NAME, acceptBlank = false) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            if (!metadataMap.containsKey(KEY_XMP_TITLE_DESCRIPTION)) {
                                xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.DESCRIPTION_PROP_NAME, acceptBlank = false) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            }
                            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                xmpMeta.getSafeDateMillis(XMP.XMP_SCHEMA_NS, XMP.CREATE_DATE_PROP_NAME) { metadataMap[KEY_DATE_MILLIS] = it }
                                if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                    xmpMeta.getSafeDateMillis(XMP.PHOTOSHOP_SCHEMA_NS, XMP.PS_DATE_CREATED_PROP_NAME) { metadataMap[KEY_DATE_MILLIS] = it }
                                }
                            }

                            // identification of panorama (aka photo sphere)
                            if (xmpMeta.isPanorama()) {
                                flags = flags or MASK_IS_360
                            }
                        } catch (e: XMPException) {
                            Log.w(LOG_TAG, "failed to read XMP directory for uri=$uri", e)
                        }
                    }

                    // XMP fallback to IPTC
                    if (!metadataMap.containsKey(KEY_XMP_SUBJECTS)) {
                        for (dir in metadata.getDirectoriesOfType(IptcDirectory::class.java)) {
                            dir.keywords?.let { metadataMap[KEY_XMP_SUBJECTS] = it.joinToString(XMP_SUBJECTS_SEPARATOR) }
                        }
                    }

                    when (mimeType) {
                        MimeTypes.PNG -> {
                            // date fallback to PNG time chunk
                            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                for (dir in metadata.getDirectoriesOfType(PngDirectory::class.java).filter { it.name == PNG_TIME_DIR_NAME }) {
                                    dir.getSafeString(PngDirectory.TAG_LAST_MODIFICATION_TIME) {
                                        try {
                                            PNG_LAST_MODIFICATION_TIME_FORMAT.parse(it)?.let { date ->
                                                metadataMap[KEY_DATE_MILLIS] = date.time
                                            }
                                        } catch (e: ParseException) {
                                            Log.w(LOG_TAG, "failed to parse PNG date=$it for uri=$uri", e)
                                        }
                                    }
                                }
                            }
                        }
                        MimeTypes.GIF -> {
                            // identification of animated GIF
                            if (metadata.containsDirectoryOfType(GifAnimationDirectory::class.java)) flags = flags or MASK_IS_ANIMATED
                        }
                        MimeTypes.WEBP -> {
                            // identification of animated WEBP
                            for (dir in metadata.getDirectoriesOfType(WebpDirectory::class.java)) {
                                dir.getSafeBoolean(WebpDirectory.TAG_IS_ANIMATION) {
                                    if (it) flags = flags or MASK_IS_ANIMATED
                                }
                            }
                        }
                        MimeTypes.TIFF -> {
                            // identification of GeoTIFF
                            for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                                if (dir.isGeoTiff()) flags = flags or MASK_IS_GEOTIFF
                            }
                        }
                    }

                    // identification of spherical video (aka 360° video)
                    if (metadata.getDirectoriesOfType(Mp4UuidBoxDirectory::class.java).any {
                            it.getString(Mp4UuidBoxDirectory.TAG_UUID) == GSpherical.SPHERICAL_VIDEO_V1_UUID
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

        if (!foundExif && isSupportedByExifInterface(mimeType)) {
            // fallback to read EXIF via ExifInterface
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
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

        if (mimeType == MimeTypes.TIFF && isMultiPageTiff(uri)) flags = flags or MASK_IS_MULTIPAGE

        metadataMap[KEY_FLAGS] = flags
    }

    private fun getMultimediaCatalogMetadataByMediaMetadataRetriever(
        uri: Uri,
        mimeType: String,
        metadataMap: HashMap<String, Any>,
    ) {
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return

        var flags = (metadataMap[KEY_FLAGS] ?: 0) as Int
        try {
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { metadataMap[KEY_ROTATION_DEGREES] = it }
            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                retriever.getSafeDateMillis(MediaMetadataRetriever.METADATA_KEY_DATE) { metadataMap[KEY_DATE_MILLIS] = it }
            }

            if (!metadataMap.containsKey(KEY_LATITUDE)) {
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
            }

            if (isHeic(mimeType)) {
                retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS) {
                    if (it > 1) flags = flags or MASK_IS_MULTIPAGE
                }
            }

            metadataMap[KEY_FLAGS] = flags
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get catalog metadata by MediaMetadataRetriever for uri=$uri", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
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
        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
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

        if (!foundExif && isSupportedByExifInterface(mimeType)) {
            // fallback to read EXIF via ExifInterface
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
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

    private fun getMultiPageInfo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (mimeType == null || uri == null) {
            result.error("getMultiPageInfo-args", "failed because of missing arguments", null)
            return
        }

        val pages = ArrayList<Map<String, Any>>()
        if (mimeType == MimeTypes.TIFF) {
            fun toMap(page: Int, options: TiffBitmapFactory.Options): HashMap<String, Any> {
                return hashMapOf(
                    KEY_PAGE to page,
                    KEY_MIME_TYPE to mimeType,
                    KEY_WIDTH to options.outWidth,
                    KEY_HEIGHT to options.outHeight,
                )
            }
            getTiffPageInfo(uri, 0)?.let { first ->
                pages.add(toMap(0, first))
                val pageCount = first.outDirectoryCount
                for (i in 1 until pageCount) {
                    getTiffPageInfo(uri, i)?.let { pages.add(toMap(i, it)) }
                }
            }
        } else if (isHeic(mimeType)) {
            fun MediaFormat.getSafeInt(key: String, save: (value: Int) -> Unit) {
                if (this.containsKey(key)) save(this.getInteger(key))
            }

            fun MediaFormat.getSafeLong(key: String, save: (value: Long) -> Unit) {
                if (this.containsKey(key)) save(this.getLong(key))
            }

            val extractor = MediaExtractor()
            extractor.setDataSource(context, uri, null)
            for (i in 0 until extractor.trackCount) {
                try {
                    val format = extractor.getTrackFormat(i)
                    format.getString(MediaFormat.KEY_MIME)?.let { mime ->
                        val trackMime = if (mime == MediaFormat.MIMETYPE_IMAGE_ANDROID_HEIC) MimeTypes.HEIC else mime
                        val page = hashMapOf<String, Any>(
                            KEY_PAGE to i,
                            KEY_MIME_TYPE to trackMime,
                        )

                        // do not use `MediaFormat.KEY_TRACK_ID` as it is actually not unique between tracks
                        // e.g. there could be both a video track and an image track with KEY_TRACK_ID == 1

                        format.getSafeInt(MediaFormat.KEY_IS_DEFAULT) { page[KEY_IS_DEFAULT] = it != 0 }
                        format.getSafeInt(MediaFormat.KEY_WIDTH) { page[KEY_WIDTH] = it }
                        format.getSafeInt(MediaFormat.KEY_HEIGHT) { page[KEY_HEIGHT] = it }
                        if (isVideo(trackMime)) {
                            format.getSafeLong(MediaFormat.KEY_DURATION) { page[KEY_DURATION] = it / 1000 }
                        }
                        pages.add(page)
                    }
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to get track information for uri=$uri, track num=$i", e)
                }
            }
            extractor.release()
        }
        result.success(pages)
    }

    private fun getPanoramaInfo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getPanoramaInfo-args", "failed because of missing arguments", null)
            return
        }

        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    val fields = hashMapOf<String, Any?>(
                        "projectionType" to XMP.GPANO_PROJECTION_TYPE_DEFAULT,
                    )
                    for (dir in metadata.getDirectoriesOfType(XmpDirectory::class.java)) {
                        val xmpMeta = dir.xmpMeta
                        xmpMeta.getSafeInt(XMP.GPANO_SCHEMA_NS, XMP.GPANO_CROPPED_AREA_LEFT_PROP_NAME) { fields["croppedAreaLeft"] = it }
                        xmpMeta.getSafeInt(XMP.GPANO_SCHEMA_NS, XMP.GPANO_CROPPED_AREA_TOP_PROP_NAME) { fields["croppedAreaTop"] = it }
                        xmpMeta.getSafeInt(XMP.GPANO_SCHEMA_NS, XMP.GPANO_CROPPED_AREA_WIDTH_PROP_NAME) { fields["croppedAreaWidth"] = it }
                        xmpMeta.getSafeInt(XMP.GPANO_SCHEMA_NS, XMP.GPANO_CROPPED_AREA_HEIGHT_PROP_NAME) { fields["croppedAreaHeight"] = it }
                        xmpMeta.getSafeInt(XMP.GPANO_SCHEMA_NS, XMP.GPANO_FULL_PANO_WIDTH_PROP_NAME) { fields["fullPanoWidth"] = it }
                        xmpMeta.getSafeInt(XMP.GPANO_SCHEMA_NS, XMP.GPANO_FULL_PANO_HEIGHT_PROP_NAME) { fields["fullPanoHeight"] = it }
                        xmpMeta.getSafeString(XMP.GPANO_SCHEMA_NS, XMP.GPANO_PROJECTION_TYPE_PROP_NAME) { fields["projectionType"] = it }
                    }
                    result.success(fields)
                    return
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read XMP", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read XMP", e)
            }
        }
        result.error("getPanoramaInfo-empty", "failed to read XMP from uri=$uri", null)
    }

    private fun getContentResolverProp(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val prop = call.argument<String>("prop")
        if (mimeType == null || uri == null || prop == null) {
            result.error("getContentResolverProp-args", "failed because of missing arguments", null)
            return
        }

        var contentUri: Uri = uri
        if (uri.scheme == ContentResolver.SCHEME_CONTENT && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)) {
            uri.tryParseId()?.let { id ->
                contentUri = when {
                    isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    else -> uri
                }
                contentUri = StorageUtils.getOriginalUri(contentUri)
            }
        }

        val projection = arrayOf(prop)
        val cursor: Cursor?
        try {
            cursor = context.contentResolver.query(contentUri, projection, null, null, null)
        } catch (e: Exception) {
            // throws SQLiteException when the requested prop is not a known column
            result.error("getContentResolverProp-query", "failed to query for contentUri=$contentUri", e.message)
            return
        }

        if (cursor == null || !cursor.moveToFirst()) {
            result.error("getContentResolverProp-cursor", "failed to get cursor for contentUri=$contentUri", null)
            return
        }

        var value: Any? = null
        try {
            value = when (cursor.getType(0)) {
                Cursor.FIELD_TYPE_NULL -> null
                Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(0)
                Cursor.FIELD_TYPE_FLOAT -> cursor.getFloat(0)
                Cursor.FIELD_TYPE_STRING -> cursor.getString(0)
                Cursor.FIELD_TYPE_BLOB -> cursor.getBlob(0)
                else -> null
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get value for key=$prop", e)
        }
        cursor.close()
        result.success(value?.toString())
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
        if (isSupportedByExifInterface(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val exif = ExifInterface(input)
                    val orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                    exif.thumbnailBitmap?.let { bitmap ->
                        TransformationUtils.rotateImageExif(BitmapUtils.getBitmapPool(context), bitmap, orientation)?.let {
                            it.getBytes(canHaveAlpha = false, recycle = false)?.let { bytes -> thumbnails.add(bytes) }
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

    private fun extractXmpDataProp(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val dataPropPath = call.argument<String>("propPath")
        val embedMimeType = call.argument<String>("propMimeType")
        if (mimeType == null || uri == null || dataPropPath == null || embedMimeType == null) {
            result.error("extractXmpDataProp-args", "failed because of missing arguments", null)
            return
        }

        if (isSupportedByMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    // data can be large and stored in "Extended XMP",
                    // which is returned as a second XMP directory
                    val xmpDirs = metadata.getDirectoriesOfType(XmpDirectory::class.java)
                    try {
                        val pathParts = dataPropPath.split('/')

                        val embedBytes: ByteArray = if (pathParts.size == 1) {
                            val propName = pathParts[0]
                            val propNs = XMP.namespaceForPropPath(propName)
                            xmpDirs.map { it.xmpMeta.getPropertyBase64(propNs, propName) }.first { it != null }
                        } else {
                            val structName = pathParts[0]
                            val structNs = XMP.namespaceForPropPath(structName)
                            val fieldName = pathParts[1]
                            val fieldNs = XMP.namespaceForPropPath(fieldName)
                            xmpDirs.map { it.xmpMeta.getStructField(structNs, structName, fieldNs, fieldName) }.first { it != null }.let {
                                XMPUtils.decodeBase64(it.value)
                            }
                        }

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
                            GlobalScope.launch(Dispatchers.IO) {
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

    private fun isMultiPageTiff(uri: Uri) = getTiffPageInfo(uri, 0)?.outDirectoryCount ?: 1 > 1

    private fun getTiffPageInfo(uri: Uri, page: Int): TiffBitmapFactory.Options? {
        try {
            val fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
            if (fd == null) {
                Log.w(LOG_TAG, "failed to get file descriptor for uri=$uri")
                return null
            }
            val options = TiffBitmapFactory.Options().apply {
                inJustDecodeBounds = true
                inDirectoryNumber = page
            }
            TiffBitmapFactory.decodeFileDescriptor(fd, options)
            return options
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get TIFF page info for uri=$uri page=$page", e)
        }
        return null
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag(MetadataHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/metadata"

        private val allMetadataRedundantDirNames = setOf(
            "MP4",
            "MP4 Sound",
            "MP4 Video",
            "QuickTime",
            "QuickTime Sound",
            "QuickTime Video",
        )

        // catalog metadata & page info
        private const val KEY_MIME_TYPE = "mimeType"
        private const val KEY_DATE_MILLIS = "dateMillis"
        private const val KEY_FLAGS = "flags"
        private const val KEY_ROTATION_DEGREES = "rotationDegrees"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
        private const val KEY_XMP_SUBJECTS = "xmpSubjects"
        private const val KEY_XMP_TITLE_DESCRIPTION = "xmpTitleDescription"
        private const val KEY_HEIGHT = "height"
        private const val KEY_WIDTH = "width"
        private const val KEY_PAGE = "page"
        private const val KEY_IS_DEFAULT = "isDefault"
        private const val KEY_DURATION = "durationMillis"

        private const val MASK_IS_ANIMATED = 1 shl 0
        private const val MASK_IS_FLIPPED = 1 shl 1
        private const val MASK_IS_GEOTIFF = 1 shl 2
        private const val MASK_IS_360 = 1 shl 3
        private const val MASK_IS_MULTIPAGE = 1 shl 4
        private const val XMP_SUBJECTS_SEPARATOR = ";"

        // overlay metadata
        private const val KEY_APERTURE = "aperture"
        private const val KEY_EXPOSURE_TIME = "exposureTime"
        private const val KEY_FOCAL_LENGTH = "focalLength"
        private const val KEY_ISO = "iso"
    }
}