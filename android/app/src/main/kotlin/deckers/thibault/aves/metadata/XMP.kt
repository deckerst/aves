package deckers.thibault.aves.metadata

import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import com.adobe.internal.xmp.XMPError
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta
import com.adobe.internal.xmp.XMPMetaFactory
import com.adobe.internal.xmp.properties.XMPProperty
import com.drew.metadata.Directory
import deckers.thibault.aves.metadata.Mp4ParserHelper.processBoxes
import deckers.thibault.aves.metadata.Mp4ParserHelper.toBytes
import deckers.thibault.aves.metadata.metadataextractor.SafeMp4UuidBoxHandler
import deckers.thibault.aves.metadata.metadataextractor.SafeXmpReader
import deckers.thibault.aves.utils.ContextUtils.queryContentPropValue
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import org.mp4parser.IsoFile
import org.mp4parser.boxes.UserBox
import java.io.FileInputStream
import java.util.TimeZone

object XMP {
    private val LOG_TAG = LogUtils.createTag<XMP>()

    // BE7ACFCB 97A942E8 9C719994 91E3AFAC / BE7ACFCB-97A9-42E8-9C71-999491E3AFAC
    val mp4Uuid = byteArrayOf(0xbe.toByte(), 0x7a, 0xcf.toByte(), 0xcb.toByte(), 0x97.toByte(), 0xa9.toByte(), 0x42, 0xe8.toByte(), 0x9c.toByte(), 0x71, 0x99.toByte(), 0x94.toByte(), 0x91.toByte(), 0xe3.toByte(), 0xaf.toByte(), 0xac.toByte())

    // standard namespaces
    // cf com.adobe.internal.xmp.XMPConst
    private const val DC_NS_URI = "http://purl.org/dc/elements/1.1/"
    private const val MICROSOFTPHOTO_NS_URI = "http://ns.microsoft.com/photo/1.0/"
    private const val PHOTOSHOP_NS_URI = "http://ns.adobe.com/photoshop/1.0/"
    private const val XMP_NS_URI = "http://ns.adobe.com/xap/1.0/"

    // other namespaces
    private const val GAUDIO_NS_URI = "http://ns.google.com/photos/1.0/audio/"
    private const val GCAMERA_NS_URI = "http://ns.google.com/photos/1.0/camera/"
    private const val GCONTAINER_NS_URI = "http://ns.google.com/photos/1.0/container/"
    private const val GCONTAINER_ITEM_NS_URI = "http://ns.google.com/photos/1.0/container/item/"
    private const val GDEPTH_NS_URI = "http://ns.google.com/photos/1.0/depthmap/"
    private const val GDEVICE_NS_URI = "http://ns.google.com/photos/dd/1.0/device/"
    private const val GDEVICE_CONTAINER_NS_URI = "http://ns.google.com/photos/dd/1.0/container/"
    private const val GDEVICE_ITEM_NS_URI = "http://ns.google.com/photos/dd/1.0/item/"
    private const val GIMAGE_NS_URI = "http://ns.google.com/photos/1.0/image/"
    private const val GPANO_NS_URI = "http://ns.google.com/photos/1.0/panorama/"
    private const val HDRGM_NS_URI = "http://ns.adobe.com/hdr-gain-map/1.0/"
    private const val PMTM_NS_URI = "http://www.hdrsoft.com/photomatix_settings01"

    val DC_SUBJECT_PROP_NAME = XMPPropName(DC_NS_URI, "subject")
    val DC_DESCRIPTION_PROP_NAME = XMPPropName(DC_NS_URI, "description")
    val DC_TITLE_PROP_NAME = XMPPropName(DC_NS_URI, "title")
    val MS_RATING_PROP_NAME = XMPPropName(MICROSOFTPHOTO_NS_URI, "Rating")
    val PS_DATE_CREATED_PROP_NAME = XMPPropName(PHOTOSHOP_NS_URI, "DateCreated")
    val XMP_CREATE_DATE_PROP_NAME = XMPPropName(XMP_NS_URI, "CreateDate")
    val XMP_RATING_PROP_NAME = XMPPropName(XMP_NS_URI, "Rating")

    private const val GENERIC_LANG = ""
    private const val SPECIFIC_LANG = "en-US"

    // embedded media data properties
    // cf https://developers.google.com/depthmap-metadata
    // cf https://developers.google.com/vr/reference/cardboard-camera-vr-photo-format
    private val knownDataProps = listOf(
        XMPPropName(GAUDIO_NS_URI, "Data"),
        XMPPropName(GCAMERA_NS_URI, "RelitInputImageData"),
        XMPPropName(GIMAGE_NS_URI, "Data"),
        XMPPropName(GDEPTH_NS_URI, "Data"),
        XMPPropName(GDEPTH_NS_URI, "Confidence"),
    )

