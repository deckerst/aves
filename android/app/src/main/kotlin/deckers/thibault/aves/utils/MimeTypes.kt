package deckers.thibault.aves.utils

import android.webkit.MimeTypeMap
import deckers.thibault.aves.decoder.MultiPageImage
import androidx.exifinterface.media.ExifInterfaceFork as ExifInterface

object MimeTypes {
    const val ANY = "*/*"

    // generic raster
    private const val AVIF = "image/avif"
    const val BMP = "image/bmp"
    private const val DJVU = "image/vnd.djvu"
    const val GIF = "image/gif"
    const val HEIC = "image/heic"
    const val HEIF = "image/heif"
    private const val ICO = "image/x-icon"
    const val JPEG = "image/jpeg"
    const val PNG = "image/png"
    const val PSD_VND = "image/vnd.adobe.photoshop"
    const val PSD_X = "image/x-photoshop"
    const val TIFF = "image/tiff"
    private const val WBMP = "image/vnd.wap.wbmp"
    const val WEBP = "image/webp"

    // raw raster
    private const val ARW = "image/x-sony-arw"
    private const val CR2 = "image/x-canon-cr2"
    private const val CRW = "image/x-canon-crw"
    private const val DCR = "image/x-kodak-dcr"
    const val DNG = "image/dng"
    const val DNG_ADOBE = "image/x-adobe-dng"
    private const val ERF = "image/x-epson-erf"
    private const val K25 = "image/x-kodak-k25"
    private const val KDC = "image/x-kodak-kdc"
    private const val MRW = "image/x-minolta-mrw"
    private const val NEF = "image/x-nikon-nef"
    private const val NRW = "image/x-nikon-nrw"
    private const val ORF = "image/x-olympus-orf"
    private const val PEF = "image/x-pentax-pef"
    private const val RAF = "image/x-fuji-raf"
    private const val RAW = "image/x-panasonic-raw"
    private const val RW2 = "image/x-panasonic-rw2"
    private const val SR2 = "image/x-sony-sr2"
    private const val SRF = "image/x-sony-srf"
    private const val SRW = "image/x-samsung-srw"
    private const val X3F = "image/x-sigma-x3f"

    // vector
    const val SVG = "image/svg+xml"

    // video
    private const val AVI = "video/avi"
    private const val AVI_VND = "video/vnd.avi"
    const val DVD = "video/dvd"
    private const val MKV = "video/x-matroska"
    const val MOV = "video/quicktime"
    private const val MP2T = "video/mp2t"
    private const val MP2TS = "video/mp2ts"
    const val MP4 = "video/mp4"
    private const val OGV = "video/ogg"
    private const val WEBM = "video/webm"

    // others
    const val ZIP = "application/zip"

    fun isImage(mimeType: String?) = mimeType != null && mimeType.startsWith("image")

    fun isVideo(mimeType: String?) = mimeType != null && mimeType.startsWith("video")

    fun isHeic(mimeType: String?) = mimeType != null && (mimeType == HEIC || mimeType == HEIF)

    fun isRaw(mimeType: String): Boolean {
        return when (mimeType) {
            ARW, CR2, CRW, DCR, DNG, DNG_ADOBE, ERF, K25, KDC, MRW, NEF, NRW, ORF, PEF, RAF, RAW, RW2, SR2, SRF, SRW, X3F -> true
            else -> false
        }
    }

    // returns whether the specified MIME type represents
    // a raster image format that allows an alpha channel
    fun canHaveAlpha(mimeType: String?) = when (mimeType) {
        AVIF, BMP, GIF, ICO, PNG, SVG, TIFF, WEBP -> true
        else -> false
    }

    // as of Flutter v3.16.4, with additional custom handling for SVG
    fun canDecodeWithFlutter(mimeType: String, pageId: Int?, rotationDegrees: Int?, isFlipped: Boolean?) = when (mimeType) {
        GIF, WEBP, BMP, WBMP, ICO, SVG -> true
        JPEG -> (pageId ?: 0) == 0
        PNG -> (rotationDegrees ?: 0) == 0 && !(isFlipped ?: false)
        else -> false
    }

    // as of `metadata-extractor` v2.14.0
    fun canReadWithMetadataExtractor(mimeType: String) = when (mimeType) {
        DJVU, SVG, WBMP -> false
        MKV, MP2T, MP2TS, OGV, WEBM -> false
        else -> true
    }

    // as of `ExifInterface` v1.4.0-alpha01, `isSupportedMimeType` reports
    // no support for AVIF/TIFF images, but it can actually open them (maybe other formats too)
    fun canReadWithExifInterface(mimeType: String, strict: Boolean = true): Boolean {
        if (!strict) return true
        return ExifInterface.isSupportedMimeType(mimeType) || mimeType == AVIF
    }

    // as of latest PixyMeta
    fun canReadWithPixyMeta(mimeType: String) = when (mimeType) {
        JPEG, TIFF, PNG, GIF, BMP -> true
        else -> false
    }

    fun canEditExif(mimeType: String) = when (mimeType) {
        // as of androidx.exifinterface:exifinterface:1.3.4
        JPEG, PNG, WEBP -> true
        else -> false
    }

    fun canEditIptc(mimeType: String) = when (mimeType) {
        // as of latest PixyMeta
        JPEG, TIFF -> true
        else -> false
    }

    fun canEditXmp(mimeType: String) = when (mimeType) {
        // as of latest PixyMeta
        JPEG, TIFF, PNG, GIF -> true
        // using `mp4parser`
        MP4 -> true
        else -> false
    }

    fun canRemoveMetadata(mimeType: String) = when (mimeType) {
        // as of latest PixyMeta
        JPEG, TIFF -> true
        else -> false
    }

    // Glide automatically applies EXIF orientation when decoding images of known formats
    // but we need to rotate the decoded bitmap for the other formats
    // maybe related to ExifInterface version used by Glide:
    // https://github.com/bumptech/glide/blob/master/gradle.properties#L21
    fun needRotationAfterGlide(mimeType: String, pageId: Int?): Boolean {
        return if (pageId != null && MultiPageImage.isSupported(mimeType)) {
            true
        } else when (mimeType) {
            AVIF, DNG, DNG_ADOBE, HEIC, HEIF, PNG, WEBP -> true
            else -> false
        }
    }

    // Thumbnails obtained from the Media Store are automatically rotated
    // according to EXIF orientation when decoding images of known formats
    // but we need to rotate the decoded bitmap for the other formats
    fun needRotationAfterContentResolverThumbnail(mimeType: String) = when (mimeType) {
        DNG, DNG_ADOBE, PNG -> true
        else -> false
    }

    // extensions

    // among other refs:
    // - https://android.googlesource.com/platform/external/mime-support/+/refs/heads/master/mime.types
    fun extensionFor(mimeType: String): String? = when (mimeType) {
        AVI, AVI_VND -> ".avi"
        HEIC, HEIF -> ".heif"
        MP2T, MP2TS -> ".m2ts"
        PSD_VND, PSD_X -> ".psd"
        else -> MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType)?.let { ".$it" }
    }

    val TIFF_EXTENSION_PATTERN = Regex(".*\\.tiff?", RegexOption.IGNORE_CASE)
}
