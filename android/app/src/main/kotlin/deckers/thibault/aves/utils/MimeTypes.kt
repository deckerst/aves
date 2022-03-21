package deckers.thibault.aves.utils

import androidx.exifinterface.media.ExifInterface

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
    const val DNG = "image/x-adobe-dng"
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

    fun isImage(mimeType: String?) = mimeType != null && mimeType.startsWith("image")

    fun isVideo(mimeType: String?) = mimeType != null && mimeType.startsWith("video")

    fun isHeic(mimeType: String?) = mimeType != null && (mimeType == HEIC || mimeType == HEIF)

    fun isRaw(mimeType: String): Boolean {
        return when (mimeType) {
            ARW, CR2, DNG, NEF, NRW, ORF, PEF, RAF, RW2, SRW -> true
            else -> false
        }
    }

    // returns whether the specified MIME type represents
    // a raster image format that allows an alpha channel
    fun canHaveAlpha(mimeType: String?) = when (mimeType) {
        AVIF, BMP, GIF, ICO, PNG, SVG, TIFF, WEBP -> true
        else -> false
    }

    // as of Flutter v1.22.0, with additional custom handling for SVG
    fun canDecodeWithFlutter(mimeType: String, rotationDegrees: Int?, isFlipped: Boolean?) = when (mimeType) {
        JPEG, GIF, WEBP, BMP, WBMP, ICO, SVG -> true
        PNG -> rotationDegrees ?: 0 == 0 && !(isFlipped ?: false)
        else -> false
    }

    // as of `metadata-extractor` v2.14.0
    fun canReadWithMetadataExtractor(mimeType: String) = when (mimeType) {
        DJVU, WBMP, MKV, MP2T, MP2TS, OGV, WEBM -> false
        else -> true
    }

    // as of `ExifInterface` v1.3.1, `isSupportedMimeType` reports
    // no support for TIFF images, but it can actually open them (maybe other formats too)
    fun canReadWithExifInterface(mimeType: String, strict: Boolean = true) = ExifInterface.isSupportedMimeType(mimeType) || !strict

    // as of latest PixyMeta
    fun canReadWithPixyMeta(mimeType: String) = when (mimeType) {
        JPEG, TIFF, PNG, GIF, BMP -> true
        else -> false
    }

    // as of androidx.exifinterface:exifinterface:1.3.3
    fun canEditExif(mimeType: String) = when (mimeType) {
        DNG,
        JPEG,
        PNG,
        WEBP -> true
        else -> false
    }

    // as of latest PixyMeta
    fun canEditIptc(mimeType: String) = when (mimeType) {
        JPEG, TIFF -> true
        else -> false
    }

    // as of latest PixyMeta
    fun canEditXmp(mimeType: String) = when (mimeType) {
        JPEG, TIFF, PNG, GIF -> true
        else -> false
    }

    // as of latest PixyMeta
    fun canRemoveMetadata(mimeType: String) = when (mimeType) {
        JPEG, TIFF -> true
        else -> false
    }

    // Glide automatically applies EXIF orientation when decoding images of known formats
    // but we need to rotate the decoded bitmap for the other formats
    // maybe related to ExifInterface version used by Glide:
    // https://github.com/bumptech/glide/blob/master/gradle.properties#L21
    fun needRotationAfterGlide(mimeType: String) = when (mimeType) {
        DNG, HEIC, HEIF, PNG, WEBP -> true
        else -> false
    }

    // Thumbnails obtained from the Media Store are automatically rotated
    // according to EXIF orientation when decoding images of known formats
    // but we need to rotate the decoded bitmap for the other formats
    fun needRotationAfterContentResolverThumbnail(mimeType: String) = when (mimeType) {
        DNG, PNG -> true
        else -> false
    }

    // extensions

    // among other refs:
    // - https://android.googlesource.com/platform/external/mime-support/+/refs/heads/master/mime.types
    fun extensionFor(mimeType: String): String? = when (mimeType) {
        ARW -> ".arw"
        AVI, AVI_VND -> ".avi"
        AVIF -> ".avif"
        BMP -> ".bmp"
        CR2 -> ".cr2"
        CRW -> ".crw"
        DCR -> ".dcr"
        DJVU -> ".djvu"
        DNG -> ".dng"
        ERF -> ".erf"
        GIF -> ".gif"
        HEIC, HEIF -> ".heif"
        ICO -> ".ico"
        JPEG -> ".jpg"
        K25 -> ".k25"
        KDC -> ".kdc"
        MKV -> ".mkv"
        MOV -> ".mov"
        MP2T, MP2TS -> ".m2ts"
        MP4 -> ".mp4"
        MRW -> ".mrw"
        NEF -> ".nef"
        NRW -> ".nrw"
        OGV -> ".ogv"
        ORF -> ".orf"
        PEF -> ".pef"
        PNG -> ".png"
        PSD_VND, PSD_X -> ".psd"
        RAF -> ".raf"
        RAW -> ".raw"
        RW2 -> ".rw2"
        SR2 -> ".sr2"
        SRF -> ".srf"
        SRW -> ".srw"
        SVG -> ".svg"
        TIFF -> ".tiff"
        WBMP -> ".wbmp"
        WEBM -> ".webm"
        WEBP -> ".webp"
        X3F -> ".x3f"
        else -> null
    }

    val TIFF_EXTENSION_PATTERN = Regex(".*\\.tiff?", RegexOption.IGNORE_CASE)
}
