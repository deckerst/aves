package deckers.thibault.aves.utils

import androidx.exifinterface.media.ExifInterface

object MimeTypes {
    private const val IMAGE = "image"

    // generic raster
    private const val BMP = "image/bmp"
    const val GIF = "image/gif"
    const val HEIC = "image/heic"
    private const val HEIF = "image/heif"
    private const val ICO = "image/x-icon"
    private const val JPEG = "image/jpeg"
    private const val PNG = "image/png"
    const val TIFF = "image/tiff"
    private const val WBMP = "image/vnd.wap.wbmp"
    const val WEBP = "image/webp"

    // raw raster
    private const val ARW = "image/x-sony-arw"
    private const val CR2 = "image/x-canon-cr2"
    private const val DNG = "image/x-adobe-dng"
    private const val NEF = "image/x-nikon-nef"
    private const val NRW = "image/x-nikon-nrw"
    private const val ORF = "image/x-olympus-orf"
    private const val PEF = "image/x-pentax-pef"
    private const val RAF = "image/x-fuji-raf"
    private const val RW2 = "image/x-panasonic-rw2"
    private const val SRW = "image/x-samsung-srw"

    // vector
    const val SVG = "image/svg+xml"

    private const val VIDEO = "video"

    private const val MP2T = "video/mp2t"
    private const val WEBM = "video/webm"

    fun isImage(mimeType: String?) = mimeType != null && mimeType.startsWith(IMAGE)

    fun isVideo(mimeType: String?) = mimeType != null && mimeType.startsWith(VIDEO)

    fun isHeifLike(mimeType: String?) = mimeType != null && (mimeType == HEIC || mimeType == HEIF)

    fun isMultimedia(mimeType: String?) = isVideo(mimeType) || isHeifLike(mimeType)

    fun isRaw(mimeType: String): Boolean {
        return when (mimeType) {
            ARW, CR2, DNG, NEF, NRW, ORF, PEF, RAF, RW2, SRW -> true
            else -> false
        }
    }

    // returns whether the specified MIME type represents
    // a raster image format that allows an alpha channel
    fun canHaveAlpha(mimeType: String?) = when (mimeType) {
        BMP, GIF, ICO, PNG, TIFF, WEBP -> true
        else -> false
    }

    // as of Flutter v1.22.0, with additional custom handling for SVG
    fun isSupportedByFlutter(mimeType: String, rotationDegrees: Int?, isFlipped: Boolean?) = when (mimeType) {
        JPEG, GIF, WEBP, BMP, WBMP, ICO, SVG -> true
        PNG -> rotationDegrees ?: 0 == 0 && !(isFlipped ?: false)
        else -> false
    }

    // as of `metadata-extractor` v2.14.0
    fun isSupportedByMetadataExtractor(mimeType: String) = when (mimeType) {
        WBMP, MP2T, WEBM -> false
        else -> true
    }

    // as of `ExifInterface` v1.3.1, `isSupportedMimeType` reports
    // no support for TIFF images, but it can actually open them (maybe other formats too)
    fun isSupportedByExifInterface(mimeType: String, strict: Boolean = true) = ExifInterface.isSupportedMimeType(mimeType) || !strict

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

    val tiffExtensionPattern = Regex(".*\\.tiff?", RegexOption.IGNORE_CASE)
}
