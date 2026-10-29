package deckers.thibault.aves.channel.calls

import android.content.Context
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.os.Build
import android.util.Log
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta
import com.adobe.internal.xmp.XMPMetaFactory
import com.adobe.internal.xmp.options.SerializeOptions
import com.adobe.internal.xmp.properties.XMPPropertyInfo
import com.drew.lang.KeyValuePair
import com.drew.lang.Rational
import com.drew.metadata.Directory
import com.drew.metadata.Tag
import com.drew.metadata.avi.AviDirectory
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.GpsDirectory
import com.drew.metadata.file.FileTypeDirectory
import com.drew.metadata.geotiff.GeoTiffDirectory
import com.drew.metadata.gif.GifAnimationDirectory
import com.drew.metadata.iptc.IptcDirectory
import com.drew.metadata.mov.metadata.QuickTimeMetadataDirectory
import com.drew.metadata.mp4.media.Mp4UuidBoxDirectory
import com.drew.metadata.png.PngDirectory
import com.drew.metadata.webp.WebpDirectory
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.metadata.C2paHelper
import deckers.thibault.aves.metadata.C2paValidity
import deckers.thibault.aves.metadata.ExifInterfaceHelper
import deckers.thibault.aves.metadata.ExifInterfaceHelper.describeAll
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeDouble
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeRational
import deckers.thibault.aves.metadata.ExifTags
import deckers.thibault.aves.metadata.GSpherical
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDescription
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeDouble
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.Metadata.DIR_DNG
import deckers.thibault.aves.metadata.Metadata.DIR_PNG_TEXTUAL_DATA
import deckers.thibault.aves.metadata.Metadata.getRotationDegreesForExifCode
import deckers.thibault.aves.metadata.Metadata.isFlippedForExifCode
import deckers.thibault.aves.metadata.Mp4ParserHelper
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.metadata.PixyMetaHelper
import deckers.thibault.aves.metadata.QuickTimeMetadata
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.PNG_ITXT_DIR_NAME
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.PNG_LAST_MODIFICATION_TIME_FORMAT
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.PNG_TIME_DIR_NAME
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.extractPngProfile
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getDateDigitizedMillis
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getDateModifiedMillis
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getDateOriginalMillis
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getSafeBoolean
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getSafeDateMillis
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getSafeRational
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getSafeString
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.isPngTextDir
import deckers.thibault.aves.metadata.metadataextractor.PngActlDirectory
import deckers.thibault.aves.metadata.metadataextractor.SafeXmpReader
import deckers.thibault.aves.metadata.metadataextractor.mpf.MpEntry
import deckers.thibault.aves.metadata.metadataextractor.mpf.MpEntryDirectory
import deckers.thibault.aves.metadata.xmp.GoogleXMP
import deckers.thibault.aves.metadata.xmp.XMP
import deckers.thibault.aves.metadata.xmp.XMP.doesPropExist
import deckers.thibault.aves.metadata.xmp.XMP.getPropArrayItemValues
import deckers.thibault.aves.metadata.xmp.XMP.getSafeDateMillis
import deckers.thibault.aves.metadata.xmp.XMP.getSafeInt
import deckers.thibault.aves.metadata.xmp.XMP.getSafeLocalizedText
import deckers.thibault.aves.metadata.xmp.XMP.hasHdrGainMap
import deckers.thibault.aves.metadata.xmp.XMP.isMotionPhoto
import deckers.thibault.aves.metadata.xmp.XMP.isPanorama
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.storage.StorageUtils
import deckers.thibault.aves.utils.ContextUtils.queryContentPropValue
import deckers.thibault.aves.utils.HashUtils
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MathUtils.round
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.canReadWithExifInterface
import deckers.thibault.aves.utils.MimeTypes.canReadWithMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isIsoBMFFImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.TimeZones
import deckers.thibault.aves.utils.TimeZones.toUtcEpochMillis
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import org.json.JSONObject
import org.mp4parser.boxes.threegpp.ts26244.LocationInformationBox
import org.mp4parser.tools.Path
import java.nio.charset.StandardCharsets
import java.text.ParseException
import java.time.LocalDateTime
import java.util.Locale
import kotlin.math.roundToInt
import kotlin.math.roundToLong
import androidx.exifinterface.media.ExifInterfaceFork as ExifInterface

class MetadataFetchHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getContentCredentials" -> ioScope.launch { safe(call, result, ::getContentCredentials) }
            "getAllMetadata" -> ioScope.launch { safe(call, result, ::getAllMetadata) }
            "getCatalogMetadata" -> ioScope.launch { safe(call, result, ::getCatalogMetadata) }
            "getOverlayMetadata" -> ioScope.launch { safe(call, result, ::getOverlayMetadata) }
            "getGeoTiffInfo" -> ioScope.launch { safe(call, result, ::getGeoTiffInfo) }
            "getMultiPageInfo" -> ioScope.launch { safe(call, result, ::getMultiPageInfo) }
            "getPanoramaInfo" -> ioScope.launch { safe(call, result, ::getPanoramaInfo) }
            "getIptc" -> ioScope.launch { safe(call, result, ::getIptc) }
            "getXmp" -> ioScope.launch { safe(call, result, ::getXmp) }
            "hasContentResolverProp" -> ioScope.launch { safe(call, result, ::hasContentProp) }
            "getContentResolverProp" -> ioScope.launch { safe(call, result, ::getContentPropValue) }
            "getDate" -> ioScope.launch { safe(call, result, ::getDate) }
            "getFields" -> ioScope.launch { safe(call, result, ::getFields) }
            else -> result.notImplemented()
        }
    }

    // as of `c2pa-android` v0.0.15, library is usable only from Android P (API 28)
    private fun getContentCredentials(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        if (contentAddress == null) {
            result.error("getContentCredentials-args", "missing arguments", null)
            return
        }

        val fields: FieldMap = hashMapOf(
            "validity" to C2paHelper.getValidity(contentAddress).toString(),
            "json" to C2paHelper.getManifestJson(contentAddress),
        )

        result.success(fields)
    }

    private fun getAllMetadata(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (contentAddress == null) {
            result.error("getAllMetadata-args", "missing arguments", null)
            return
        }

        val mimeType = contentAddress.mimeType

        val metadataMap = HashMap<String, MutableMap<String, String>>()
        var foundExif = false
        var foundXmp = false
        var foundMp4Uuid = false

        fun processXmp(xmpMeta: XMPMeta, dirMap: MutableMap<String, String>, allowMultiple: Boolean = false) {
            if (foundXmp && !allowMultiple) return
            foundXmp = true
            try {
                for (prop in xmpMeta) {
                    if (prop is XMPPropertyInfo) {
                        val path = prop.path
                        if (path?.isNotEmpty() == true) {
                            val value = if (XMP.isDataPath(path)) VALUE_SKIPPED_DATA else prop.value
                            if (value?.isNotEmpty() == true) {
                                dirMap[path] = value
                            }
                        }
                    }
                }
            } catch (e: XMPException) {
                Log.w(LOG_TAG, "failed to read XMP directory for $contentAddress", e)
            }
            // remove this stat as it is not actual XMP data
            dirMap.remove(XmpDirectory().getTagName(XmpDirectory.TAG_XMP_VALUE_COUNT))
            if (dirMap.isNotEmpty()) {
                // add schema prefixes for namespace resolution
                val prefixes = XMPMetaFactory.getSchemaRegistry().prefixes
                dirMap["schemaRegistryPrefixes"] = JSONObject(prefixes).toString()
            }
        }

        val mp4UuidDirCount = HashMap<String, Int>()
        fun processMp4Uuid(dir: Mp4UuidBoxDirectory) {
            var thisDirName: String
            when (val uuid = dir.getString(Mp4UuidBoxDirectory.TAG_UUID)) {
                GSpherical.SPHERICAL_VIDEO_V1_UUID -> {
                    val bytes = dir.getByteArray(Mp4UuidBoxDirectory.TAG_USER_DATA)
                    thisDirName = "Spherical Video"
                    metadataMap[thisDirName] = HashMap(GSpherical(bytes).describe())
                }

                QuickTimeMetadata.PROF_UUID -> {
                    // redundant with info derived on the Dart side
                }

                QuickTimeMetadata.USMT_UUID -> {
                    val bytes = dir.getByteArray(Mp4UuidBoxDirectory.TAG_USER_DATA)
                    val blocks = QuickTimeMetadata.parseUuidUsmt(bytes)
                    if (blocks.isNotEmpty()) {
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

                else -> {
                    val uuidPart = uuid.substringBefore('-')
                    thisDirName = "${dir.name} $uuidPart"

                    val count = mp4UuidDirCount[uuidPart] ?: 0
                    mp4UuidDirCount[uuidPart] = count + 1
                    if (count > 0) {
                        thisDirName += " ($count)"
                    }

                    val dirMap = metadataMap[thisDirName] ?: HashMap()
                    metadataMap[thisDirName] = dirMap

                    dirMap.putAll(dir.tags.map { Pair(it.tagName, it.description) })
                }
            }
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    foundExif = metadata.directories.any { it is ExifDirectoryBase && it.tagCount > 0 }
                    foundMp4Uuid = metadata.directories.any { it is Mp4UuidBoxDirectory && it.tagCount > 0 }

                    val dirByName = metadata.directories.filter {
                        (it.tagCount > 0 || it.errorCount > 0 || it is MpEntryDirectory)
                                && it !is FileTypeDirectory
                                && it !is AviDirectory
                    }.groupBy { dir -> dir.name }

                    for ((baseDirName, sameNameDirs) in dirByName) {
                        // exclude directories known to be redundant with info derived on the Dart side
                        // they are excluded by name instead of runtime type because excluding `Mp4Directory`
                        // would also exclude derived directories, such as `Mp4UuidBoxDirectory`
                        if (allMetadataRedundantDirNames.contains(baseDirName)) continue

                        val sameNameDirCount = sameNameDirs.size
                        for (dirIndex in 0..<sameNameDirCount) {
                            val dir = sameNameDirs[dirIndex]

                            // directory name
                            var thisDirName = baseDirName
                            if (sameNameDirCount > 1 && !allMetadataMergeableDirNames.contains(baseDirName)) {
                                // optional count for multiple directories of the same type
                                thisDirName = "$thisDirName[${dirIndex + 1}]"
                            }
                            // optional parent to distinguish child directories of the same type
                            dir.parent?.name?.let { thisDirName = "$it/$thisDirName" }

                            var dirMap = metadataMap[thisDirName] ?: HashMap()
                            if (dir !is Mp4UuidBoxDirectory) {
                                metadataMap[thisDirName] = dirMap

                                // tags
                                val tags = dir.tags
                                when {
                                    dir is ExifDirectoryBase -> {
                                        when {
                                            mimeType == MimeTypes.DNG || mimeType == MimeTypes.DNG_ADOBE -> {
                                                // split DNG tags in their own directory
                                                val dngDirMap = metadataMap[DIR_DNG] ?: HashMap()
                                                metadataMap[DIR_DNG] = dngDirMap
                                                val byDng = tags.groupBy { ExifTags.isDngTag(it.tagType) }
                                                byDng[true]?.map { exifTagMapper(dir, it) }?.let { dngDirMap.putAll(it) }
                                                byDng[false]?.map { exifTagMapper(dir, it) }?.let { dirMap.putAll(it) }
                                            }

                                            else -> {
                                                dirMap.putAll(tags.filter { tag ->
                                                    when (tag.tagType) {
                                                        // skip GeoTIFF tags which contents are presented through various keys in the GeoTIFF directory
                                                        ExifDirectoryBase.TAG_GEOTIFF_GEO_KEYS,
                                                        ExifDirectoryBase.TAG_GEOTIFF_GEO_DOUBLE_PARAMS,
                                                        ExifDirectoryBase.TAG_GEOTIFF_GEO_ASCII_PARAMS -> false

                                                        else -> true
                                                    }
                                                }.map { exifTagMapper(dir, it) })
                                            }
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
                                                        StandardCharsets.UTF_8
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
                                                                profileDirMap.putAll(profileTags.map { exifTagMapper(dir, it) })
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

                                    dir is MpEntryDirectory -> {
                                        dirMap.putAll(dir.describe())
                                    }

                                    else -> dirMap.putAll(tags.map { Pair(it.tagName, it.description) })
                                }
                            }

                            if (!isLargeMp4(mimeType, sizeBytes)) {
                                if (dir is Mp4UuidBoxDirectory) {
                                    processMp4Uuid(dir)
                                }

                                if (dir is XmpDirectory) {
                                    processXmp(dir.xmpMeta, dirMap, allowMultiple = true)
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
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
            // fallback to read EXIF via `ExifInterface`
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val exifInterface = ExifInterface(input)
                    val allTags = describeAll(exifInterface).toMutableMap()
                    if (foundXmp) {
                        // do not overwrite XMP parsed by `metadata-extractor`
                        // with raw XMP found by `ExifInterface`
                        allTags.remove(Metadata.DIR_XMP)
                    } else {
                        val xmpTags = allTags[Metadata.DIR_XMP]
                        if (xmpTags != null) {
                            val xmpRaw = xmpTags[ExifInterface.TAG_XMP]
                            if (xmpRaw != null) {
                                val metadata = com.drew.metadata.Metadata()
                                val xmpBytes = xmpRaw.toByteArray(Charsets.UTF_8)
                                SafeXmpReader().extract(xmpBytes, 0, xmpBytes.size, metadata, null)
                                metadata.getFirstDirectoryOfType(XmpDirectory::class.java)?.let { xmpDir ->
                                    val dirMap = HashMap<String, String>()
                                    processXmp(xmpDir.xmpMeta, dirMap, allowMultiple = true)
                                    allTags[Metadata.DIR_XMP] = dirMap
                                }
                            }
                        }
                    }
                    metadataMap.putAll(allTags.mapValues { it.value.toMutableMap() })
                }
            } catch (e: Exception) {
                // `ExifInterface` initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for $contentAddress", e)
            }
        }

        fun fallbackProcessXmp(xmpMeta: XMPMeta) {
            val thisDirName = XmpDirectory().name
            val dirMap = metadataMap[thisDirName] ?: HashMap()
            processXmp(xmpMeta, dirMap)
            if (dirMap.isNotEmpty()) {
                metadataMap[thisDirName] = dirMap
            }
        }

        XMP.checkIsoBMFFImage(context, contentAddress, foundXmp, ::fallbackProcessXmp)
        // `metadata-extractor` may fail to get UUID boxes for some MP4 files,
        // so we always check with `mp4parser`, even for smaller files
        XMP.checkMp4(context, contentAddress) { dirs ->
            for (dir in dirs.filterIsInstance<XmpDirectory>()) {
                fallbackProcessXmp(dir.xmpMeta)
            }
            if (!foundMp4Uuid) {
                for (dir in dirs.filterIsInstance<Mp4UuidBoxDirectory>()) {
                    processMp4Uuid(dir)
                }
            }
        }

        if (isVideo(mimeType)) {
            // `metadata-extractor` do not extract custom tags in user data box
            Mp4ParserHelper.getUserDataBox(context, contentAddress)?.let { box ->
                metadataMap[Metadata.DIR_MP4_USER_DATA] = Mp4ParserHelper.extractBoxFields(box)
            }

            // this is used as fallback when the video metadata cannot be found on the Dart side
            // and to identify whether there is an accessible cover image
            // do not include HEIC here
            val mediaDir = getAllMetadataByMediaMetadataRetriever(contentAddress)
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
        } else if (isIsoBMFFImage(mimeType)) {
            Mp4ParserHelper.getSamsungSefd(context, contentAddress.uri)?.let { (_, bytes) ->
                metadataMap[Mp4ParserHelper.SAMSUNG_MAKERNOTE_BOX_TYPE] = hashMapOf(
                    "Size" to bytes.size.toString(),
                )
            }
        }

        if (metadataMap.isNotEmpty()) {
            result.success(metadataMap)
        } else {
            result.error("getAllMetadata-failure", "failed to get metadata for $contentAddress", null)
        }
    }

    private fun getAllMetadataByMediaMetadataRetriever(contentAddress: ContentAddress): MutableMap<String, String> {
        val dirMap = HashMap<String, String>()
        val retriever = StorageUtils.openMetadataRetriever(context, contentAddress) ?: return dirMap
        try {
            for ((code, name) in MediaMetadataRetrieverHelper.allKeys) {
                retriever.getSafeDescription(code) { dirMap[name] = it }
            }
            if (retriever.embeddedPicture != null) {
                // additional key for the Dart side to know whether to add a `Cover` section
                dirMap[KEY_HAS_EMBEDDED_PICTURE] = "yes"
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get video metadata by MediaMetadataRetriever for $contentAddress", e)
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
    // set `KEY_XMP_TITLE` from these fields (by precedence):
    // - XMP / dc:title
    // - IPTC / object-name
    // set `KEY_XMP_SUBJECTS` from these fields (by precedence):
    // - XMP / dc:subject
    // - IPTC / keywords
    // set `KEY_RATING` from these fields (by precedence):
    // - XMP / xmp:Rating
    // - XMP / MicrosoftPhoto:Rating
    private fun getCatalogMetadata(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (contentAddress == null) {
            result.error("getCatalogMetadata-args", "missing arguments", null)
            return
        }

        val beforeAvailableHeapSize = MemoryUtils.getAvailableHeapSize()

        val metadataMap = HashMap<String, Any>()
        getCatalogMetadataByMetadataExtractor(contentAddress, sizeBytes, metadataMap)

        val mimeType = contentAddress.mimeType
        if (isVideo(mimeType) || isIsoBMFFImage(mimeType)) {
            getMultimediaCatalogMetadataByMediaMetadataRetriever(contentAddress, metadataMap)

            // fallback to MP4 `loci` box for location
            if (!metadataMap.contains(KEY_LATITUDE) || !metadataMap.contains(KEY_LONGITUDE)) {
                try {
                    Mp4ParserHelper.getUserDataBox(context, contentAddress)?.let { userDataBox ->
                        Path.getPath<LocationInformationBox>(userDataBox, LocationInformationBox.TYPE)?.let { locationBox ->
                            if (!locationBox.isParsed) {
                                locationBox.parseDetails()
                            }
                            metadataMap[KEY_LATITUDE] = locationBox.latitude
                            metadataMap[KEY_LONGITUDE] = locationBox.longitude
                        }
                    }
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to get Location Information box by MP4 parser for $contentAddress", e)
                }
            }
        }

        if (isIsoBMFFImage(mimeType)) {
            val flags = (metadataMap[KEY_FLAGS] ?: 0) as Int
            if ((flags and MASK_IS_MOTION_PHOTO == 0) && MultiPage.isIsoBMFFImageSefdMotionPhoto(context, contentAddress.uri)) {
                metadataMap[KEY_FLAGS] = flags or MASK_IS_MULTIPAGE or MASK_IS_MOTION_PHOTO
            }
        }

        val afterAvailableHeapSize = MemoryUtils.getAvailableHeapSize()
        val diff = beforeAvailableHeapSize - afterAvailableHeapSize
        if (diff > LARGE_HEAP_USAGE_THRESHOLD) {
            Log.d(
                LOG_TAG, "Large heap usage for cataloguing" +
                        ": used ${diff shr 20}MB for entry size=${if (sizeBytes != null) sizeBytes shr 20 else 0}MB" +
                        " (x${if (sizeBytes != null) (diff.toDouble() / sizeBytes).round(2) else 0})" +
                        " $contentAddress"
            )
            MemoryUtils.requestGarbageCollection()
        }

        fun addCredentialsFlags(contentAddress: ContentAddress, existingFlags: Int): Int {
            var flags = existingFlags

            val validity = C2paHelper.getValidity(contentAddress)

            if (validity == C2paValidity.UNKNOWN) return flags
            flags = flags or MASK_ARE_CREDENTIALS_PRESENT

            if (validity == C2paValidity.INVALID) return flags
            flags = flags or MASK_ARE_CREDENTIALS_VALID

            if (validity == C2paValidity.VALID) return flags
            flags = flags or MASK_ARE_CREDENTIALS_TRUSTED

            return flags
        }

        metadataMap[KEY_FLAGS] = addCredentialsFlags(contentAddress, (metadataMap[KEY_FLAGS] ?: 0) as Int)

        // report success even when empty
        result.success(metadataMap)
    }

    private fun getCatalogMetadataByMetadataExtractor(
        sourceContentAddress: ContentAddress,
        sizeBytes: Long?,
        metadataMap: HashMap<String, Any>,
    ) {
        val mimeType = MetadataExtractorHelper.readMimeType(context, sourceContentAddress, sizeBytes)
        val uri = sourceContentAddress.uri
        val path = sourceContentAddress.path
        val contentAddress = ContentAddress(mimeType = mimeType, uri = uri, path = path, pageId = sourceContentAddress.pageId)

        metadataMap[KEY_MIME_TYPE] = mimeType

        var flags = (metadataMap[KEY_FLAGS] ?: 0) as Int
        var foundExif = false
        var foundXmp = false
        var foundMp4Uuid = false

        fun processXmp(xmpMeta: XMPMeta, allowMultiple: Boolean = false) {
            if (foundXmp && !allowMultiple) return
            foundXmp = true
            try {
                if (xmpMeta.doesPropExist(XMP.DC_SUBJECT_PROP_NAME)) {
                    val values = xmpMeta.getPropArrayItemValues(XMP.DC_SUBJECT_PROP_NAME)
                    metadataMap[KEY_XMP_SUBJECTS] = values.joinToString(XMP_SUBJECTS_SEPARATOR)
                }
                xmpMeta.getSafeLocalizedText(XMP.DC_TITLE_PROP_NAME, acceptBlank = false) { metadataMap[KEY_XMP_TITLE] = it }
                if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                    xmpMeta.getSafeDateMillis(XMP.XMP_CREATE_DATE_PROP_NAME) { date, offset ->
                        run {
                            metadataMap[KEY_DATE_MILLIS] = date
                            offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                        }
                    }
                    if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                        xmpMeta.getSafeDateMillis(XMP.PS_DATE_CREATED_PROP_NAME) { date, offset ->
                            run {
                                metadataMap[KEY_DATE_MILLIS] = date
                                offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                            }
                        }
                    }
                }

                xmpMeta.getSafeInt(XMP.XMP_RATING_PROP_NAME) { metadataMap[KEY_RATING] = it }
                if (!metadataMap.containsKey(KEY_RATING)) {
                    xmpMeta.getSafeInt(XMP.MS_RATING_PROP_NAME) { percentRating ->
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
                    flags = flags or MASK_IS_MULTIPAGE or MASK_IS_MOTION_PHOTO
                }

                // identification of embedded gain map
                if (xmpMeta.hasHdrGainMap()) {
                    flags = flags or MASK_IS_HDR
                }
            } catch (e: XMPException) {
                Log.w(LOG_TAG, "failed to read XMP directory for $contentAddress", e)
            }
        }

        fun processMp4Uuid(dir: Mp4UuidBoxDirectory) {
            // identification of spherical video (aka 360° video)
            if (dir.getString(Mp4UuidBoxDirectory.TAG_UUID) == GSpherical.SPHERICAL_VIDEO_V1_UUID) {
                flags = flags or MASK_IS_360
            }
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    foundExif = metadata.directories.any { it is ExifDirectoryBase && it.tagCount > 0 }
                    foundMp4Uuid = metadata.directories.any { it is Mp4UuidBoxDirectory && it.tagCount > 0 }

                    // EXIF
                    for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                        dir.getDateOriginalMillis { date, offset ->
                            run {
                                metadataMap[KEY_DATE_MILLIS] = date
                                offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                            }
                        }
                        if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                            // fetch date modified from SubIFD directory first, as the sub-second tag is here
                            dir.getDateModifiedMillis { date, offset ->
                                run {
                                    metadataMap[KEY_DATE_MILLIS] = date
                                    offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                                }
                            }
                        }
                    }
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                            // fallback to fetch date modified from IFD0 directory,
                            // without the sub-second tag nor the time zone offset tag,
                            // in case there was no SubIFD directory
                            dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME, null, isUtc = true)?.let { date ->
                                metadataMap[KEY_DATE_MILLIS] = date
                                metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = TimeZones.currentOffsetMinutes
                            }
                        }
                        dir.getSafeInt(ExifDirectoryBase.TAG_ORIENTATION) { orientation ->
                            if (isFlippedForExifCode(orientation)) {
                                flags = flags or MASK_IS_FLIPPED
                            }
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

                    // JPEG Multi-Picture Format
                    if (metadata.getDirectoriesOfType(MpEntryDirectory::class.java).count { !it.entry.isThumbnail } > 1) {
                        flags = flags or MASK_IS_MULTIPAGE

                        if (hasAppleHdrGainMap(contentAddress, sizeBytes)) {
                            flags = flags or MASK_IS_HDR
                        }
                    }

                    // XMP
                    if (!isLargeMp4(mimeType, sizeBytes)) {
                        metadata.getDirectoriesOfType(XmpDirectory::class.java).map { it.xmpMeta }.forEach {
                            processXmp(it, allowMultiple = true)
                        }

                        // XMP fallback to IPTC
                        if (!metadataMap.containsKey(KEY_XMP_TITLE) || !metadataMap.containsKey(KEY_XMP_SUBJECTS)) {
                            for (dir in metadata.getDirectoriesOfType(IptcDirectory::class.java)) {
                                if (!metadataMap.containsKey(KEY_XMP_TITLE)) {
                                    dir.getSafeString(IptcDirectory.TAG_OBJECT_NAME, acceptBlank = false) { metadataMap[KEY_XMP_TITLE] = it }
                                }
                                if (!metadataMap.containsKey(KEY_XMP_SUBJECTS)) {
                                    dir.keywords?.let { metadataMap[KEY_XMP_SUBJECTS] = it.joinToString(XMP_SUBJECTS_SEPARATOR) }
                                }
                            }
                        }
                    }

                    if (!metadataMap.containsKey(KEY_LATITUDE) || !metadataMap.containsKey(KEY_LONGITUDE)) {
                        for (dir in metadata.getDirectoriesOfType(QuickTimeMetadataDirectory::class.java)) {
                            dir.getSafeString(QuickTimeMetadataDirectory.TAG_LOCATION_ISO6709) { locationString ->
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
                    }

                    when (mimeType) {
                        MimeTypes.PNG -> {
                            // date fallback to PNG time chunk
                            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                                for (dir in metadata.getDirectoriesOfType(PngDirectory::class.java).filter { it.name == PNG_TIME_DIR_NAME }) {
                                    dir.getSafeString(PngDirectory.TAG_LAST_MODIFICATION_TIME) {
                                        try {
                                            val date = LocalDateTime.parse(it, PNG_LAST_MODIFICATION_TIME_FORMAT).toUtcEpochMillis()
                                            metadataMap[KEY_DATE_MILLIS] = date
                                            metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = TimeZones.currentOffsetMinutes
                                        } catch (e: ParseException) {
                                            Log.w(LOG_TAG, "failed to parse PNG date=$it for uri=$uri path=$path", e)
                                        }
                                    }
                                }
                            }

                            // identification of animated PNG
                            if (metadata.containsDirectoryOfType(PngActlDirectory::class.java)) {
                                flags = flags or MASK_IS_ANIMATED
                            }
                        }

                        MimeTypes.GIF -> {
                            // identification of animated GIF
                            if (metadata.containsDirectoryOfType(GifAnimationDirectory::class.java)) {
                                flags = flags or MASK_IS_ANIMATED
                            }
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
                            if (metadata.containsDirectoryOfType(GeoTiffDirectory::class.java)) {
                                flags = flags or MASK_IS_GEOTIFF
                            }
                        }
                    }

                    metadata.getDirectoriesOfType(Mp4UuidBoxDirectory::class.java).forEach(::processMp4Uuid)
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
            // fallback to read EXIF via `ExifInterface`
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val exifInterface = ExifInterface(input)
                    exifInterface.getSafeDateMillis(
                        ExifInterface.TAG_DATETIME_ORIGINAL,
                        ExifInterface.TAG_SUBSEC_TIME_ORIGINAL,
                        ExifInterface.TAG_OFFSET_TIME_ORIGINAL,
                    ) { date, offset ->
                        metadataMap[KEY_DATE_MILLIS] = date
                        offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                    }
                    if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                        exifInterface.getSafeDateMillis(
                            ExifInterface.TAG_DATETIME,
                            ExifInterface.TAG_SUBSEC_TIME,
                            ExifInterface.TAG_OFFSET_TIME,
                        ) { date, offset ->
                            metadataMap[KEY_DATE_MILLIS] = date
                            offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                        }
                    }
                    exifInterface.getSafeInt(ExifInterface.TAG_ORIENTATION, acceptZero = false) {
                        if (exifInterface.isFlipped) flags = flags or MASK_IS_FLIPPED
                        metadataMap[KEY_ROTATION_DEGREES] = exifInterface.rotationDegrees
                    }
                    val latLong = exifInterface.latLong
                    if (latLong?.size == 2) {
                        metadataMap[KEY_LATITUDE] = latLong[0]
                        metadataMap[KEY_LONGITUDE] = latLong[1]
                    }
                }
            } catch (e: Exception) {
                // `ExifInterface` initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for mimeType=$mimeType uri=$uri path=$path", e)
            }
        }

        XMP.checkIsoBMFFImage(context, contentAddress, foundXmp, ::processXmp)
        // `metadata-extractor` may fail to get UUID boxes for some MP4 files,
        // so we always check with `mp4parser`, even for smaller files
        XMP.checkMp4(context, contentAddress) { dirs ->
            for (dir in dirs.filterIsInstance<XmpDirectory>()) {
                processXmp(dir.xmpMeta)
            }
            if (!foundMp4Uuid) {
                for (dir in dirs.filterIsInstance<Mp4UuidBoxDirectory>()) {
                    processMp4Uuid(dir)
                }
            }
        }

        if (mimeType == MimeTypes.TIFF && MultiPage.isMultiPageTiff(context, uri)) flags = flags or MASK_IS_MULTIPAGE

        metadataMap[KEY_FLAGS] = flags
    }

    private fun hasAppleHdrGainMap(contentAddress: ContentAddress, sizeBytes: Long?): Boolean {
        val uri = contentAddress.uri
        val path = contentAddress.path

        val mpEntries = MultiPage.getJpegMpfEntries(context, contentAddress, sizeBytes) ?: return false
        mpEntries.filter { it.type == MpEntry.TYPE_UNDEFINED }.forEachIndexed { mpIndex, mpEntry ->
            var dataOffset = mpEntry.dataOffset
            if (dataOffset > 0) {
                val baseOffset = MultiPage.getJpegMpfBaseOffset(context, contentAddress, sizeBytes)
                if (baseOffset != null) {
                    dataOffset += baseOffset
                }
            }
            StorageUtils.openInputStream(context, uri)?.let { input ->
                input.skip(dataOffset)
                try {
                    val pageMetadata = MetadataExtractorHelper.safeRead(input, sizeBytes, path)
                    if (pageMetadata.getDirectoriesOfType(XmpDirectory::class.java).any { it.xmpMeta.hasHdrGainMap() }) {
                        return true
                    }
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress mpIndex=$mpIndex mpEntry=$mpEntry", e)
                }
            }
        }
        return false
    }

    private fun getMultimediaCatalogMetadataByMediaMetadataRetriever(
        contentAddress: ContentAddress,
        metadataMap: HashMap<String, Any>,
    ) {
        val mimeType = contentAddress.mimeType

        val retriever = StorageUtils.openMetadataRetriever(context, contentAddress) ?: return

        var flags = (metadataMap[KEY_FLAGS] ?: 0) as Int
        try {
            retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) { metadataMap[KEY_ROTATION_DEGREES] = it }
            if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                retriever.getSafeDateMillis(MediaMetadataRetriever.METADATA_KEY_DATE) { date, offset ->
                    metadataMap[KEY_DATE_MILLIS] = date
                    offset?.let { metadataMap[KEY_TIME_ZONE_OFFSET_MINUTES] = it }
                }
            }

            if (!metadataMap.containsKey(KEY_LATITUDE) || !metadataMap.containsKey(KEY_LONGITUDE)) {
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

            if (isIsoBMFFImage(mimeType)) {
                retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS) {
                    if (it > 1) flags = flags or MASK_IS_MULTIPAGE
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                retriever.getSafeInt(MediaMetadataRetriever.METADATA_KEY_COLOR_TRANSFER) {
                    if (it == MediaFormat.COLOR_TRANSFER_ST2084 || it == MediaFormat.COLOR_TRANSFER_HLG) {
                        flags = flags or MASK_IS_HDR
                    }
                }
            }

            if (isVideo(mimeType)) {
                retriever.getSafeDouble(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE) {
                    if (it >= SLOW_MOTION_MIN_CAPTURE_FRAME_RATE) flags = flags or MASK_IS_SLOW_MOTION
                }
            }

            metadataMap[KEY_FLAGS] = flags
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get catalog metadata by MediaMetadataRetriever for $contentAddress", e)
        } finally {
            // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
            retriever.release()
        }
    }

    private fun getOverlayMetadata(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val fields = call.argument<List<String>>("fields")
        if (contentAddress == null || fields == null) {
            result.error("getOverlayMetadata-args", "missing arguments", null)
            return
        }

        val mimeType = contentAddress.mimeType
        val metadataMap = HashMap<String, Any>()
        if (fields.isEmpty() || isVideo(mimeType)) {
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
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                        foundExif = true
                        if (fields.contains(KEY_APERTURE)) {
                            dir.getSafeRational(ExifDirectoryBase.TAG_FNUMBER) { metadataMap[KEY_APERTURE] = it.numerator.toDouble() / it.denominator }
                        }
                        if (fields.contains(KEY_DESCRIPTION)) {
                            getDescriptionByMetadataExtractor(metadata)?.let { metadataMap[KEY_DESCRIPTION] = it }
                        }
                        if (fields.contains(KEY_EXPOSURE_TIME)) {
                            dir.getSafeRational(ExifDirectoryBase.TAG_EXPOSURE_TIME, saveExposureTime)
                        }
                        if (fields.contains(KEY_FOCAL_LENGTH)) {
                            dir.getSafeRational(ExifDirectoryBase.TAG_FOCAL_LENGTH) { metadataMap[KEY_FOCAL_LENGTH] = it.numerator.toDouble() / it.denominator }
                        }
                        if (fields.contains(KEY_ISO)) {
                            dir.getSafeInt(ExifDirectoryBase.TAG_ISO_EQUIVALENT) { metadataMap[KEY_ISO] = it }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
            // fallback to read EXIF via `ExifInterface`
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val exifInterface = ExifInterface(input)
                    if (fields.contains(KEY_APERTURE)) {
                        exifInterface.getSafeDouble(ExifInterface.TAG_F_NUMBER) { metadataMap[KEY_APERTURE] = it }
                    }
                    if (fields.contains(KEY_EXPOSURE_TIME)) {
                        exifInterface.getSafeRational(ExifInterface.TAG_EXPOSURE_TIME, saveExposureTime)
                    }
                    if (fields.contains(KEY_FOCAL_LENGTH)) {
                        exifInterface.getSafeDouble(ExifInterface.TAG_FOCAL_LENGTH) { metadataMap[KEY_FOCAL_LENGTH] = it }
                    }
                    if (fields.contains(KEY_ISO)) {
                        exifInterface.getSafeInt(ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY) { metadataMap[KEY_ISO] = it }
                    }
                }
            } catch (e: Exception) {
                // `ExifInterface` initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for $contentAddress", e)
            }
        }

        result.success(metadataMap)
    }

    // returns description from these fields (by precedence):
    // - XMP / dc:description
    // - IPTC / caption-abstract
    // - Exif / UserComment
    // - Exif / ImageDescription
    private fun getDescriptionByMetadataExtractor(metadata: com.drew.metadata.Metadata): String? {
        var description: String? = null
        for (dir in metadata.getDirectoriesOfType(XmpDirectory::class.java)) {
            val xmpMeta = dir.xmpMeta
            try {
                if (xmpMeta.doesPropExist(XMP.DC_DESCRIPTION_PROP_NAME)) {
                    xmpMeta.getSafeLocalizedText(XMP.DC_DESCRIPTION_PROP_NAME, acceptBlank = false) { description = it }
                }
            } catch (e: XMPException) {
                Log.w(LOG_TAG, "failed to read XMP directory", e)
            }
        }
        if (description == null) {
            for (dir in metadata.getDirectoriesOfType(IptcDirectory::class.java)) {
                dir.getSafeString(IptcDirectory.TAG_CAPTION, acceptBlank = false) { description = it }
            }
        }
        if (description == null) {
            for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                // user comment field specifies encoding, unlike other string fields
                if (dir.containsTag(ExifSubIFDDirectory.TAG_USER_COMMENT)) {
                    val string = dir.getDescription(ExifSubIFDDirectory.TAG_USER_COMMENT)
                    if (string.isNotBlank()) {
                        description = string
                    }
                }
            }
        }
        if (description == null) {
            for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                dir.getSafeString(ExifIFD0Directory.TAG_IMAGE_DESCRIPTION, acceptBlank = false) { description = it }
            }
        }
        return description
    }

    /*
        returns map of GeoTIFF tag/key codes to various types:
          - GeoTiffExifTags.modelPixelScale -> double list
          - GeoTiffExifTags.modelTiePoints -> double list
          - GeoTiffExifTags.modelTransformation -> double list
          - GeoTiffKeys.projCSType -> int
          - GeoTiffKeys.projLinearUnits -> int
     */
    private fun getGeoTiffInfo(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (contentAddress == null) {
            result.error("getGeoTiffInfo-args", "missing arguments", null)
            return
        }

        if (canReadWithMetadataExtractor(contentAddress.mimeType)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    val fields = HashMap<Int, Any?>()
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        fields.putAll(dir.tags.map { it.tagType }.filter { tagType ->
                            when (tagType) {
                                ExifDirectoryBase.TAG_PIXEL_SCALE,
                                ExifDirectoryBase.TAG_MODEL_TIE_POINT,
                                ExifDirectoryBase.TAG_MODEL_TRANSFORMATION,
                                    -> true

                                else -> false
                            }
                        }.map { Pair(it, dir.getObject(it)) })
                    }
                    for (dir in metadata.getDirectoriesOfType(GeoTiffDirectory::class.java)) {
                        fields.putAll(dir.tags.map { it.tagType }.filter { tagType ->
                            when (tagType) {
                                GeoTiffDirectory.TAG_PROJECTED_CS_TYPE,
                                GeoTiffDirectory.TAG_PROJ_LINEAR_UNITS,
                                    -> true

                                else -> false
                            }
                        }.map { Pair(it, dir.getObject(it)) })
                    }
                    result.success(fields)
                    return
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }
        result.error("getGeoTiffInfo-empty", "failed to get info for $contentAddress", null)
    }

    private fun getMultiPageInfo(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val isMotionPhoto = call.argument<Boolean>("isMotionPhoto")
        if (contentAddress == null || sizeBytes == null || isMotionPhoto == null) {
            result.error("getMultiPageInfo-args", "missing arguments", null)
            return
        }

        val pages: ArrayList<FieldMap>? = if (isMotionPhoto) {
            MultiPage.getMotionPhotoPages(context, contentAddress, sizeBytes)
        } else {
            when (contentAddress.mimeType) {
                MimeTypes.HEIC,
                MimeTypes.HEIC_SEQUENCE,
                MimeTypes.HEIF -> MultiPage.getHeicTracks(context, contentAddress.uri)

                MimeTypes.JPEG -> MultiPage.getJpegMpfPages(context, contentAddress, sizeBytes)
                MimeTypes.TIFF -> MultiPage.getTiffPages(context, contentAddress.uri)
                else -> null
            }
        }
        if (pages?.isEmpty() == true) {
            result.error("getMultiPageInfo-empty", "failed to get pages for $contentAddress", null)
        } else {
            result.success(pages)
        }
    }

    private fun getPanoramaInfo(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (contentAddress == null) {
            result.error("getPanoramaInfo-args", "missing arguments", null)
            return
        }

        val fields: FieldMap = hashMapOf()
        var foundXmp = false

        fun processXmp(xmpMeta: XMPMeta, allowMultiple: Boolean = false) {
            if (foundXmp && !allowMultiple) return
            foundXmp = true
            fields.putAll(GoogleXMP.getPanoramaInfo(xmpMeta))
        }

        val mimeType = contentAddress.mimeType
        if (canReadWithMetadataExtractor(mimeType) && !isLargeMp4(mimeType, sizeBytes)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    metadata.getDirectoriesOfType(XmpDirectory::class.java).map { it.xmpMeta }.forEach {
                        processXmp(it, allowMultiple = true)
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        XMP.checkIsoBMFFImage(context, contentAddress, foundXmp, ::processXmp)
        // `metadata-extractor` may fail to get UUID boxes for some MP4 files,
        // so we always check with `mp4parser`, even for smaller files
        XMP.checkMp4(context, contentAddress) { dirs ->
            for (dir in dirs.filterIsInstance<XmpDirectory>()) {
                processXmp(dir.xmpMeta)
            }
        }

        if (fields.isEmpty()) {
            result.error("getPanoramaInfo-empty", "failed to get info for $contentAddress", null)
        } else {
            fields["projectionType"] = fields["projectionType"] ?: GoogleXMP.GPANO_PROJECTION_TYPE_DEFAULT
            result.success(fields)
        }
    }

    private fun getIptc(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        if (contentAddress == null) {
            result.error("getIptc-args", "missing arguments", null)
            return
        }

        if (MimeTypes.canReadWithPixyMeta(contentAddress.mimeType)) {
            try {
                StorageUtils.openInputStream(context, contentAddress.uri)?.use { input ->
                    val iptcDataList = PixyMetaHelper.getIptc(input)
                    result.success(iptcDataList)
                    return
                }
            } catch (e: Exception) {
                result.error("getIptc-exception", "failed to read IPTC for $contentAddress", e.stackTraceToString())
                return
            }
        }

        result.success(null)
    }

    // returns XMP components
    // returns an empty list if there is no XMP
    private fun getXmp(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (contentAddress == null) {
            result.error("getXmp-args", "missing arguments", null)
            return
        }

        val xmpStrings = mutableListOf<String>()
        var foundXmp = false

        fun processXmp(xmpMeta: XMPMeta, allowMultiple: Boolean = false) {
            if (foundXmp && !allowMultiple) return
            foundXmp = true
            try {
                xmpStrings.add(XMPMetaFactory.serializeToString(xmpMeta, xmpSerializeOptions))
            } catch (e: XMPException) {
                Log.w(LOG_TAG, "failed to read XMP directory for $contentAddress", e)
            }
        }

        val mimeType = contentAddress.mimeType
        if (canReadWithMetadataExtractor(mimeType) && !isLargeMp4(mimeType, sizeBytes)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    metadata.getDirectoriesOfType(XmpDirectory::class.java).map { it.xmpMeta }.forEach {
                        processXmp(it, allowMultiple = true)
                    }
                }
            } catch (e: Exception) {
                result.error("getXmp-exception", "failed to read XMP for $contentAddress", e.stackTraceToString())
                return
            } catch (e: NoClassDefFoundError) {
                result.error("getXmp-noclass", "failed to read XMP for $contentAddress", e.stackTraceToString())
                return
            } catch (e: AssertionError) {
                result.error("getXmp-assert", "failed to read XMP for $contentAddress", e.stackTraceToString())
                return
            }
        }

        XMP.checkIsoBMFFImage(context, contentAddress, foundXmp, ::processXmp)
        // `metadata-extractor` may fail to get UUID boxes for some MP4 files,
        // so we always check with `mp4parser`, even for smaller files
        XMP.checkMp4(context, contentAddress) { dirs ->
            for (dir in dirs.filterIsInstance<XmpDirectory>()) {
                processXmp(dir.xmpMeta)
            }
        }

        result.success(xmpStrings)
    }

    private fun hasContentProp(call: MethodCall, result: MethodChannel.Result) {
        val prop = call.argument<String>("prop")
        if (prop == null) {
            result.error("hasContentProp-args", "missing arguments", null)
            return
        }

        result.success(
            when (prop) {
                "owner_package_name" -> Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
                else -> {
                    result.error("hasContentProp-unknown", "unknown property=$prop", null)
                    return
                }
            }
        )
    }

    private fun getContentPropValue(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val prop = call.argument<String>("prop")
        if (contentAddress == null || prop == null) {
            result.error("getContentPropValue-args", "missing arguments", null)
            return
        }

        try {
            val value = context.queryContentPropValue(contentAddress.uri, contentAddress.mimeType, prop)
            result.success(value?.toString())
        } catch (e: Exception) {
            result.error("getContentPropValue-query", "failed to query prop for $contentAddress", e.stackTraceToString())
        }
    }

    private fun getDate(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val field = call.argument<String>("field")
        if (contentAddress == null || field == null) {
            result.error("getDate-args", "missing arguments", null)
            return
        }

        var dateMillis: Long? = null
        var offsetMinutes: Int? = null
        if (canReadWithMetadataExtractor(contentAddress.mimeType)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
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
                                dir.getDateModifiedMillis { date, offset ->
                                    run {
                                        dateMillis = date
                                        offsetMinutes = offset
                                    }
                                }
                            }
                            if (dateMillis == null) {
                                // fallback to fetch date modified from IFD0 directory,
                                // without the sub-second tag nor the time zone offset tag,
                                // in case there was no SubIFD directory
                                for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                                    dir.getSafeDateMillis(ExifIFD0Directory.TAG_DATETIME, null, isUtc = true)?.let {
                                        dateMillis = it
                                        offsetMinutes = TimeZones.currentOffsetMinutes
                                    }
                                }
                            }
                        }

                        ExifSubIFDDirectory.TAG_DATETIME_DIGITIZED -> {
                            for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                                dir.getDateDigitizedMillis { date, offset ->
                                    run {
                                        dateMillis = date
                                        offsetMinutes = offset
                                    }
                                }
                            }
                        }

                        ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL -> {
                            for (dir in metadata.getDirectoriesOfType(ExifSubIFDDirectory::class.java)) {
                                dir.getDateOriginalMillis { date, offset ->
                                    run {
                                        dateMillis = date
                                        offsetMinutes = offset
                                    }
                                }
                            }
                        }

                        GpsDirectory.TAG_DATE_STAMP -> {
                            for (dir in metadata.getDirectoriesOfType(GpsDirectory::class.java)) {
                                dir.gpsDate?.let {
                                    dateMillis = it.time
                                    offsetMinutes = TimeZones.currentOffsetMinutes
                                }
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        val fields: FieldMap = hashMapOf(
            KEY_DATE_MILLIS to dateMillis,
            KEY_TIME_ZONE_OFFSET_MINUTES to offsetMinutes,
        )

        result.success(fields)
    }

    private fun getFields(call: MethodCall, result: MethodChannel.Result) {
        val contentAddress = ContentAddress.fromMethodCall(call)
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val fields = call.argument<List<String>>("fields")
        if (contentAddress == null || fields == null) {
            result.error("getFields-args", "missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, Any?>()

        val hashFields = fields.filter { it.startsWith(HASH_FIELD_PREFIX) }.toSet()
        metadataMap.putAll(getHashFields(contentAddress, sizeBytes, hashFields))

        val exifFields = fields.filterNot { hashFields.contains(it) }.toSet()
        metadataMap.putAll(getExifFields(contentAddress, sizeBytes, exifFields))

        result.success(metadataMap)
    }

    private fun getHashFields(contentAddress: ContentAddress, sizeBytes: Long?, fields: Set<String>): FieldMap {
        val metadataMap = HashMap<String, Any?>()
        fields.forEach { field ->
            val function = field.substringAfter(HASH_FIELD_PREFIX).lowercase(Locale.ROOT)
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    metadataMap[field] = HashUtils.getHash(input, function)
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get hash for $contentAddress function=$function", e)
            }
        }
        return metadataMap
    }

    private fun getExifFields(contentAddress: ContentAddress, sizeBytes: Long?, fields: Set<String>): FieldMap {
        val mimeType = contentAddress.mimeType

        val metadataMap = HashMap<String, Any?>()
        if (fields.isEmpty() || isVideo(mimeType)) {
            return metadataMap
        }

        var foundExif = false
        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    for (dir in metadata.getDirectoriesOfType(ExifDirectoryBase::class.java)) {
                        foundExif = true
                        val allTags = ExifInterfaceHelper.allTags
                        fields.forEach { tag ->
                            allTags[tag]?.let { mapper ->
                                val tagType = mapper.type
                                dir.getDescription(tagType)?.let { value -> metadataMap[tag] = value }
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        if (!foundExif && canReadWithExifInterface(mimeType)) {
            // fallback to read EXIF via `ExifInterface`
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val exifInterface = ExifInterface(input)
                    fields.forEach { tag ->
                        if (exifInterface.hasAttribute(tag)) {
                            val value = exifInterface.getAttribute(tag)
                            if (value != null) {
                                metadataMap[tag] = value
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // `ExifInterface` initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for $contentAddress", e)
            }
        }

        return metadataMap
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<MetadataFetchHandler>()
        const val CHANNEL = "deckers.thibault/aves/metadata_fetch"

        private const val SLOW_MOTION_MIN_CAPTURE_FRAME_RATE = 120
        private const val LARGE_HEAP_USAGE_THRESHOLD = 15 * (1 shl 20) // MiB

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

        private fun isLargeMp4(mimeType: String, sizeBytes: Long?) = mimeType == MimeTypes.MP4 && Metadata.isDangerouslyLarge(sizeBytes)

        private fun exifTagMapper(dir: Directory, tag: Tag): Pair<String, String> {
            return Pair(MetadataExtractorHelper.getTagName(tag), MetadataExtractorHelper.getTagDescription(dir, tag))
        }

        // catalog metadata
        private const val KEY_MIME_TYPE = "mimeType"
        private const val KEY_DATE_MILLIS = "dateMillis"
        private const val KEY_TIME_ZONE_OFFSET_MINUTES = "timeZoneOffsetMinutes"
        private const val KEY_FLAGS = "flags"
        private const val KEY_ROTATION_DEGREES = "rotationDegrees"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
        private const val KEY_XMP_SUBJECTS = "xmpSubjects"
        private const val KEY_XMP_TITLE = "xmpTitle"
        private const val KEY_RATING = "rating"

        private const val MASK_IS_ANIMATED = 1 shl 0
        private const val MASK_IS_FLIPPED = 1 shl 1
        private const val MASK_IS_GEOTIFF = 1 shl 2
        private const val MASK_IS_360 = 1 shl 3
        private const val MASK_IS_MULTIPAGE = 1 shl 4
        private const val MASK_IS_MOTION_PHOTO = 1 shl 5
        private const val MASK_IS_HDR = 1 shl 6 // for images: embedded HDR gainmap, for videos: HDR color transfer
        private const val MASK_IS_SLOW_MOTION = 1 shl 7
        private const val MASK_ARE_CREDENTIALS_PRESENT = 1 shl 8
        private const val MASK_ARE_CREDENTIALS_VALID = 1 shl 9
        private const val MASK_ARE_CREDENTIALS_TRUSTED = 1 shl 10
        private const val XMP_SUBJECTS_SEPARATOR = ";"

        // overlay metadata
        private const val KEY_APERTURE = "aperture"
        private const val KEY_DESCRIPTION = "description"
        private const val KEY_EXPOSURE_TIME = "exposureTime"
        private const val KEY_FOCAL_LENGTH = "focalLength"
        private const val KEY_ISO = "iso"

        // additional media key
        private const val KEY_HAS_EMBEDDED_PICTURE = "Has Embedded Picture"

        private const val HASH_FIELD_PREFIX = "hash"
        private const val VALUE_SKIPPED_DATA = "[skipped]"
    }
}
