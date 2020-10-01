package deckers.thibault.aves.utils

import androidx.exifinterface.media.ExifInterface
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

object MetadataHelper {
    // list of known tags from ExifInterface as of androidx.exifinterface:exifinterface:1.3.0
    @JvmField
    val ExifInterfaceTags = arrayOf(
            ExifInterface.TAG_APERTURE_VALUE,
            ExifInterface.TAG_ARTIST,
            ExifInterface.TAG_BITS_PER_SAMPLE,
            ExifInterface.TAG_BODY_SERIAL_NUMBER,
            ExifInterface.TAG_BRIGHTNESS_VALUE,
            ExifInterface.TAG_CAMERA_OWNER_NAME,
            ExifInterface.TAG_CFA_PATTERN,
            ExifInterface.TAG_COLOR_SPACE,
            ExifInterface.TAG_COMPONENTS_CONFIGURATION,
            ExifInterface.TAG_COMPRESSED_BITS_PER_PIXEL,
            ExifInterface.TAG_COMPRESSION,
            ExifInterface.TAG_CONTRAST,
            ExifInterface.TAG_COPYRIGHT,
            ExifInterface.TAG_CUSTOM_RENDERED,
            ExifInterface.TAG_DATETIME,
            ExifInterface.TAG_DATETIME_DIGITIZED,
            ExifInterface.TAG_DATETIME_ORIGINAL,
            ExifInterface.TAG_DEFAULT_CROP_SIZE,
            ExifInterface.TAG_DEVICE_SETTING_DESCRIPTION,
            ExifInterface.TAG_DIGITAL_ZOOM_RATIO,
            ExifInterface.TAG_DNG_VERSION,
            ExifInterface.TAG_EXIF_VERSION,
            ExifInterface.TAG_EXPOSURE_BIAS_VALUE,
            ExifInterface.TAG_EXPOSURE_INDEX,
            ExifInterface.TAG_EXPOSURE_MODE,
            ExifInterface.TAG_EXPOSURE_PROGRAM,
            ExifInterface.TAG_EXPOSURE_TIME,
            ExifInterface.TAG_FILE_SOURCE,
            ExifInterface.TAG_FLASH,
            ExifInterface.TAG_FLASHPIX_VERSION,
            ExifInterface.TAG_FLASH_ENERGY,
            ExifInterface.TAG_FOCAL_LENGTH,
            ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM,
            ExifInterface.TAG_FOCAL_PLANE_RESOLUTION_UNIT,
            ExifInterface.TAG_FOCAL_PLANE_X_RESOLUTION,
            ExifInterface.TAG_FOCAL_PLANE_Y_RESOLUTION,
            ExifInterface.TAG_F_NUMBER,
            ExifInterface.TAG_GAIN_CONTROL,
            ExifInterface.TAG_GAMMA,
            ExifInterface.TAG_GPS_ALTITUDE,
            ExifInterface.TAG_GPS_ALTITUDE_REF,
            ExifInterface.TAG_GPS_AREA_INFORMATION,
            ExifInterface.TAG_GPS_DATESTAMP,
            ExifInterface.TAG_GPS_DEST_BEARING,
            ExifInterface.TAG_GPS_DEST_BEARING_REF,
            ExifInterface.TAG_GPS_DEST_DISTANCE,
            ExifInterface.TAG_GPS_DEST_DISTANCE_REF,
            ExifInterface.TAG_GPS_DEST_LATITUDE,
            ExifInterface.TAG_GPS_DEST_LATITUDE_REF,
            ExifInterface.TAG_GPS_DEST_LONGITUDE,
            ExifInterface.TAG_GPS_DEST_LONGITUDE_REF,
            ExifInterface.TAG_GPS_DIFFERENTIAL,
            ExifInterface.TAG_GPS_DOP,
            ExifInterface.TAG_GPS_H_POSITIONING_ERROR,
            ExifInterface.TAG_GPS_IMG_DIRECTION,
            ExifInterface.TAG_GPS_IMG_DIRECTION_REF,
            ExifInterface.TAG_GPS_LATITUDE,
            ExifInterface.TAG_GPS_LATITUDE_REF,
            ExifInterface.TAG_GPS_LONGITUDE,
            ExifInterface.TAG_GPS_LONGITUDE_REF,
            ExifInterface.TAG_GPS_MAP_DATUM,
            ExifInterface.TAG_GPS_MEASURE_MODE,
            ExifInterface.TAG_GPS_PROCESSING_METHOD,
            ExifInterface.TAG_GPS_SATELLITES,
            ExifInterface.TAG_GPS_SPEED,
            ExifInterface.TAG_GPS_SPEED_REF,
            ExifInterface.TAG_GPS_STATUS,
            ExifInterface.TAG_GPS_TIMESTAMP,
            ExifInterface.TAG_GPS_TRACK,
            ExifInterface.TAG_GPS_TRACK_REF,
            ExifInterface.TAG_GPS_VERSION_ID,
            ExifInterface.TAG_IMAGE_DESCRIPTION,
            ExifInterface.TAG_IMAGE_LENGTH,
            ExifInterface.TAG_IMAGE_UNIQUE_ID,
            ExifInterface.TAG_IMAGE_WIDTH,
            ExifInterface.TAG_INTEROPERABILITY_INDEX,
            ExifInterface.TAG_ISO_SPEED,
            ExifInterface.TAG_ISO_SPEED_LATITUDE_YYY,
            ExifInterface.TAG_ISO_SPEED_LATITUDE_ZZZ,
            ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT,
            ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT_LENGTH,
            ExifInterface.TAG_LENS_MAKE,
            ExifInterface.TAG_LENS_MODEL,
            ExifInterface.TAG_LENS_SERIAL_NUMBER,
            ExifInterface.TAG_LENS_SPECIFICATION,
            ExifInterface.TAG_LIGHT_SOURCE,
            ExifInterface.TAG_MAKE,
            ExifInterface.TAG_MAKER_NOTE,
            ExifInterface.TAG_MAX_APERTURE_VALUE,
            ExifInterface.TAG_METERING_MODE,
            ExifInterface.TAG_MODEL,
            ExifInterface.TAG_NEW_SUBFILE_TYPE,
            ExifInterface.TAG_OECF,
            ExifInterface.TAG_OFFSET_TIME,
            ExifInterface.TAG_OFFSET_TIME_DIGITIZED,
            ExifInterface.TAG_OFFSET_TIME_ORIGINAL,
            ExifInterface.TAG_ORF_ASPECT_FRAME,
            ExifInterface.TAG_ORF_PREVIEW_IMAGE_LENGTH,
            ExifInterface.TAG_ORF_PREVIEW_IMAGE_START,
            ExifInterface.TAG_ORF_THUMBNAIL_IMAGE,
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY,
            ExifInterface.TAG_PHOTOMETRIC_INTERPRETATION,
            ExifInterface.TAG_PIXEL_X_DIMENSION,
            ExifInterface.TAG_PIXEL_Y_DIMENSION,
            ExifInterface.TAG_PLANAR_CONFIGURATION,
            ExifInterface.TAG_PRIMARY_CHROMATICITIES,
            ExifInterface.TAG_RECOMMENDED_EXPOSURE_INDEX,
            ExifInterface.TAG_REFERENCE_BLACK_WHITE,
            ExifInterface.TAG_RELATED_SOUND_FILE,
            ExifInterface.TAG_RESOLUTION_UNIT,
            ExifInterface.TAG_ROWS_PER_STRIP,
            ExifInterface.TAG_RW2_ISO,
            ExifInterface.TAG_RW2_JPG_FROM_RAW,
            ExifInterface.TAG_RW2_SENSOR_BOTTOM_BORDER,
            ExifInterface.TAG_RW2_SENSOR_LEFT_BORDER,
            ExifInterface.TAG_RW2_SENSOR_RIGHT_BORDER,
            ExifInterface.TAG_RW2_SENSOR_TOP_BORDER,
            ExifInterface.TAG_SAMPLES_PER_PIXEL,
            ExifInterface.TAG_SATURATION,
            ExifInterface.TAG_SCENE_CAPTURE_TYPE,
            ExifInterface.TAG_SCENE_TYPE,
            ExifInterface.TAG_SENSING_METHOD,
            ExifInterface.TAG_SENSITIVITY_TYPE,
            ExifInterface.TAG_SHARPNESS,
            ExifInterface.TAG_SHUTTER_SPEED_VALUE,
            ExifInterface.TAG_SOFTWARE,
            ExifInterface.TAG_SPATIAL_FREQUENCY_RESPONSE,
            ExifInterface.TAG_SPECTRAL_SENSITIVITY,
            ExifInterface.TAG_STANDARD_OUTPUT_SENSITIVITY,
            ExifInterface.TAG_STRIP_BYTE_COUNTS,
            ExifInterface.TAG_STRIP_OFFSETS,
            ExifInterface.TAG_SUBFILE_TYPE,
            ExifInterface.TAG_SUBJECT_AREA,
            ExifInterface.TAG_SUBJECT_DISTANCE,
            ExifInterface.TAG_SUBJECT_DISTANCE_RANGE,
            ExifInterface.TAG_SUBJECT_LOCATION,
            ExifInterface.TAG_SUBSEC_TIME,
            ExifInterface.TAG_SUBSEC_TIME_DIGITIZED,
            ExifInterface.TAG_SUBSEC_TIME_ORIGINAL,
            ExifInterface.TAG_THUMBNAIL_IMAGE_LENGTH,
            ExifInterface.TAG_THUMBNAIL_IMAGE_WIDTH,
            ExifInterface.TAG_TRANSFER_FUNCTION,
            ExifInterface.TAG_USER_COMMENT,
            ExifInterface.TAG_WHITE_BALANCE,
            ExifInterface.TAG_WHITE_POINT,
            ExifInterface.TAG_XMP,
            ExifInterface.TAG_X_RESOLUTION,
            ExifInterface.TAG_Y_CB_CR_COEFFICIENTS,
            ExifInterface.TAG_Y_CB_CR_POSITIONING,
            ExifInterface.TAG_Y_CB_CR_SUB_SAMPLING,
            ExifInterface.TAG_Y_RESOLUTION,
    )

