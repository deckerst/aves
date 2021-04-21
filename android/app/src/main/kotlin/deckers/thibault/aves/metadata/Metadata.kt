package deckers.thibault.aves.metadata

import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import java.io.File
import java.io.InputStream
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

object Metadata {
    private val LOG_TAG = LogUtils.createTag<Metadata>()

    // Pattern to extract latitude & longitude from a video location tag (cf ISO 6709)
    // Examples:
    // "+37.5090+127.0243/" (Samsung)
    // "+51.3328-000.7053+113.474/" (Apple)
    val VIDEO_LOCATION_PATTERN: Pattern = Pattern.compile("([+-][.0-9]+)([+-][.0-9]+).*")

    private val VIDEO_DATE_SUBSECOND_PATTERN = Pattern.compile("(\\d{6})(\\.\\d+)")
    private val VIDEO_TIMEZONE_PATTERN = Pattern.compile("(Z|[+-]\\d{4})$")

    // directory names, as shown when listing all metadata
    const val DIR_GPS = "GPS" // from metadata-extractor
    const val DIR_XMP = "XMP" // from metadata-extractor
    const val DIR_MEDIA = "Media" // custom
    const val DIR_COVER_ART = "Cover" // custom

    // interpret EXIF code to angle (0, 90, 180 or 270 degrees)
    fun getRotationDegreesForExifCode(exifOrientation: Int): Int = when (exifOrientation) {
        ExifInterface.ORIENTATION_ROTATE_90, ExifInterface.ORIENTATION_TRANSVERSE -> 90
        ExifInterface.ORIENTATION_ROTATE_180, ExifInterface.ORIENTATION_FLIP_VERTICAL -> 180
        ExifInterface.ORIENTATION_ROTATE_270, ExifInterface.ORIENTATION_TRANSPOSE -> 270
        else -> 0
    }

    // interpret EXIF code to whether the image is flipped
    fun isFlippedForExifCode(exifOrientation: Int): Boolean = when (exifOrientation) {
        ExifInterface.ORIENTATION_FLIP_HORIZONTAL, ExifInterface.ORIENTATION_TRANSVERSE, ExifInterface.ORIENTATION_FLIP_VERTICAL, ExifInterface.ORIENTATION_TRANSPOSE -> true
        else -> false
    }

    fun getExifCode(rotationDegrees: Int, isFlipped: Boolean): Int {
        return when (rotationDegrees) {
            90 -> if (isFlipped) ExifInterface.ORIENTATION_TRANSVERSE else ExifInterface.ORIENTATION_ROTATE_90
            180 -> if (isFlipped) ExifInterface.ORIENTATION_FLIP_VERTICAL else ExifInterface.ORIENTATION_ROTATE_180
            270 -> if (isFlipped) ExifInterface.ORIENTATION_TRANSPOSE else ExifInterface.ORIENTATION_ROTATE_270
            else -> if (isFlipped) ExifInterface.ORIENTATION_FLIP_HORIZONTAL else ExifInterface.ORIENTATION_NORMAL
        }
    }

    // not sure which standards are used for the different video formats,
    // but looks like some form of ISO 8601 `basic format`:
    // yyyyMMddTHHmmss(.sss)?(Z|+/-hhmm)?
    fun parseVideoMetadataDate(metadataDate: String?): Long {
        var dateString = metadataDate ?: return 0

        // optional sub-second
        var subSecond: String? = null
        val subSecondMatcher = VIDEO_DATE_SUBSECOND_PATTERN.matcher(dateString)
        if (subSecondMatcher.find()) {
            subSecond = subSecondMatcher.group(2)?.substring(1)
            dateString = subSecondMatcher.replaceAll("$1")
        }

        // optional time zone
        var timeZone: TimeZone? = null
        val timeZoneMatcher = VIDEO_TIMEZONE_PATTERN.matcher(dateString)
        if (timeZoneMatcher.find()) {
            timeZone = TimeZone.getTimeZone("GMT${timeZoneMatcher.group().replace("Z".toRegex(), "")}")
            dateString = timeZoneMatcher.replaceAll("")
        }

        val date: Date = try {
            val parser = SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.ROOT)
            parser.timeZone = timeZone ?: TimeZone.getTimeZone("GMT")
            parser.parse(dateString)
        } catch (e: ParseException) {
            // ignore
            null
        } ?: return 0

        var dateMillis = date.time
        if (subSecond != null) {
            try {
                val millis = (".$subSecond".toDouble() * 1000).toInt()
                if (millis in 0..999) {
                    dateMillis += millis.toLong()
                }
            } catch (e: NumberFormatException) {
                // ignore
            }
        }
        return dateMillis
    }

    // opening large PSD/TIFF files yields an OOM (both with `metadata-extractor` v2.15.0 and `ExifInterface` v1.3.1),
    // so we define an arbitrary threshold to avoid a crash on launch.
    // It is not clear whether it is because of the file itself or its metadata.
    private const val fileSizeBytesMax = 100 * (1 shl 20) // MB

    // we try and read metadata from large files by copying an arbitrary amount from its beginning
    // to a temporary file, and reusing that preview file for all metadata reading purposes
    private const val previewSize = 5 * (1 shl 20) // MB

    private val previewFiles = HashMap<Uri, File>()

    private fun getSafeUri(context: Context, uri: Uri, mimeType: String, sizeBytes: Long?): Uri {
        return when (mimeType) {
            // formats known to yield OOM for large files
            MimeTypes.PSD_VND,
            MimeTypes.PSD_X,
            MimeTypes.TIFF -> {
                if (sizeBytes != null && sizeBytes < fileSizeBytesMax) {
                    // small enough to be safe as it is
                    uri
                } else {
                    // make a preview from the beginning of the file,
                    // hoping the metadata is accessible in the copied chunk
                    Log.d(LOG_TAG, "use a preview for uri=$uri mimeType=$mimeType size=$sizeBytes")
                    var previewFile = previewFiles[uri]
                    if (previewFile == null) {
                        previewFile = File.createTempFile("aves", null, context.cacheDir).apply {
                            deleteOnExit()
                            outputStream().use { outputStream ->
                                StorageUtils.openInputStream(context, uri)?.use { inputStream ->
                                    val b = ByteArray(previewSize)
                                    inputStream.read(b, 0, previewSize)
                                    outputStream.write(b)
                                }
                            }
                        }
                        previewFiles[uri] = previewFile
                    }
                    Uri.fromFile(previewFile)
                }
            }
            // *probably* safe
            else -> uri
        }
    }

    fun openSafeInputStream(context: Context, uri: Uri, mimeType: String, sizeBytes: Long?): InputStream? {
        val safeUri = getSafeUri(context, uri, mimeType, sizeBytes)
        return StorageUtils.openInputStream(context, safeUri)
    }
}