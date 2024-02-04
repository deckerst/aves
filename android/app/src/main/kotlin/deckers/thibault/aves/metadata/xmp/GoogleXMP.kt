package deckers.thibault.aves.metadata.xmp

import android.util.Log
import com.adobe.internal.xmp.XMPError
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPMeta
import deckers.thibault.aves.metadata.xmp.XMP.countPropArrayItems
import deckers.thibault.aves.metadata.xmp.XMP.doesPropExist
import deckers.thibault.aves.metadata.xmp.XMP.doesPropPathExist
import deckers.thibault.aves.metadata.xmp.XMP.getSafeInt
import deckers.thibault.aves.metadata.xmp.XMP.getSafeLong
import deckers.thibault.aves.metadata.xmp.XMP.getSafeString
import deckers.thibault.aves.metadata.xmp.XMP.getSafeStructField
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes

object GoogleXMP {
    private val LOG_TAG = LogUtils.createTag<GoogleXMP>()

    // namespaces
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

    private val GCAMERA_VIDEO_OFFSET_PROP_NAME = XMPPropName(GCAMERA_NS_URI, "MicroVideoOffset")
    private val GCONTAINER_DIRECTORY_PROP_NAME = XMPPropName(GCONTAINER_NS_URI, "Directory")
    private val GCONTAINER_ITEM_PROP_NAME = XMPPropName(GCONTAINER_NS_URI, "Item")
    private val GCONTAINER_ITEM_LENGTH_PROP_NAME = XMPPropName(GCONTAINER_ITEM_NS_URI, "Length")
    private val GCONTAINER_ITEM_MIME_PROP_NAME = XMPPropName(GCONTAINER_ITEM_NS_URI, "Mime")
    private val GCONTAINER_ITEM_SEMANTIC_PROP_NAME = XMPPropName(GCONTAINER_ITEM_NS_URI, "Semantic")

    private const val ITEM_SEMANTIC_GAIN_MAP = "GainMap"

    // panorama
    // cf https://developers.google.com/streetview/spherical-metadata

    private val GPANO_CROPPED_AREA_HEIGHT_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaImageHeightPixels")
    private val GPANO_CROPPED_AREA_WIDTH_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaImageWidthPixels")
    private val GPANO_CROPPED_AREA_LEFT_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaLeftPixels")
    private val GPANO_CROPPED_AREA_TOP_PROP_NAME = XMPPropName(GPANO_NS_URI, "CroppedAreaTopPixels")
    private val GPANO_FULL_PANO_HEIGHT_PROP_NAME = XMPPropName(GPANO_NS_URI, "FullPanoHeightPixels")
    private val GPANO_FULL_PANO_WIDTH_PROP_NAME = XMPPropName(GPANO_NS_URI, "FullPanoWidthPixels")
    private val GPANO_PROJECTION_TYPE_PROP_NAME = XMPPropName(GPANO_NS_URI, "ProjectionType")
    const val GPANO_PROJECTION_TYPE_DEFAULT = "equirectangular"

    // `GPano:ProjectionType` is required by spec but it is sometimes missing, assuming default
    // `GPano:FullPanoHeightPixels` is required by spec but it is sometimes missing (e.g. Samsung Camera app panorama mode)
    private val gpanoRequiredProps = listOf(
        GPANO_CROPPED_AREA_HEIGHT_PROP_NAME,
        GPANO_CROPPED_AREA_WIDTH_PROP_NAME,
        GPANO_CROPPED_AREA_LEFT_PROP_NAME,
        GPANO_CROPPED_AREA_TOP_PROP_NAME,
        GPANO_FULL_PANO_WIDTH_PROP_NAME,
    )

    fun isUltraHdPhoto(meta: XMPMeta): Boolean {
        if (meta.doesPropExist(GCONTAINER_DIRECTORY_PROP_NAME)) {
            val count = meta.countPropArrayItems(GCONTAINER_DIRECTORY_PROP_NAME)
            for (i in 1 until count + 1) {
                val semantic = meta.getSafeStructField(listOf(GCONTAINER_DIRECTORY_PROP_NAME, i, GCONTAINER_ITEM_PROP_NAME, GCONTAINER_ITEM_SEMANTIC_PROP_NAME))?.value
                if (semantic == ITEM_SEMANTIC_GAIN_MAP) {
                    return true
                }
            }
        }
        return false
    }

