package deckers.thibault.aves.utils

object MimeTypes {
    private const val IMAGE = "image"

    // generic raster
    private const val BMP = "image/bmp"
    const val GIF = "image/gif"
    private const val HEIC = "image/heic"
    private const val HEIF = "image/heif"
    private const val ICO = "image/x-icon"
    private const val JPEG = "image/jpeg"
    private const val PNG = "image/png"
    const val TIFF = "image/tiff"
    private const val WBMP = "image/vnd.wap.wbmp"
    const val WEBP = "image/webp"

    // raw raster
    private const val DNG = "image/x-adobe-dng"

    // vector
    const val SVG = "image/svg+xml"

    private const val VIDEO = "video"

    private const val MP2T = "video/mp2t"
    private const val WEBM = "video/webm"

    @JvmStatic
    fun isImage(mimeType: String?) = mimeType != null && mimeType.startsWith(IMAGE)

    @JvmStatic
    fun isVideo(mimeType: String?) = mimeType != null && mimeType.startsWith(VIDEO)

    // as of Flutter v1.22.0
    @JvmStatic
    fun isSupportedByFlutter(mimeType: String, rotationDegrees: Int?, isFlipped: Boolean?) = when (mimeType) {
        JPEG, GIF, WEBP, BMP, WBMP, ICO, SVG -> true
        PNG -> rotationDegrees ?: 0 == 0 && !(isFlipped ?: false)
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
    // maybe related to ExifInterface version used by Glide:
    // https://github.com/bumptech/glide/blob/master/gradle.properties#L21
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
}