    fun isDataPath(path: String) = knownDataProps.map { it.toString() }.any { path == it }

    // google portrait

    val GDEVICE_CONTAINER_PROP_NAME = XMPPropName(GDEVICE_NS_URI, "Container")
    val GDEVICE_CONTAINER_DIRECTORY_PROP_NAME = XMPPropName(GDEVICE_CONTAINER_NS_URI, "Directory")
    val GDEVICE_CONTAINER_ITEM_DATA_URI_PROP_NAME = XMPPropName(GDEVICE_ITEM_NS_URI, "DataURI")
    val GDEVICE_CONTAINER_ITEM_LENGTH_PROP_NAME = XMPPropName(GDEVICE_ITEM_NS_URI, "Length")
    val GDEVICE_CONTAINER_ITEM_MIME_PROP_NAME = XMPPropName(GDEVICE_ITEM_NS_URI, "Mime")

    // container

    val GCAMERA_VIDEO_OFFSET_PROP_NAME = XMPPropName(GCAMERA_NS_URI, "MicroVideoOffset")
    val GCONTAINER_DIRECTORY_PROP_NAME = XMPPropName(GCONTAINER_NS_URI, "Directory")
    val GCONTAINER_ITEM_PROP_NAME = XMPPropName(GCONTAINER_NS_URI, "Item")
    val GCONTAINER_ITEM_LENGTH_PROP_NAME = XMPPropName(GCONTAINER_ITEM_NS_URI, "Length")
    val GCONTAINER_ITEM_MIME_PROP_NAME = XMPPropName(GCONTAINER_ITEM_NS_URI, "Mime")
    private val GCONTAINER_ITEM_SEMANTIC_PROP_NAME = XMPPropName(GCONTAINER_ITEM_NS_URI, "Semantic")

    private const val ITEM_SEMANTIC_GAIN_MAP = "GainMap"

    // HDR gain map

    private val HDRGM_VERSION_PROP_NAME = XMPPropName(HDRGM_NS_URI, "Version")

    // panorama
    // cf https://developers.google.com/streetview/spherical-metadata

    val GPANO_CROPPED_AREA_HEIGHT_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaImageHeightPixels")
    val GPANO_CROPPED_AREA_WIDTH_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaImageWidthPixels")
    val GPANO_CROPPED_AREA_LEFT_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaLeftPixels")
    val GPANO_CROPPED_AREA_TOP_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaTopPixels")
    val GPANO_FULL_PANO_HEIGHT_PROP_NAME = XMPPropName(GPANO_NS_URI, "FullPanoHeightPixels")
    val GPANO_FULL_PANO_WIDTH_PROP_NAME = XMPPropName(GPANO_NS_URI, "FullPanoWidthPixels")
    val GPANO_PROJECTION_TYPE_PROP_NAME = XMPPropName(GPANO_NS_URI, "ProjectionType")
    const val GPANO_PROJECTION_TYPE_DEFAULT = "equirectangular"

    private val PMTM_IS_PANO360_PROP_NAME = XMPPropName(PMTM_NS_URI, "IsPano360")

    // `GPano:ProjectionType` is required by spec but it is sometimes missing, assuming default
    // `GPano:FullPanoHeightPixels` is required by spec but it is sometimes missing (e.g. Samsung Camera app panorama mode)
    private val gpanoRequiredProps = listOf(
        GPANO_CROPPED_AREA_HEIGHT_PROP_NAME,
        GPANO_CROPPED_AREA_WIDTH_PROP_NAME,
        GPANO_CROPPED_AREA_LEFT_PROP_NAME,
        GPANO_CROPPED_AREA_TOP_PROP_NAME,
        GPANO_FULL_PANO_WIDTH_PROP_NAME,
    )

    // as of `metadata-extractor` v2.18.0, XMP is not discovered in HEIC images,
    // so we fall back to the native content resolver, if possible
    fun checkHeic(
        context: Context,
        mimeType: String,
        uri: Uri,
        foundXmp: Boolean,
        processXmp: (xmpMeta: XMPMeta) -> Unit,
    ) {
        if (MimeTypes.isHeic(mimeType) && !foundXmp && StorageUtils.isMediaStoreContentUri(uri) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val xmpBytes = context.queryContentPropValue(uri, mimeType, MediaStore.MediaColumns.XMP)
                if (xmpBytes is ByteArray && xmpBytes.size > 0) {
                    val xmpMeta = XMPMetaFactory.parseFromBuffer(xmpBytes, SafeXmpReader.PARSE_OPTIONS)
                    processXmp(xmpMeta)
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get XMP by content resolver for mimeType=$mimeType uri=$uri", e)
            }
        }
    }

