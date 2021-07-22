package deckers.thibault.aves.metadata

import android.util.Log
import com.adobe.internal.xmp.XMPError
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta
import com.adobe.internal.xmp.properties.XMPProperty
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import java.util.*

object XMP {
    private val LOG_TAG = LogUtils.createTag<XMP>()

    // standard namespaces
    // cf com.adobe.internal.xmp.XMPConst
    const val DC_SCHEMA_NS = "http://purl.org/dc/elements/1.1/"
    const val PHOTOSHOP_SCHEMA_NS = "http://ns.adobe.com/photoshop/1.0/"
    const val XMP_SCHEMA_NS = "http://ns.adobe.com/xap/1.0/"
    private const val XMP_GIMG_SCHEMA_NS = "http://ns.adobe.com/xap/1.0/g/img/"

    // other namespaces
    private const val GAUDIO_SCHEMA_NS = "http://ns.google.com/photos/1.0/audio/"
    const val GCAMERA_SCHEMA_NS = "http://ns.google.com/photos/1.0/camera/"
    private const val GDEPTH_SCHEMA_NS = "http://ns.google.com/photos/1.0/depthmap/"
    const val GIMAGE_SCHEMA_NS = "http://ns.google.com/photos/1.0/image/"
    const val CONTAINER_SCHEMA_NS = "http://ns.google.com/photos/1.0/container/"
    private const val CONTAINER_ITEM_SCHEMA_NS = "http://ns.google.com/photos/1.0/container/item/"

    const val SUBJECT_PROP_NAME = "dc:subject"
    const val TITLE_PROP_NAME = "dc:title"
    const val DESCRIPTION_PROP_NAME = "dc:description"
    const val PS_DATE_CREATED_PROP_NAME = "photoshop:DateCreated"
    const val CREATE_DATE_PROP_NAME = "xmp:CreateDate"

    private const val GENERIC_LANG = ""
    private const val SPECIFIC_LANG = "en-US"

    private val schemas = hashMapOf(
        "Container" to CONTAINER_SCHEMA_NS,
        "GAudio" to GAUDIO_SCHEMA_NS,
        "GDepth" to GDEPTH_SCHEMA_NS,
        "GImage" to GIMAGE_SCHEMA_NS,
        "Item" to CONTAINER_ITEM_SCHEMA_NS,
        "xmp" to XMP_SCHEMA_NS,
        "xmpGImg" to XMP_GIMG_SCHEMA_NS,
    )

    fun namespaceForPropPath(propPath: String) = schemas[propPath.split(":")[0]]

    // embedded media data properties
    // cf https://developers.google.com/depthmap-metadata
    // cf https://developers.google.com/vr/reference/cardboard-camera-vr-photo-format
    private val knownDataPaths = listOf("GAudio:Data", "GImage:Data", "GDepth:Data", "GDepth:Confidence")

    fun isDataPath(path: String) = knownDataPaths.contains(path)

    // motion photo

    const val GCAMERA_VIDEO_OFFSET_PROP_NAME = "GCamera:MicroVideoOffset"
    const val CONTAINER_DIRECTORY_PROP_NAME = "Container:Directory"
    const val CONTAINER_ITEM_PROP_NAME = "Container:Item"
    const val CONTAINER_ITEM_LENGTH_PROP_NAME = "Item:Length"
    const val CONTAINER_ITEM_MIME_PROP_NAME = "Item:Mime"

    // panorama
    // cf https://developers.google.com/streetview/spherical-metadata

    const val GPANO_SCHEMA_NS = "http://ns.google.com/photos/1.0/panorama/"
    private const val PMTM_SCHEMA_NS = "http://www.hdrsoft.com/photomatix_settings01"

    const val GPANO_CROPPED_AREA_HEIGHT_PROP_NAME = "GPano:CroppedAreaImageHeightPixels"
    const val GPANO_CROPPED_AREA_WIDTH_PROP_NAME = "GPano:CroppedAreaImageWidthPixels"
    const val GPANO_CROPPED_AREA_LEFT_PROP_NAME = "GPano:CroppedAreaLeftPixels"
    const val GPANO_CROPPED_AREA_TOP_PROP_NAME = "GPano:CroppedAreaTopPixels"
    const val GPANO_FULL_PANO_HEIGHT_PROP_NAME = "GPano:FullPanoHeightPixels"
    const val GPANO_FULL_PANO_WIDTH_PROP_NAME = "GPano:FullPanoWidthPixels"
    const val GPANO_PROJECTION_TYPE_PROP_NAME = "GPano:ProjectionType"
    const val GPANO_PROJECTION_TYPE_DEFAULT = "equirectangular"

