package deckers.thibault.aves.utils

import java.util.*

object MimeTypes {
    private const val IMAGE = "image"

    // generic raster
    private const val BMP = "image/bmp"
    const val GIF = "image/gif"
    private const val HEIC = "image/heic"
    private const val HEIF = "image/heif"
    private const val ICO = "image/x-icon"
    private const val JPEG = "image/jpeg"
    private const val PCX = "image/x-pcx"
    private const val PNG = "image/png"
    private const val PSD = "image/x-photoshop" // aka "image/vnd.adobe.photoshop"
    private const val TIFF = "image/tiff"
    private const val WBMP = "image/vnd.wap.wbmp"
    const val WEBP = "image/webp"

    // raw raster
    private const val ARW = "image/x-sony-arw"
    private const val CR2 = "image/x-canon-cr2"
    private const val CRW = "image/x-canon-crw"
    private const val DCR = "image/x-kodak-dcr"
    private const val DNG = "image/x-adobe-dng"
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

    private const val VIDEO = "video"

    private const val AVI = "video/avi"
    private const val MOV = "video/quicktime"
    private const val MP2T = "video/mp2t"
    private const val MP4 = "video/mp4"
    private const val WEBM = "video/webm"

    @JvmStatic
    fun isImage(mimeType: String?) = mimeType != null && mimeType.startsWith(IMAGE)

    @JvmStatic
    fun isVideo(mimeType: String?) = mimeType != null && mimeType.startsWith(VIDEO)

    // as of Flutter v1.22.0
    @JvmStatic
    fun isSupportedByFlutter(mimeType: String, rotationDegrees: Int?) = when (mimeType) {
        JPEG, GIF, WEBP, BMP, WBMP, ICO, SVG -> true
        PNG -> rotationDegrees ?: 0 == 0
        else -> false
    }

    // as of metadata-extractor v2.14.0
    @JvmStatic
    fun isSupportedByMetadataExtractor(mimeType: String) = when (mimeType) {
        WBMP, MP2T, WEBM -> false
        else -> true
    }

    // Glide automatically applies EXIF orientation when decoding images of known formats
    // but we need to rotate the decoded bitmap for the other formats
    @JvmStatic
    fun needRotationAfterGlide(mimeType: String) = when (mimeType) {
        DNG, HEIC, HEIF, PNG, WEBP -> true
        else -> false
    }

    // Thumbnails obtained from the Media Store are automatically rotated
    // according to EXIF orientation when decoding images of known formats
    // but we need to rotate the decoded bitmap for the other formats
    @JvmStatic
    fun needRotationAfterContentResolverThumbnail(mimeType: String) = when (mimeType) {
        DNG, PNG -> true
        else -> false
    }

    @JvmStatic
    fun getMimeTypeForExtension(extension: String?): String? = when (extension?.toLowerCase(Locale.ROOT)) {
        // generic raster
        ".bmp" -> BMP
        ".gif" -> GIF
        ".heic" -> HEIC
        ".heif" -> HEIF
        ".ico" -> ICO
        ".jpg", ".jpeg", ".jpe" -> JPEG
        ".pcx" -> PCX
        ".png" -> PNG
        ".psd" -> PSD
        ".tiff", ".tif" -> TIFF
        ".wbmp" -> WBMP
        ".webp" -> WEBP
        // raw raster
        ".arw" -> ARW
        ".cr2" -> CR2
        ".crw" -> CRW
        ".dcr" -> DCR
        ".dng" -> DNG
        ".erf" -> ERF
        ".k25" -> K25
        ".kdc" -> KDC
        ".mrw" -> MRW
        ".nef" -> NEF
        ".nrw" -> NRW
        ".orf" -> ORF
        ".pef" -> PEF
        ".raf" -> RAF
        ".raw" -> RAW
        ".rw2" -> RW2
        ".sr2" -> SR2
        ".srf" -> SRF
        ".srw" -> SRW
        ".x3f" -> X3F
        // vector
        ".svg" -> SVG
        // video
        ".avi" -> AVI
        ".m2ts" -> MP2T
        ".mov", ".qt" -> MOV
        ".mp4", ".m4a", ".m4p", ".m4b", ".m4r", ".m4v" -> MP4
        else -> null
    }
}