    fun isMotionPhoto(meta: XMPMeta): Boolean {
        try {
            // GCamera motion photo
            if (meta.doesPropExist(GCAMERA_VIDEO_OFFSET_PROP_NAME)) return true

            // Container motion photo
            if (meta.doesPropExist(GCONTAINER_DIRECTORY_PROP_NAME)) {
                val count = meta.countPropArrayItems(GCONTAINER_DIRECTORY_PROP_NAME)
                var hasImage = false
                var hasVideo = false
                for (i in 1 until count + 1) {
                    val mime = getContainerItemAttribute(meta, i, GCONTAINER_ITEM_MIME_PROP_NAME)
                    val length = getContainerItemAttribute(meta, i, GCONTAINER_ITEM_LENGTH_PROP_NAME)
                    // `length` is not always provided for the image item
                    hasImage = hasImage || MimeTypes.isImage(mime)
                    hasVideo = hasVideo || (MimeTypes.isVideo(mime) && length != null)
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

    private fun getContainerItemAttribute(meta: XMPMeta, i: Int, attribute: XMPPropName): String? {
        // variant of `Container:Item` with `<rdf:li rdf:parseType="Resource">`
        val mime = meta.getSafeStructField(listOf(GCONTAINER_DIRECTORY_PROP_NAME, i, GCONTAINER_ITEM_PROP_NAME, attribute))?.value
        // variant of `Container:Item` with `<rdf:li>`
        return mime ?: meta.getSafeStructField(listOf(GCONTAINER_DIRECTORY_PROP_NAME, i, attribute))?.value
    }

    fun isPanorama(meta: XMPMeta): Boolean {
        try {
            if (gpanoRequiredProps.all { meta.doesPropExist(it) }) return true
        } catch (e: XMPException) {
            if (e.errorCode != XMPError.BADSCHEMA) {
                // `BADSCHEMA` code is reported when we check a property
                // from a non standard namespace, and that namespace is not declared in the XMP
                Log.w(LOG_TAG, "failed to check Google panorama props from XMP", e)
            }
        }
        return false
    }

    fun getPanoramaInfo(meta: XMPMeta): FieldMap {
        val fields: FieldMap = hashMapOf()
        try {
            meta.getSafeInt(GPANO_CROPPED_AREA_LEFT_PROP_NAME) { fields["croppedAreaLeft"] = it }
            meta.getSafeInt(GPANO_CROPPED_AREA_TOP_PROP_NAME) { fields["croppedAreaTop"] = it }
            meta.getSafeInt(GPANO_CROPPED_AREA_WIDTH_PROP_NAME) { fields["croppedAreaWidth"] = it }
            meta.getSafeInt(GPANO_CROPPED_AREA_HEIGHT_PROP_NAME) { fields["croppedAreaHeight"] = it }
            meta.getSafeInt(GPANO_FULL_PANO_WIDTH_PROP_NAME) { fields["fullPanoWidth"] = it }
            meta.getSafeInt(GPANO_FULL_PANO_HEIGHT_PROP_NAME) { fields["fullPanoHeight"] = it }
            meta.getSafeString(GPANO_PROJECTION_TYPE_PROP_NAME) { fields["projectionType"] = it }
        } catch (e: XMPException) {
            Log.w(LOG_TAG, "failed to read XMP directory", e)
        }
        return fields
    }

    fun getTrailingVideoOffsetFromEnd(meta: XMPMeta): Long? {
        var offsetFromEnd: Long? = null
        if (meta.doesPropExist(GCAMERA_VIDEO_OFFSET_PROP_NAME)) {
            // `GCamera` motion photo
            meta.getSafeLong(GCAMERA_VIDEO_OFFSET_PROP_NAME) { offsetFromEnd = it }
        } else if (meta.doesPropExist(GCONTAINER_DIRECTORY_PROP_NAME)) {
            // `Container` motion photo
            val count = meta.countPropArrayItems(GCONTAINER_DIRECTORY_PROP_NAME)
            for (i in 1 until count + 1) {
                val mime = getContainerItemAttribute(meta, i, GCONTAINER_ITEM_MIME_PROP_NAME)
                if (MimeTypes.isVideo(mime)) {
                    getContainerItemAttribute(meta, i, GCONTAINER_ITEM_LENGTH_PROP_NAME)?.let { offsetFromEnd = it.toLong() }
                }
            }
        }
        return offsetFromEnd
    }

    fun updateTrailingVideoOffset(xmp: String, oldOffset: Int, newOffset: Int): String {
        return xmp.replace(
            // GCamera motion photo
            "${GCAMERA_VIDEO_OFFSET_PROP_NAME}=\"$oldOffset\"",
            "${GCAMERA_VIDEO_OFFSET_PROP_NAME}=\"$newOffset\"",
        ).replace(
            // Container motion photo
            "${GCONTAINER_ITEM_LENGTH_PROP_NAME}=\"$oldOffset\"",
            "${GCONTAINER_ITEM_LENGTH_PROP_NAME}=\"$newOffset\"",
        )
    }


    fun getDeviceContainer(meta: XMPMeta): GoogleDeviceContainer? {
        return if (meta.doesPropPathExist(listOf(GDEVICE_CONTAINER_PROP_NAME, GDEVICE_CONTAINER_DIRECTORY_PROP_NAME))) {
            GoogleDeviceContainer().apply { findItems(meta) }
        } else {
            null
        }
    }
}