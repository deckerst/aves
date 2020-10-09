package deckers.thibault.aves.utils

import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta

object XMP {
    const val DC_SCHEMA_NS = "http://purl.org/dc/elements/1.1/"
    const val XMP_SCHEMA_NS = "http://ns.adobe.com/xap/1.0/"
    const val IMG_SCHEMA_NS = "http://ns.adobe.com/xap/1.0/g/img/"
    const val SUBJECT_PROP_NAME = "dc:subject"
    const val TITLE_PROP_NAME = "dc:title"
    const val DESCRIPTION_PROP_NAME = "dc:description"
    const val THUMBNAIL_PROP_NAME = "xmp:Thumbnails"
    const val THUMBNAIL_IMAGE_PROP_NAME = "xmpGImg:image"
    private const val GENERIC_LANG = ""
    private const val SPECIFIC_LANG = "en-US"

    @Throws(XMPException::class)
    fun XMPMeta.getSafeLocalizedText(propName: String, save: (value: String) -> Unit) {
        if (this.doesPropertyExist(DC_SCHEMA_NS, propName)) {
            val item = this.getLocalizedText(DC_SCHEMA_NS, propName, GENERIC_LANG, SPECIFIC_LANG)
            // double check retrieved items as the property sometimes is reported to exist but it is actually null
            if (item != null) save(item.value)
        }
    }
}