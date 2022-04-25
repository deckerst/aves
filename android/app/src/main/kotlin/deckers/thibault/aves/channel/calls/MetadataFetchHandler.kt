package deckers.thibault.aves.channel.calls

import android.annotation.SuppressLint
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
import com.adobe.internal.xmp.XMPMetaFactory
import com.adobe.internal.xmp.options.SerializeOptions
import com.adobe.internal.xmp.properties.XMPPropertyInfo
import com.drew.lang.KeyValuePair
import com.drew.lang.Rational
import com.drew.metadata.Tag
import com.drew.metadata.avi.AviDirectory
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
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
import deckers.thibault.aves.metadata.Metadata.DIR_DNG
import deckers.thibault.aves.metadata.Metadata.DIR_EXIF_GEOTIFF
import deckers.thibault.aves.metadata.Metadata.DIR_PNG_TEXTUAL_DATA
import deckers.thibault.aves.metadata.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.metadata.Metadata.isFlippedForExifCode
import deckers.thibault.aves.metadata.MetadataExtractorHelper.PNG_ITXT_DIR_NAME
import deckers.thibault.aves.metadata.MetadataExtractorHelper.PNG_LAST_MODIFICATION_TIME_FORMAT
import deckers.thibault.aves.metadata.MetadataExtractorHelper.PNG_TIME_DIR_NAME
import deckers.thibault.aves.metadata.MetadataExtractorHelper.containsGeoTiffTags
import deckers.thibault.aves.metadata.MetadataExtractorHelper.extractGeoKeys
import deckers.thibault.aves.metadata.MetadataExtractorHelper.extractPngProfile
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getDateDigitizedMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getDateModifiedMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getDateOriginalMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeBoolean
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeRational
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeString
import deckers.thibault.aves.metadata.MetadataExtractorHelper.isPngTextDir
import deckers.thibault.aves.metadata.XMP.getSafeDateMillis
import deckers.thibault.aves.metadata.XMP.getSafeInt
import deckers.thibault.aves.metadata.XMP.getSafeLocalizedText
import deckers.thibault.aves.metadata.XMP.getSafeString
import deckers.thibault.aves.metadata.XMP.isMotionPhoto
import deckers.thibault.aves.metadata.XMP.isPanorama
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.TIFF_EXTENSION_PATTERN
import deckers.thibault.aves.utils.MimeTypes.canReadWithExifInterface
import deckers.thibault.aves.utils.MimeTypes.canReadWithMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isHeic
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.UriUtils.tryParseId
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import java.text.DecimalFormat
import java.text.ParseException
import kotlin.math.roundToInt
import kotlin.math.roundToLong

class MetadataFetchHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAllMetadata" -> ioScope.launch { safe(call, result, ::getAllMetadata) }
            "getCatalogMetadata" -> ioScope.launch { safe(call, result, ::getCatalogMetadata) }
            "getOverlayMetadata" -> ioScope.launch { safe(call, result, ::getOverlayMetadata) }
            "getGeoTiffInfo" -> ioScope.launch { safe(call, result, ::getGeoTiffInfo) }
            "getMultiPageInfo" -> ioScope.launch { safe(call, result, ::getMultiPageInfo) }
            "getPanoramaInfo" -> ioScope.launch { safe(call, result, ::getPanoramaInfo) }
            "getIptc" -> ioScope.launch { safe(call, result, ::getIptc) }
            "getXmp" -> ioScope.launch { safe(call, result, ::getXmp) }
            "hasContentResolverProp" -> ioScope.launch { safe(call, result, ::hasContentResolverProp) }
            "getContentResolverProp" -> ioScope.launch { safe(call, result, ::getContentResolverProp) }
            "getDate" -> ioScope.launch { safe(call, result, ::getDate) }
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

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    foundExif = metadata.directories.any { it is ExifDirectoryBase && it.tagCount > 0 }
                    foundXmp = metadata.directories.any { it is XmpDirectory && it.tagCount > 0 }
                    val uuidDirCount = HashMap<String, Int>()
                    val dirByName = metadata.directories.filter {
                        (it.tagCount > 0 || it.errorCount > 0)
                                && it !is FileTypeDirectory
                                && it !is AviDirectory
                    }.groupBy { dir -> dir.name }
                    for (dirEntry in dirByName) {
                        val baseDirName = dirEntry.key

                        // exclude directories known to be redundant with info derived on the Dart side
                        // they are excluded by name instead of runtime type because excluding `Mp4Directory`
                        // would also exclude derived directories, such as `Mp4UuidBoxDirectory`
                        if (allMetadataRedundantDirNames.contains(baseDirName)) continue

                        val sameNameDirs = dirEntry.value
                        val sameNameDirCount = sameNameDirs.size
                        for (dirIndex in 0 until sameNameDirCount) {
                            val dir = sameNameDirs[dirIndex]

                            // directory name
                            var thisDirName = baseDirName
                            if (dir is Mp4UuidBoxDirectory) {
                                val uuid = dir.getString(Mp4UuidBoxDirectory.TAG_UUID).substringBefore('-')
                                thisDirName += " $uuid"

                                val count = uuidDirCount[uuid] ?: 0
                                uuidDirCount[uuid] = count + 1
                                if (count > 0) {
                                    thisDirName += " ($count)"
                                }
                            } else if (sameNameDirCount > 1 && !allMetadataMergeableDirNames.contains(baseDirName)) {
                                // optional count for multiple directories of the same type
                                thisDirName = "$thisDirName[${dirIndex + 1}]"
                            }

                            // optional parent to distinguish child directories of the same type
                            dir.parent?.name?.let { thisDirName = "$it/$thisDirName" }

                            var dirMap = metadataMap[thisDirName] ?: HashMap()
                            metadataMap[thisDirName] = dirMap

                            // tags
                            val tags = dir.tags
                            when {
                                dir is ExifDirectoryBase -> {
                                    when {
                                        dir.containsGeoTiffTags() -> {
                                            // split GeoTIFF tags in their own directory
                                            val geoTiffDirMap = metadataMap[DIR_EXIF_GEOTIFF] ?: HashMap()
                                            metadataMap[DIR_EXIF_GEOTIFF] = geoTiffDirMap
                                            val byGeoTiff = tags.groupBy { ExifTags.isGeoTiffTag(it.tagType) }
                                            byGeoTiff[true]?.flatMap { tag ->
                                                when (tag.tagType) {
                                                    ExifGeoTiffTags.TAG_GEO_KEY_DIRECTORY -> {
                                                        val geoTiffTags = (dir as ExifIFD0Directory).extractGeoKeys(dir.getIntArray(tag.tagType))
                                                        geoTiffTags.map { geoTag ->
                                                            val name = GeoTiffKeys.getTagName(geoTag.key) ?: "0x${geoTag.key.toString(16)}"
                                                            val value = geoTag.value
                                                            val description = if (value is DoubleArray) value.joinToString(" ") { doubleFormat.format(it) } else "$value"
                                                            Pair(name, description)
                                                        }
                                                    }
                                                    // skip `Geo double/ascii params`, as their content is split and presented through various GeoTIFF keys
                                                    ExifGeoTiffTags.TAG_GEO_DOUBLE_PARAMS,
                                                    ExifGeoTiffTags.TAG_GEO_ASCII_PARAMS -> ArrayList()
                                                    else -> listOf(exifTagMapper(tag))
                                                }
                                            }?.let { geoTiffDirMap.putAll(it) }
                                            byGeoTiff[false]?.map { exifTagMapper(it) }?.let { dirMap.putAll(it) }
                                        }
                                        mimeType == MimeTypes.DNG -> {
                                            // split DNG tags in their own directory
                                            val dngDirMap = metadataMap[DIR_DNG] ?: HashMap()
                                            metadataMap[DIR_DNG] = dngDirMap
                                            val byDng = tags.groupBy { ExifTags.isDngTag(it.tagType) }
                                            byDng[true]?.map { exifTagMapper(it) }?.let { dngDirMap.putAll(it) }
                                            byDng[false]?.map { exifTagMapper(it) }?.let { dirMap.putAll(it) }
                                        }
                                        else -> dirMap.putAll(tags.map { exifTagMapper(it) })
                                    }
                                }
                                dir.isPngTextDir() -> {
                                    metadataMap.remove(thisDirName)
                                    dirMap = metadataMap[DIR_PNG_TEXTUAL_DATA] ?: HashMap()
                                    metadataMap[DIR_PNG_TEXTUAL_DATA] = dirMap

                                    for (tag in tags) {
                                        val tagType = tag.tagType
                                        if (tagType == PngDirectory.TAG_TEXTUAL_DATA) {
                                            val pairs = dir.getObject(tagType) as List<*>
                                            val textPairs = pairs.map { pair ->
                                                val kv = pair as KeyValuePair
                                                val key = kv.key
                                                // `PNG-iTXt` uses UTF-8, contrary to `PNG-tEXt` and `PNG-zTXt` using Latin-1 / ISO-8859-1
                                                val charset = if (baseDirName == PNG_ITXT_DIR_NAME) {
                                                    @SuppressLint("ObsoleteSdkInt")
                                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                                                        StandardCharsets.UTF_8
                                                    } else {
                                                        Charset.forName("UTF-8")
                                                    }
                                                } else {
                                                    kv.value.charset
                                                }
                                                val valueString = String(kv.value.bytes, charset)
                                                val dirs = extractPngProfile(key, valueString)
                                                if (dirs?.any() == true) {
                                                    dirs.forEach { profileDir ->
                                                        val profileDirName = "${dir.name}/${profileDir.name}"
                                                        val profileDirMap = metadataMap[profileDirName] ?: HashMap()
                                                        metadataMap[profileDirName] = profileDirMap
                                                        val profileTags = profileDir.tags
                                                        if (profileDir is ExifDirectoryBase) {
                                                            profileDirMap.putAll(profileTags.map { exifTagMapper(it) })
                                                        } else {
                                                            profileDirMap.putAll(profileTags.map { Pair(it.tagName, it.description) })
                                                        }
                                                    }
                                                    null
                                                } else {
                                                    Pair(key, valueString)
                                                }
                                            }
                                            dirMap.putAll(textPairs.filterNotNull())
                                        } else {
                                            dirMap[tag.tagName] = tag.description
                                        }
                                    }
                                }
                                else -> dirMap.putAll(tags.map { Pair(it.tagName, it.description) })
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
                                when (dir.getString(Mp4UuidBoxDirectory.TAG_UUID)) {
                                    GSpherical.SPHERICAL_VIDEO_V1_UUID -> {
                                        val bytes = dir.getByteArray(Mp4UuidBoxDirectory.TAG_USER_DATA)
                                        metadataMap["Spherical Video"] = HashMap(GSpherical(bytes).describe())
                                        metadataMap.remove(thisDirName)
                                    }
                                    QuickTimeMetadata.PROF_UUID -> {
                                        // redundant with info derived on the Dart side
                                        metadataMap.remove(thisDirName)
                                    }
                                    QuickTimeMetadata.USMT_UUID -> {
                                        val bytes = dir.getByteArray(Mp4UuidBoxDirectory.TAG_USER_DATA)
                                        val blocks = QuickTimeMetadata.parseUuidUsmt(bytes)
                                        if (blocks.isNotEmpty()) {
                                            metadataMap.remove(thisDirName)
                                            thisDirName = "QuickTime User Media"
                                            val usmt = metadataMap[thisDirName] ?: HashMap()
                                            metadataMap[thisDirName] = usmt

                                            blocks.forEach {
                                                var key = it.type
                                                var value = it.value
                                                val language = it.language

                                                var i = 0
                                                while (usmt.containsKey(key)) {
                                                    key = it.type + " (${++i})"
                                                }
                                                if (language != "und") {
                                                    value += " ($language)"
                                                }
                                                usmt[key] = value
                                            }
                                        }
                                    }
                                }
                            }

                            // include errors, if any
                            dir.errors.forEachIndexed { i, error ->
                                dirMap["Error[$i]"] = error
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
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
            // and to identify whether there is an accessible cover image
            // do not include HEIC here
            val mediaDir = getAllMetadataByMediaMetadataRetriever(uri)
            if (mediaDir.isNotEmpty()) {
                metadataMap[Metadata.DIR_MEDIA] = mediaDir
                if (mediaDir.containsKey(KEY_HAS_EMBEDDED_PICTURE)) {
                    metadataMap[Metadata.DIR_COVER_ART] = hashMapOf(
                        // dummy entry value
                        "Image" to "data",
                    )
                }
            }
            // Android's `MediaExtractor` and `MediaPlayer` cannot be used for details
            // about embedded images as they do not list them as separate tracks
            // and only identify at most one
        }

        if (metadataMap.isNotEmpty()) {
            result.success(metadataMap)
        } else {
            result.error("getAllMetadata-failure", "failed to get metadata for mimeType=$mimeType uri=$uri", null)
        }
    }

    private fun getAllMetadataByMediaMetadataRetriever(uri: Uri): MutableMap<String, String> {
        val dirMap = HashMap<String, String>()
        val retriever = StorageUtils.openMetadataRetriever(context, uri) ?: return dirMap
        try {
            for ((code, name) in MediaMetadataRetrieverHelper.allKeys) {
                retriever.getSafeDescription(code) { dirMap[name] = it }
            }
            if (retriever.embeddedPicture != null) {
                // additional key for the Dart side to know whether to add a `Cover` section
                dirMap[KEY_HAS_EMBEDDED_PICTURE] = "yes"
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get video metadata by MediaMetadataRetriever for uri=$uri", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
        return dirMap
    }

    // set `KEY_DATE_MILLIS` from these fields (by precedence):
    // - Exif / DATETIME_ORIGINAL
    // - Exif / DATETIME
    // - XMP / xmp:CreateDate
    // - XMP / photoshop:DateCreated
    // - PNG / TIME / LAST_MODIFICATION_TIME
    // - Video / METADATA_KEY_DATE
    // set `KEY_XMP_TITLE_DESCRIPTION` from these fields (by precedence):
    // - XMP / dc:title
    // - XMP / dc:description
    // set `KEY_XMP_SUBJECTS` from these fields (by precedence):
    // - XMP / dc:subject
    // - IPTC / keywords
    // set `KEY_RATING` from these fields (by precedence):
    // - XMP / xmp:Rating
    // - XMP / MicrosoftPhoto:Rating
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

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    foundExif = metadata.directories.any { it is ExifDirectoryBase && it.tagCount > 0 }

                    // File type
                    for (dir in metadata.getDirectoriesOfType(FileTypeDirectory::class.java)) {
                        // * `metadata-extractor` sometimes detects the wrong MIME type (e.g. `pef` file as `tiff`, `mpeg` as `dvd`, `avif` as `mov`)
                        // * the content resolver / media store sometimes reports the wrong MIME type (e.g. `png` file as `jpeg`, `tiff` as `srw`)
                        // * `context.getContentResolver().getType()` sometimes returns an incorrect value
                        // * `MediaMetadataRetriever.setDataSource()` sometimes fails with `status = 0x80000000`
                        // * file extension is unreliable
                        // In the end, `metadata-extractor` is the most reliable, except for `tiff`/`dvd`/`mov` (false positives, false negatives),
                        // in which case we trust the file extension
                        // cf https://github.com/drewnoakes/metadata-extractor/issues/296
                        if (path?.matches(TIFF_EXTENSION_PATTERN) == true) {
                            metadataMap[KEY_MIME_TYPE] = MimeTypes.TIFF
                        } else {
                            dir.getSafeString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE) {
                                if (it != MimeTypes.TIFF && it != MimeTypes.DVD && it != MimeTypes.MOV) {
                                    metadataMap[KEY_MIME_TYPE] = it
                                }
                            }
                        }
                    }

                    // EXIF
                    for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                        dir.getDateOriginalMillis { metadataMap[KEY_DATE_MILLIS] = it }
                        if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                            // fetch date modified from SubIFD directory first, as the sub-second tag is here
                            dir.getDateModifiedMillis { metadataMap[KEY_DATE_MILLIS] = it }
                        }
                    }
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                            // fallback to fetch date modified from IFD0 directory, without the sub-second tag
                            // in case there was no SubIFD directory
                            dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME, null)?.let { metadataMap[KEY_DATE_MILLIS] = it }
                        }
                        dir.getSafeInt(ExifDirectoryBase.TAG_ORIENTATION) {
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
                            if (xmpMeta.doesPropertyExist(XMP.DC_SCHEMA_NS, XMP.DC_SUBJECT_PROP_NAME)) {
                                val count = xmpMeta.countArrayItems(XMP.DC_SCHEMA_NS, XMP.DC_SUBJECT_PROP_NAME)
                                val values = (1 until count + 1).map { xmpMeta.getArrayItem(XMP.DC_SCHEMA_NS, XMP.DC_SUBJECT_PROP_NAME, it).value }
                                metadataMap[KEY_XMP_SUBJECTS] = values.joinToString(XMP_SUBJECTS_SEPARATOR)
                            }
                            xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.DC_TITLE_PROP_NAME, acceptBlank = false) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            if (!metadataMap.containsKey(KEY_XMP_TITLE_DESCRIPTION)) {
                                xmpMeta.getSafeLocalizedText(XMP.DC_SCHEMA_NS, XMP.DC_DESCRIPTION_PROP_NAME, acceptBlank = false) { metadataMap[KEY_XMP_TITLE_DESCRIPTION] = it }
                            }
                            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                xmpMeta.getSafeDateMillis(XMP.XMP_SCHEMA_NS, XMP.XMP_CREATE_DATE_PROP_NAME) { metadataMap[KEY_DATE_MILLIS] = it }
                                if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                    xmpMeta.getSafeDateMillis(XMP.PHOTOSHOP_SCHEMA_NS, XMP.PS_DATE_CREATED_PROP_NAME) { metadataMap[KEY_DATE_MILLIS] = it }
                                }
                            }

                            xmpMeta.getSafeInt(XMP.XMP_SCHEMA_NS, XMP.XMP_RATING_PROP_NAME) { metadataMap[KEY_RATING] = it }
                            if (!metadataMap.containsKey(KEY_RATING)) {
                                xmpMeta.getSafeInt(XMP.MICROSOFTPHOTO_SCHEMA_NS, XMP.MS_RATING_PROP_NAME) { percentRating ->
                                    // values of 1,25,50,75,99% correspond to 1,2,3,4,5 stars
                                    val standardRating = (percentRating / 25f).roundToInt() + 1
                                    metadataMap[KEY_RATING] = standardRating
                                }
                            }

                            // identification of panorama (aka photo sphere)
                            if (xmpMeta.isPanorama()) {
                                flags = flags or MASK_IS_360
                            }

                            // identification of motion photo
                            if (xmpMeta.isMotionPhoto()) {
                                flags = flags or MASK_IS_MULTIPAGE
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
                                if (dir.containsGeoTiffTags()) flags = flags or MASK_IS_GEOTIFF
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
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
            // fallback to read EXIF via ExifInterface
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val exif = ExifInterface(input)
                    exif.getSafeDateMillis(ExifInterface.TAG_DATETIME_ORIGINAL, ExifInterface.TAG_SUBSEC_TIME_ORIGINAL) { metadataMap[KEY_DATE_MILLIS] = it }
                    if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                        exif.getSafeDateMillis(ExifInterface.TAG_DATETIME, ExifInterface.TAG_SUBSEC_TIME) { metadataMap[KEY_DATE_MILLIS] = it }
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
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for mimeType=$mimeType uri=$uri", e)
            }
        }

        if (mimeType == MimeTypes.TIFF && MultiPage.isMultiPageTiff(context, uri)) flags = flags or MASK_IS_MULTIPAGE

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
            @SuppressLint("ObsoleteSdkInt")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { metadataMap[KEY_ROTATION_DEGREES] = it }
            }
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

        val saveExposureTime = fun(value: Rational) {
            // `TAG_EXPOSURE_TIME` as a string is sometimes a ratio, sometimes a decimal
            // so we explicitly request it as a rational (e.g. 1/100, 1/14, 71428571/1000000000, 4000/1000, 2000000000/500000000)
            // and process it to make sure the numerator is `1` when the ratio value is less than 1
            val num = value.numerator
            val denom = value.denominator
            metadataMap[KEY_EXPOSURE_TIME] = when {
                num >= denom -> "${value.toSimpleString(true)}″"
                num != 1L && num != 0L -> Rational(1, (denom / num.toDouble()).roundToLong()).toString()
                else -> value.toString()
            }
        }

        var foundExif = false
        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                        foundExif = true
                        dir.getSafeRational(ExifDirectoryBase.TAG_FNUMBER) { metadataMap[KEY_APERTURE] = it.numerator.toDouble() / it.denominator }
                        dir.getSafeRational(ExifDirectoryBase.TAG_EXPOSURE_TIME, saveExposureTime)
                        dir.getSafeRational(ExifDirectoryBase.TAG_FOCAL_LENGTH) { metadataMap[KEY_FOCAL_LENGTH] = it.numerator.toDouble() / it.denominator }
                        dir.getSafeInt(ExifDirectoryBase.TAG_ISO_EQUIVALENT) { metadataMap[KEY_ISO] = it }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
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
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for mimeType=$mimeType uri=$uri", e)
            }
        }

        result.success(metadataMap)
    }

    private fun getGeoTiffInfo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getGeoTiffInfo-args", "failed because of missing arguments", null)
            return
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    val fields = HashMap<Int, Any?>()
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        if (dir.containsGeoTiffTags()) {
                            fields.putAll(dir.tags.map { it.tagType }.filter { ExifTags.isGeoTiffTag(it) }.map {
                                val value = when (it) {
                                    ExifGeoTiffTags.TAG_GEO_ASCII_PARAMS -> dir.getString(it)
                                    else -> dir.getObject(it)
                                }
                                Pair(it, value)
                            })
                            val geoKeyDirectory = dir.getIntArray(ExifGeoTiffTags.TAG_GEO_KEY_DIRECTORY)
                            fields.putAll((dir as ExifIFD0Directory).extractGeoKeys(geoKeyDirectory))
                        }
                    }
                    result.success(fields)
                    return
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }
        result.error("getGeoTiffInfo-empty", "failed to get info for mimeType=$mimeType uri=$uri", null)
    }

    private fun getMultiPageInfo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null || sizeBytes == null) {
            result.error("getMultiPageInfo-args", "failed because of missing arguments", null)
            return
        }

        val pages: ArrayList<FieldMap>? = when (mimeType) {
            MimeTypes.HEIC, MimeTypes.HEIF -> MultiPage.getHeicTracks(context, uri)
            MimeTypes.JPEG -> MultiPage.getMotionPhotoPages(context, uri, mimeType, sizeBytes = sizeBytes)
            MimeTypes.TIFF -> MultiPage.getTiffPages(context, uri)
            else -> null
        }
        if (pages?.isEmpty() == true) {
            result.error("getMultiPageInfo-empty", "failed to get pages for mimeType=$mimeType uri=$uri", null)
        } else {
            result.success(pages)
        }
    }

    private fun getPanoramaInfo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getPanoramaInfo-args", "failed because of missing arguments", null)
            return
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    val fields: FieldMap = hashMapOf(
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
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }
        result.error("getPanoramaInfo-empty", "failed to get info for mimeType=$mimeType uri=$uri", null)
    }

    private fun getIptc(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (mimeType == null || uri == null) {
            result.error("getIptc-args", "failed because of missing arguments", null)
            return
        }

        if (MimeTypes.canReadWithPixyMeta(mimeType)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val iptcDataList = PixyMetaHelper.getIptc(input)
                    result.success(iptcDataList)
                    return
                }
            } catch (e: Exception) {
                result.error("getIptc-exception", "failed to read IPTC for mimeType=$mimeType uri=$uri", e.message)
                return
            }
        }

        result.success(null)
    }

    private fun getXmp(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getXmp-args", "failed because of missing arguments", null)
            return
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    val xmpStrings = metadata.getDirectoriesOfType(XmpDirectory::class.java).mapNotNull { XMPMetaFactory.serializeToString(it.xmpMeta, xmpSerializeOptions) }
                    result.success(xmpStrings.toMutableList())
                    return
                }
            } catch (e: Exception) {
                result.error("getXmp-exception", "failed to read XMP for mimeType=$mimeType uri=$uri", e.message)
                return
            } catch (e: NoClassDefFoundError) {
                result.error("getXmp-noclass", "failed to read XMP for mimeType=$mimeType uri=$uri", e.message)
                return
            } catch (e: AssertionError) {
                result.error("getXmp-assert", "failed to read XMP for mimeType=$mimeType uri=$uri", e.message)
                return
            }
        }

        result.success(null)
    }

    private fun hasContentResolverProp(call: MethodCall, result: MethodChannel.Result) {
        val prop = call.argument<String>("prop")
        if (prop == null) {
            result.error("hasContentResolverProp-args", "failed because of missing arguments", null)
            return
        }

        result.success(
            when (prop) {
                "owner_package_name" -> Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
                else -> {
                    result.error("hasContentResolverProp-unknown", "unknown property=$prop", null)
                    return
                }
            }
        )
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
        if (StorageUtils.isMediaStoreContentUri(uri)) {
            uri.tryParseId()?.let { id ->
                contentUri = when {
                    isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    else -> uri
                }
                contentUri = StorageUtils.getOriginalUri(context, contentUri)
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

    private fun getDate(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val field = call.argument<String>("field")
        if (mimeType == null || uri == null || field == null) {
            result.error("getDate-args", "failed because of missing arguments", null)
            return
        }

        var dateMillis: Long? = null
        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    val tag = when (field) {
                        ExifInterface.TAG_DATETIME -> ExifIFD0Directory.TAG_DATETIME
                        ExifInterface.TAG_DATETIME_DIGITIZED -> ExifSubIFDDirectory.TAG_DATETIME_DIGITIZED
                        ExifInterface.TAG_DATETIME_ORIGINAL -> ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL
                        ExifInterface.TAG_GPS_DATESTAMP -> GpsDirectory.TAG_DATE_STAMP
                        else -> {
                            result.error("getDate-field", "unsupported ExifInterface field=$field", null)
                            return
                        }
                    }

                    when (tag) {
                        ExifIFD0Directory.TAG_DATETIME -> {
                            for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                                dir.getDateModifiedMillis { dateMillis = it }
                            }
                            if (dateMillis == null) {
                                for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                                    dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME, null)?.let { dateMillis = it }
                                }
                            }
                        }
                        ExifSubIFDDirectory.TAG_DATETIME_DIGITIZED -> {
                            for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                                dir.getDateDigitizedMillis { dateMillis = it }
                            }
                        }
                        ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL -> {
                            for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                                dir.getDateOriginalMillis { dateMillis = it }
                            }
                        }
                        GpsDirectory.TAG_DATE_STAMP -> {
                            for (dir in metadata.getDirectoriesOfType(GpsDirectory::class.java)) {
                                dir.gpsDate?.let { dateMillis = it.time }
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for mimeType=$mimeType uri=$uri", e)
            }
        }

        result.success(dateMillis)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MetadataFetchHandler>()
        const val CHANNEL = "deckers.thibault/aves/metadata_fetch"

        private val doubleFormat = DecimalFormat("0.###")

        private val allMetadataRedundantDirNames = setOf(
            "MP4",
            "MP4 Metadata",
            "MP4 Sound",
            "MP4 Video",
            "QuickTime",
            "QuickTime Sound",
            "QuickTime Video",
        )
        private val allMetadataMergeableDirNames = setOf(
            "Exif SubIFD",
            "GIF Control",
            "GIF Image",
            "HEIF",
            "ICC Profile",
            "IPTC",
            "WebP",
            "XMP",
        )

        private val xmpSerializeOptions = SerializeOptions().apply {
            omitPacketWrapper = true // e.g. <?xpacket begin="..." id="W5M0MpCehiHzreSzNTczkc9d"?>...<?xpacket end="r"?>
            omitXmpMetaElement = false // e.g. <x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">...</x:xmpmeta>
        }

        private fun exifTagMapper(it: Tag): Pair<String, String> {
            val name = if (it.hasTagName()) {
                it.tagName
            } else {
                ExifTags.getTagName(it.tagType) ?: it.tagName
            }
            return Pair(name, it.description)
        }

        // catalog metadata
        private const val KEY_MIME_TYPE = "mimeType"
        private const val KEY_DATE_MILLIS = "dateMillis"
        private const val KEY_FLAGS = "flags"
        private const val KEY_ROTATION_DEGREES = "rotationDegrees"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
        private const val KEY_XMP_SUBJECTS = "xmpSubjects"
        private const val KEY_XMP_TITLE_DESCRIPTION = "xmpTitleDescription"
        private const val KEY_RATING = "rating"

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

        // additional media key
        private const val KEY_HAS_EMBEDDED_PICTURE = "Has Embedded Picture"
    }
}