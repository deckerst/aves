package deckers.thibault.aves.metadata

import android.util.Log
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta
import deckers.thibault.aves.utils.LogUtils
import java.util.*

object XMP {
    private val LOG_TAG = LogUtils.createTag(XMP::class.java)

    const val DC_SCHEMA_NS = "http://purl.org/dc/elements/1.1/"
    const val XMP_SCHEMA_NS = "http://ns.adobe.com/xap/1.0/"
    const val IMG_SCHEMA_NS = "http://ns.adobe.com/xap/1.0/g/img/"

    const val SUBJECT_PROP_NAME = "dc:subject"
    const val TITLE_PROP_NAME = "dc:title"
    const val DESCRIPTION_PROP_NAME = "dc:description"
    const val CREATE_DATE_PROP_NAME = "xmp:CreateDate"
    const val THUMBNAIL_PROP_NAME = "xmp:Thumbnails"
    const val THUMBNAIL_IMAGE_PROP_NAME = "xmpGImg:image"

    private const val GENERIC_LANG = ""
    private const val SPECIFIC_LANG = "en-US"

    // panorama
    // cf https://developers.google.com/streetview/spherical-metadata

    const val GPANO_SCHEMA_NS = "http://ns.google.com/photos/1.0/panorama/"

    private const val GPANO_CROPPED_AREA_HEIGHT_PROP_NAME = "GPano:CroppedAreaImageHeightPixels"
    private const val GPANO_CROPPED_AREA_WIDTH_PROP_NAME = "GPano:CroppedAreaImageWidthPixels"
    private const val GPANO_CROPPED_AREA_LEFT_PROP_NAME = "GPano:CroppedAreaLeftPixels"
    private const val GPANO_CROPPED_AREA_TOP_PROP_NAME = "GPano:CroppedAreaTopPixels"
    private const val GPANO_FULL_PANO_HEIGHT_PIXELS_PROP_NAME = "GPano:FullPanoHeightPixels"
    private const val GPANO_FULL_PANO_WIDTH_PIXELS_PROP_NAME = "GPano:FullPanoWidthPixels"
    private const val GPANO_PROJECTION_TYPE_PROP_NAME = "GPano:ProjectionType"

    val panoramaRequiredProps = listOf(
        GPANO_CROPPED_AREA_HEIGHT_PROP_NAME,
        GPANO_CROPPED_AREA_WIDTH_PROP_NAME,
        GPANO_CROPPED_AREA_LEFT_PROP_NAME,
        GPANO_CROPPED_AREA_TOP_PROP_NAME,
        GPANO_FULL_PANO_HEIGHT_PIXELS_PROP_NAME,
        GPANO_FULL_PANO_WIDTH_PIXELS_PROP_NAME,
        GPANO_PROJECTION_TYPE_PROP_NAME,
    )

    // embedded media data properties
    // cf https://developers.google.com/depthmap-metadata
    // cf https://developers.google.com/vr/reference/cardboard-camera-vr-photo-format

    private const val GAUDIO_SCHEMA_NS = "http://ns.google.com/photos/1.0/audio/"
    private const val GDEPTH_SCHEMA_NS = "http://ns.google.com/photos/1.0/depthmap/"
    private const val GIMAGE_SCHEMA_NS = "http://ns.google.com/photos/1.0/image/"

    private const val GAUDIO_DATA_PROP_NAME = "GAudio:Data"
    private const val GIMAGE_DATA_PROP_NAME = "GImage:Data"
    private const val GDEPTH_DATA_PROP_NAME = "GDepth:Data"
    private const val GDEPTH_CONFIDENCE_PROP_NAME = "GDepth:Confidence"

    private const val GAUDIO_MIME_PROP_NAME = "GAudio:Mime"
    private const val GIMAGE_MIME_PROP_NAME = "GImage:Mime"
    private const val GDEPTH_MIME_PROP_NAME = "GDepth:Mime"
    private const val GDEPTH_CONFIDENCE_MIME_PROP_NAME = "GDepth:ConfidenceMime"

    private val dataPropNamespaces = hashMapOf(
        GAUDIO_DATA_PROP_NAME to GAUDIO_SCHEMA_NS,
        GIMAGE_DATA_PROP_NAME to GIMAGE_SCHEMA_NS,
        GDEPTH_DATA_PROP_NAME to GDEPTH_SCHEMA_NS,
        GDEPTH_CONFIDENCE_PROP_NAME to GDEPTH_SCHEMA_NS,
    )

    private val dataPropMimeProps = hashMapOf(
        GAUDIO_DATA_PROP_NAME to GAUDIO_MIME_PROP_NAME,
        GIMAGE_DATA_PROP_NAME to GIMAGE_MIME_PROP_NAME,
        GDEPTH_DATA_PROP_NAME to GDEPTH_MIME_PROP_NAME,
        GDEPTH_CONFIDENCE_PROP_NAME to GDEPTH_CONFIDENCE_MIME_PROP_NAME,
    )

    fun isDataPath(path: String) = dataPropNamespaces.containsKey(path)

    fun namespaceForDataPath(dataPropPath: String) = dataPropNamespaces[dataPropPath]

    fun mimeTypePathForDataPath(dataPropPath: String) = dataPropMimeProps[dataPropPath]

    // extensions

    fun XMPMeta.getSafeLocalizedText(schema: String, propName: String, save: (value: String) -> Unit) {
        try {
            if (this.doesPropertyExist(schema, propName)) {
                val item = this.getLocalizedText(schema, propName, GENERIC_LANG, SPECIFIC_LANG)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null) save(item.value)
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get text for XMP schema=$schema, propName=$propName", e)
        }
    }

    fun XMPMeta.getSafeDateMillis(schema: String, propName: String, save: (value: Long) -> Unit) {
        try {
            if (this.doesPropertyExist(schema, propName)) {
                val item = this.getPropertyDate(schema, propName)
                // double check retrieved items as the property sometimes is reported to exist but it is actually null
                if (item != null) {
                    // strip time zone from XMP dates so that we show date/times as local ones
                    // this aligns with Exif date/times, which are specified without time zones
                    item.timeZone = TimeZone.getDefault()
                    save(item.calendar.timeInMillis)
                }
            }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to get text for XMP schema=$schema, propName=$propName", e)
        }
    }
}