    private const val PMTM_IS_PANO360 = "pmtm:IsPano360"

    // `GPano:ProjectionType` is required by spec but it is sometimes missing, assuming default
    // `GPano:FullPanoHeightPixels` is required by spec but it is sometimes missing (e.g. Samsung Camera app panorama mode)
    private val gpanoRequiredProps = listOf(
        GPANO_CROPPED_AREA_HEIGHT_PROP_NAME,
        GPANO_CROPPED_AREA_WIDTH_PROP_NAME,
        GPANO_CROPPED_AREA_LEFT_PROP_NAME,
        GPANO_CROPPED_AREA_TOP_PROP_NAME,
        GPANO_FULL_PANO_WIDTH_PROP_NAME,
    )

    // extensions

    fun XMPMeta.isMotionPhoto(): Boolean {
        try {
            // GCamera motion photo
            if (doesPropertyExist(GCAMERA_SCHEMA_NS, GCAMERA_VIDEO_OFFSET_PROP_NAME)) return true

            // Container motion photo
            if (doesPropertyExist(CONTAINER_SCHEMA_NS, CONTAINER_DIRECTORY_PROP_NAME)) {
                val count = countArrayItems(CONTAINER_SCHEMA_NS, CONTAINER_DIRECTORY_PROP_NAME)
                if (count == 2) {
                    var hasImage = false
                    var hasVideo = false
                    for (i in 1 until count + 1) {
                        val mime = getSafeStructField("$CONTAINER_DIRECTORY_PROP_NAME[$i]/$CONTAINER_ITEM_PROP_NAME/$CONTAINER_ITEM_MIME_PROP_NAME")?.value
                        val length = getSafeStructField("$CONTAINER_DIRECTORY_PROP_NAME[$i]/$CONTAINER_ITEM_PROP_NAME/$CONTAINER_ITEM_LENGTH_PROP_NAME")?.value
                        hasImage = hasImage || MimeTypes.isImage(mime) && length != null
                        hasVideo = hasVideo || MimeTypes.isVideo(mime) && length != null
                    }
                    if (hasImage && hasVideo) return true
                }
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
            if (gpanoRequiredProps.all { doesPropertyExist(GPANO_SCHEMA_NS, it) }) return true
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check Google panorama props from XMP", e)
            }
        }

        // Photomatix
        try {
            if (getPropertyString(PMTM_SCHEMA_NS, PMTM_IS_PANO360) == "Yes") return true
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check Photomatix panorama props from XMP", e)
            }
        }

        return false
    }

    fun XMPMeta.getSafeInt(schema: String, propName: String, save: (value: Int) -> Unit) {
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

    fun XMPMeta.getSafeLong(schema: String, propName: String, save: (value: Long) -> Unit) {
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

    fun XMPMeta.getSafeString(schema: String, propName: String, save: (value: String) -> Unit) {
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

    fun XMPMeta.getSafeLocalizedText(schema: String, propName: String, acceptBlank: Boolean = true, save: (value: String) -> Unit) {
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

    fun XMPMeta.getSafeDateMillis(schema: String, propName: String, save: (value: Long) -> Unit) {
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

    // e.g. 'Container:Directory[42]/Container:Item/Item:Mime'
    fun XMPMeta.getSafeStructField(path: String): XMPProperty? {
        val separator = path.lastIndexOf("/")
        if (separator != -1) {
            val structName = path.substring(0, separator)
            val structNs = namespaceForPropPath(structName)
            val fieldName = path.substring(separator + 1)
            val fieldNs = namespaceForPropPath(fieldName)
            try {
                return getStructField(structNs, structName, fieldNs, fieldName)
            } catch (e: XMPException) {
                Log.w(LOG_TAG, "failed to get XMP struct field for path=$path", e)
            }
        }
        return null
    }
}