    // as of `metadata-extractor` v2.18.0, processing large MP4 files may crash,
    // so we fall back to parsing with `mp4parser`
    fun checkMp4(
        context: Context,
        mimeType: String,
        uri: Uri,
        processDirs: (dirs: List<Directory>) -> Unit,
    ) {
        if (mimeType != MimeTypes.MP4) return
        try {
            // we can skip uninteresting boxes with a seekable data source
            val pfd = StorageUtils.openInputFileDescriptor(context, uri) ?: throw Exception("failed to open file descriptor for uri=$uri")
            pfd.use {
                FileInputStream(it.fileDescriptor).use { stream ->
                    stream.channel.use { channel ->
                        // creating `IsoFile` with a `File` or a `File.inputStream()` yields `No such device`
                        IsoFile(channel, Mp4ParserHelper.metadataBoxParser()).use { isoFile ->
                            isoFile.processBoxes(UserBox::class.java, true) { box, _ ->
                                val boxSize = box.size
                                if (MemoryUtils.canAllocate(boxSize)) {
                                    val bytes = box.toBytes()
                                    val payload = bytes.copyOfRange(8, bytes.size)

                                    val metadata = com.drew.metadata.Metadata()
                                    SafeMp4UuidBoxHandler(metadata).processBox("", payload, -1, null)
                                    processDirs(metadata.directories.filter { dir -> dir.tagCount > 0 }.toList())
                                } else {
                                    Log.w(LOG_TAG, "MP4 box too large at $boxSize bytes, for mimeType=$mimeType uri=$uri")
                                }
                            }
                        }
                    }
                }
            }
        } catch (e: NoClassDefFoundError) {
            Log.w(LOG_TAG, "failed to parse MP4 for mimeType=$mimeType uri=$uri", e)
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get XMP by MP4 parser for mimeType=$mimeType uri=$uri", e)
        }
    }

    // extensions

