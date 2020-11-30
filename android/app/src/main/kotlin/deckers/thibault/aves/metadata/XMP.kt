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