    // interpret EXIF code to angle (0, 90, 180 or 270 degrees)
    @JvmStatic
    fun getRotationDegreesForExifCode(exifOrientation: Int): Int = when (exifOrientation) {
        ExifInterface.ORIENTATION_ROTATE_90, ExifInterface.ORIENTATION_TRANSVERSE -> 90
        ExifInterface.ORIENTATION_ROTATE_180, ExifInterface.ORIENTATION_FLIP_VERTICAL -> 180
        ExifInterface.ORIENTATION_ROTATE_270, ExifInterface.ORIENTATION_TRANSPOSE -> 270
        else -> 0
    }

    // interpret EXIF code to whether the image is flipped
    @JvmStatic
    fun isFlippedForExifCode(exifOrientation: Int): Boolean = when (exifOrientation) {
        ExifInterface.ORIENTATION_FLIP_HORIZONTAL, ExifInterface.ORIENTATION_TRANSVERSE, ExifInterface.ORIENTATION_FLIP_VERTICAL, ExifInterface.ORIENTATION_TRANSPOSE -> true
        else -> false
    }

    // yyyyMMddTHHmmss(.sss)?(Z|+/-hhmm)?
    @JvmStatic
    fun parseVideoMetadataDate(metadataDate: String?): Long {
        var dateString = metadataDate ?: return 0

        // optional sub-second
        var subSecond: String? = null
        val subSecondMatcher = Pattern.compile("(\\d{6})(\\.\\d+)").matcher(dateString)
        if (subSecondMatcher.find()) {
            subSecond = subSecondMatcher.group(2)?.substring(1)
            dateString = subSecondMatcher.replaceAll("$1")
        }

        // optional time zone
        var timeZone: TimeZone? = null
        val timeZoneMatcher = Pattern.compile("(Z|[+-]\\d{4})$").matcher(dateString)
        if (timeZoneMatcher.find()) {
            timeZone = TimeZone.getTimeZone("GMT" + timeZoneMatcher.group().replace("Z".toRegex(), ""))
            dateString = timeZoneMatcher.replaceAll("")
        }

        val date: Date = try {
            val parser = SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.US)
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
}