    fun XMPMeta.hasHdrGainMap(): Boolean {
        try {
            // standard HDR gain map
            if (doesPropExist(HDRGM_VERSION_PROP_NAME)) {
                return true
            }

            // `Ultra HDR`
            if (doesPropExist(GCONTAINER_DIRECTORY_PROP_NAME)) {
                val count = countPropArrayItems(GCONTAINER_DIRECTORY_PROP_NAME)
                for (i in 1 until count + 1) {
                    val semantic = getSafeStructField(listOf(GCONTAINER_DIRECTORY_PROP_NAME, i, GCONTAINER_ITEM_PROP_NAME, GCONTAINER_ITEM_SEMANTIC_PROP_NAME))?.value
                    if (semantic == ITEM_SEMANTIC_GAIN_MAP) {
                        return true
                    }
                }
            }

            return false
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check HDR props from XMP", e)
            }
        }
        return false
    }

    fun XMPMeta.isMotionPhoto(): Boolean {
        try {
            // GCamera motion photo
            if (doesPropExist(GCAMERA_VIDEO_OFFSET_PROP_NAME)) return true

            // Container motion photo
            if (doesPropExist(GCONTAINER_DIRECTORY_PROP_NAME)) {
                val count = countPropArrayItems(GCONTAINER_DIRECTORY_PROP_NAME)
                var hasImage = false
                var hasVideo = false
                for (i in 1 until count + 1) {
                    val mime = getSafeStructField(listOf(GCONTAINER_DIRECTORY_PROP_NAME, i, GCONTAINER_ITEM_PROP_NAME, GCONTAINER_ITEM_MIME_PROP_NAME))?.value
                    val length = getSafeStructField(listOf(GCONTAINER_DIRECTORY_PROP_NAME, i, GCONTAINER_ITEM_PROP_NAME, GCONTAINER_ITEM_LENGTH_PROP_NAME))?.value
                    hasImage = hasImage || MimeTypes.isImage(mime) && length != null
                    hasVideo = hasVideo || MimeTypes.isVideo(mime) && length != null
                }
                if (hasImage && hasVideo) return true
            }

            return false
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check Google motion photo props from XMP", e)
            }
        }
        return false
    }

    fun XMPMeta.isPanorama(): Boolean {
        // Google
        try {
            if (gpanoRequiredProps.all { doesPropExist(it) }) return true
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check Google panorama props from XMP", e)
            }
        }

        // Photomatix
        try {
            if (getPropertyString(PMTM_IS_PANO360_PROP_NAME.nsUri, PMTM_IS_PANO360_PROP_NAME.toString()) == "Yes") return true
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check Photomatix panorama props from XMP", e)
            }
        }

        return false
    }

    fun XMPMeta.doesPropExist(prop: XMPPropName): Boolean {
        return doesPropertyExist(prop.nsUri, prop.toString())
    }

    fun XMPMeta.doesPropPathExist(props: List<XMPPropName>): Boolean {
        return doesPropertyExist(props.first().nsUri, props.joinToString("/"))
    }

    fun XMPMeta.countPropArrayItems(prop: XMPPropName): Int {
        return countArrayItems(prop.nsUri, prop.toString())
    }

    fun XMPMeta.countPropPathArrayItems(props: List<XMPPropName>): Int {
        return countArrayItems(props.first().nsUri, props.joinToString("/"))
    }

    fun XMPMeta.getPropArrayItemValues(prop: XMPPropName): List<String> {
        val schema = prop.nsUri
        val propName = prop.toString()
        val count = countArrayItems(schema, propName)
        return (1 until count + 1).map { getArrayItem(schema, propName, it).value }
    }

    fun XMPMeta.getSafeInt(prop: XMPPropName, save: (value: Int) -> Unit) {
        val schema = prop.nsUri
        val propName = prop.toString()
        try {
            if (doesPropertyExist(schema, propName)) {
                val item = getPropertyInteger(schema, propName)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null) {
                    save(item)
                }
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get int for XMP schema=$schema, propName=$propName", e)
        }
    }

    fun XMPMeta.getSafeLong(prop: XMPPropName, save: (value: Long) -> Unit) {
        val schema = prop.nsUri
        val propName = prop.toString()
        try {
            if (doesPropertyExist(schema, propName)) {
                val item = getPropertyLong(schema, propName)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null) {
                    save(item)
                }
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get long for XMP schema=$schema, propName=$propName", e)
        }
    }

    fun XMPMeta.getSafeString(prop: XMPPropName, save: (value: String) -> Unit) {
        val schema = prop.nsUri
        val propName = prop.toString()
        try {
            if (doesPropertyExist(schema, propName)) {
                val item = getPropertyString(schema, propName)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null) {
                    save(item)
                }
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get int for XMP schema=$schema, propName=$propName", e)
        }
    }

    fun XMPMeta.getSafeLocalizedText(prop: XMPPropName, acceptBlank: Boolean = true, save: (value: String) -> Unit) {
        val schema = prop.nsUri
        val propName = prop.toString()
        try {
            if (doesPropertyExist(schema, propName)) {
                val item = getLocalizedText(schema, propName, GENERIC_LANG, SPECIFIC_LANG)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null && (acceptBlank || item.value.isNotBlank())) {
                    save(item.value)
                }
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get text for XMP schema=$schema, propName=$propName", e)
        }
    }

    fun XMPMeta.getSafeDateMillis(prop: XMPPropName, save: (value: Long) -> Unit) {
        val schema = prop.nsUri
        val propName = prop.toString()
        try {
            if (doesPropertyExist(schema, propName)) {
                val item = getPropertyDate(schema, propName)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null) {
                    // strip time zone from XMP dates so that we show date/times as local ones
                    // this aligns with Exif date/times, which are specified without time zones
                    item.timeZone = TimeZone.getDefault()
                    save(item.calendar.timeInMillis)
                }
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get date for XMP schema=$schema, propName=$propName", e)
        }
    }

    // e.g. path 'Container:Directory[42]/Container:Item/Item:Mime' matches:
    // - structNs: "http://ns.google.com/photos/1.0/container/"
    // - structName: "Container:Directory[42]/Container:Item"
    // - fieldNs: "http://ns.google.com/photos/1.0/container/item/"
    // - fieldName: "Item:Mime"
    fun XMPMeta.getSafeStructField(props: List<Any>): XMPProperty? {
        if (props.size >= 2) {
            val structFirst = props.first()
            val field = props.last()
            if (structFirst is XMPPropName && field is XMPPropName) {
                val structName = props.take(props.size - 1).mapIndexed { index, prop ->
                    when (prop) {
                        is XMPPropName -> "${if (index == 0) "" else "/"}$prop"
                        is Int -> "[$prop]"
                        else -> null
                    }
                }.filterNotNull().joinToString("")
                val fieldName = field.toString()

                try {
                    return getStructField(structFirst.nsUri, structName, field.nsUri, fieldName)
                } catch (e: XMPException) {
                    Log.w(LOG_TAG, "failed to get XMP struct field for props=$props", e)
                }
            }
        }
        return null
    }
}

class XMPPropName(val nsUri: String, private val prop: String) {
    private fun resolve(): String = "${XMPMetaFactory.getSchemaRegistry().getNamespacePrefix(nsUri)}$prop"

    override fun toString(): String = resolve()
}
