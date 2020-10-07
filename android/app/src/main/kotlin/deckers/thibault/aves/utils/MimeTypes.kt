package deckers.thibault.aves.utils

import java.util.*

object MimeTypes {
    const val IMAGE = "image"

    // generic raster
    const val BMP = "image/bmp"
    const val GIF = "image/gif"
    const val HEIC = "image/heic"
    const val HEIF = "image/heif"
    const val ICO = "image/x-icon"
    const val JPEG = "image/jpeg"
    const val PCX = "image/x-pcx"
    const val PNG = "image/png"
    const val PSD = "image/x-photoshop" // aka "image/vnd.adobe.photoshop"
    const val TIFF = "image/tiff"
    const val WBMP = "image/vnd.wap.wbmp"
    const val WEBP = "image/webp"

    // raw raster
    const val ARW = "image/x-sony-arw"
    const val CR2 = "image/x-canon-cr2"
    const val CRW = "image/x-canon-crw"
    const val DCR = "image/x-kodak-dcr"
    const val DNG = "image/x-adobe-dng"
    const val ERF = "image/x-epson-erf"
    const val K25 = "image/x-kodak-k25"
    const val KDC = "image/x-kodak-kdc"
    const val MRW = "image/x-minolta-mrw"
    const val NEF = "image/x-nikon-nef"
    const val NRW = "image/x-nikon-nrw"
    const val ORF = "image/x-olympus-orf"
    const val PEF = "image/x-pentax-pef"
    const val RAF = "image/x-fuji-raf"
    const val RAW = "image/x-panasonic-raw"
    const val RW2 = "image/x-panasonic-rw2"
    const val SR2 = "image/x-sony-sr2"
    const val SRF = "image/x-sony-srf"
    const val SRW = "image/x-samsung-srw"
    const val X3F = "image/x-sigma-x3f"

    // vector
    const val SVG = "image/svg+xml"

    const val VIDEO = "video"

    const val AVI = "video/avi"
    const val MOV = "video/quicktime"
    const val MP2T = "video/mp2t"
    const val MP4 = "video/mp4"
    const val WEBM = "video/webm"

    // as of metadata-extractor v2.14.0, the following formats are not supported
    private val unsupportedMetadataExtractorFormats = listOf(WBMP, MP2T, WEBM)

    @JvmStatic
    fun isSupportedByMetadataExtractor(mimeType: String) = !unsupportedMetadataExtractorFormats.contains(mimeType)

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
