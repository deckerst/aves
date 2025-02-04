package deckers.thibault.aves.metadata

import android.util.Log
import com.drew.lang.Rational
import com.drew.metadata.Directory
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifThumbnailDirectory
import com.drew.metadata.exif.GpsDirectory
import com.drew.metadata.exif.PanasonicRawIFD0Directory
import com.drew.metadata.exif.makernotes.OlympusCameraSettingsMakernoteDirectory
import com.drew.metadata.exif.makernotes.OlympusImageProcessingMakernoteDirectory
import com.drew.metadata.exif.makernotes.OlympusMakernoteDirectory
import deckers.thibault.aves.utils.LogUtils
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Locale
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.roundToLong
import androidx.exifinterface.media.ExifInterfaceFork as ExifInterface

object ExifInterfaceHelper {
    private val LOG_TAG = LogUtils.createTag<ExifInterfaceHelper>()
    val DATETIME_FORMAT = SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.ROOT)
    val GPS_DATE_FORMAT = SimpleDateFormat("yyyy:MM:dd", Locale.ROOT)
    val GPS_TIME_FORMAT = SimpleDateFormat("HH:mm:ss", Locale.ROOT)

    private const val PRECISION_ERROR_TOLERANCE = 1e-10

    // ExifInterface always states it has the following attributes
    // and returns "0" instead of "null" when they are actually missing
    private val neverNullTags = listOf(
        ExifInterface.TAG_IMAGE_LENGTH,
        ExifInterface.TAG_IMAGE_WIDTH,
        ExifInterface.TAG_LIGHT_SOURCE,
        ExifInterface.TAG_ORIENTATION,
    )

    private fun isNeverNull(tag: String): Boolean = neverNullTags.contains(tag)

    private val baseTags: Map<String, TagMapper?> = mapOf(
        ExifInterface.TAG_APERTURE_VALUE to TagMapper(ExifDirectoryBase.TAG_APERTURE, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_ARTIST to TagMapper(ExifDirectoryBase.TAG_ARTIST, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_BITS_PER_SAMPLE to TagMapper(ExifDirectoryBase.TAG_BITS_PER_SAMPLE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_BODY_SERIAL_NUMBER to TagMapper(ExifDirectoryBase.TAG_BODY_SERIAL_NUMBER, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_BRIGHTNESS_VALUE to TagMapper(ExifDirectoryBase.TAG_BRIGHTNESS_VALUE, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_CAMERA_OWNER_NAME to TagMapper(ExifDirectoryBase.TAG_CAMERA_OWNER_NAME, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_CFA_PATTERN to TagMapper(ExifDirectoryBase.TAG_CFA_PATTERN, DirType.EXIF_IFD0, TagFormat.BYTE), // spec format: UNDEFINED, e.g. [Red,Green][Green,Blue]
        ExifInterface.TAG_COLOR_SPACE to TagMapper(ExifDirectoryBase.TAG_COLOR_SPACE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_COMPONENTS_CONFIGURATION to TagMapper(ExifDirectoryBase.TAG_COMPONENTS_CONFIGURATION, DirType.EXIF_IFD0, TagFormat.BYTE), // spec format: UNDEFINED, e.g. [Y,Cb,Cr]
        ExifInterface.TAG_COMPRESSED_BITS_PER_PIXEL to TagMapper(ExifDirectoryBase.TAG_COMPRESSED_AVERAGE_BITS_PER_PIXEL, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_COMPRESSION to TagMapper(ExifDirectoryBase.TAG_COMPRESSION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_CONTRAST to TagMapper(ExifDirectoryBase.TAG_CONTRAST, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_COPYRIGHT to TagMapper(ExifDirectoryBase.TAG_COPYRIGHT, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_CUSTOM_RENDERED to TagMapper(ExifDirectoryBase.TAG_CUSTOM_RENDERED, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_DATETIME to TagMapper(ExifDirectoryBase.TAG_DATETIME, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_DATETIME_DIGITIZED to TagMapper(ExifDirectoryBase.TAG_DATETIME_DIGITIZED, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_DATETIME_ORIGINAL to TagMapper(ExifDirectoryBase.TAG_DATETIME_ORIGINAL, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_DEVICE_SETTING_DESCRIPTION to TagMapper(ExifDirectoryBase.TAG_DEVICE_SETTING_DESCRIPTION, DirType.EXIF_IFD0, TagFormat.UNDEFINED),
        ExifInterface.TAG_DIGITAL_ZOOM_RATIO to TagMapper(ExifDirectoryBase.TAG_DIGITAL_ZOOM_RATIO, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_EXIF_VERSION to TagMapper(ExifDirectoryBase.TAG_EXIF_VERSION, DirType.EXIF_IFD0, TagFormat.UNDEFINED),
        ExifInterface.TAG_EXPOSURE_BIAS_VALUE to TagMapper(ExifDirectoryBase.TAG_EXPOSURE_BIAS, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_EXPOSURE_INDEX to TagMapper(ExifDirectoryBase.TAG_EXPOSURE_INDEX, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_EXPOSURE_MODE to TagMapper(ExifDirectoryBase.TAG_EXPOSURE_MODE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_EXPOSURE_PROGRAM to TagMapper(ExifDirectoryBase.TAG_EXPOSURE_PROGRAM, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_EXPOSURE_TIME to TagMapper(ExifDirectoryBase.TAG_EXPOSURE_TIME, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_FILE_SOURCE to TagMapper(ExifDirectoryBase.TAG_FILE_SOURCE, DirType.EXIF_IFD0, TagFormat.SHORT), // spec format: UNDEFINED
        ExifInterface.TAG_FLASH to TagMapper(ExifDirectoryBase.TAG_FLASH, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_FLASHPIX_VERSION to TagMapper(ExifDirectoryBase.TAG_FLASHPIX_VERSION, DirType.EXIF_IFD0, TagFormat.UNDEFINED),
        ExifInterface.TAG_FLASH_ENERGY to TagMapper(ExifDirectoryBase.TAG_FLASH_ENERGY, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_FOCAL_LENGTH to TagMapper(ExifDirectoryBase.TAG_FOCAL_LENGTH, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM to TagMapper(ExifDirectoryBase.TAG_35MM_FILM_EQUIV_FOCAL_LENGTH, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_FOCAL_PLANE_RESOLUTION_UNIT to TagMapper(ExifDirectoryBase.TAG_FOCAL_PLANE_RESOLUTION_UNIT, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_FOCAL_PLANE_X_RESOLUTION to TagMapper(ExifDirectoryBase.TAG_FOCAL_PLANE_X_RESOLUTION, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_FOCAL_PLANE_Y_RESOLUTION to TagMapper(ExifDirectoryBase.TAG_FOCAL_PLANE_Y_RESOLUTION, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_F_NUMBER to TagMapper(ExifDirectoryBase.TAG_FNUMBER, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_GAIN_CONTROL to TagMapper(ExifDirectoryBase.TAG_GAIN_CONTROL, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_GAMMA to TagMapper(ExifDirectoryBase.TAG_GAMMA, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_IMAGE_DESCRIPTION to TagMapper(ExifDirectoryBase.TAG_IMAGE_DESCRIPTION, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_IMAGE_LENGTH to TagMapper(ExifDirectoryBase.TAG_IMAGE_HEIGHT, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_IMAGE_UNIQUE_ID to TagMapper(ExifDirectoryBase.TAG_IMAGE_UNIQUE_ID, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_IMAGE_WIDTH to TagMapper(ExifDirectoryBase.TAG_IMAGE_WIDTH, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_INTEROPERABILITY_INDEX to TagMapper(ExifDirectoryBase.TAG_INTEROP_INDEX, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_ISO_SPEED to TagMapper(ExifDirectoryBase.TAG_ISO_SPEED, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_ISO_SPEED_LATITUDE_YYY to TagMapper(ExifDirectoryBase.TAG_ISO_SPEED_LATITUDE_YYY, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_ISO_SPEED_LATITUDE_ZZZ to TagMapper(ExifDirectoryBase.TAG_ISO_SPEED_LATITUDE_ZZZ, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_LENS_MAKE to TagMapper(ExifDirectoryBase.TAG_LENS_MAKE, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_LENS_MODEL to TagMapper(ExifDirectoryBase.TAG_LENS_MODEL, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_LENS_SERIAL_NUMBER to TagMapper(ExifDirectoryBase.TAG_LENS_SERIAL_NUMBER, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_LENS_SPECIFICATION to TagMapper(ExifDirectoryBase.TAG_LENS_SPECIFICATION, DirType.EXIF_IFD0, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_LIGHT_SOURCE to TagMapper(ExifDirectoryBase.TAG_WHITE_BALANCE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_MAKE to TagMapper(ExifDirectoryBase.TAG_MAKE, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_MAKER_NOTE to TagMapper(ExifDirectoryBase.TAG_MAKERNOTE, DirType.EXIF_IFD0, TagFormat.UNDEFINED),
        ExifInterface.TAG_MAX_APERTURE_VALUE to TagMapper(ExifDirectoryBase.TAG_MAX_APERTURE, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_METERING_MODE to TagMapper(ExifDirectoryBase.TAG_METERING_MODE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_MODEL to TagMapper(ExifDirectoryBase.TAG_MODEL, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_NEW_SUBFILE_TYPE to TagMapper(ExifDirectoryBase.TAG_NEW_SUBFILE_TYPE, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_OECF to TagMapper(ExifDirectoryBase.TAG_OPTO_ELECTRIC_CONVERSION_FUNCTION, DirType.EXIF_IFD0, TagFormat.UNDEFINED),
        ExifInterface.TAG_OFFSET_TIME to TagMapper(ExifDirectoryBase.TAG_TIME_ZONE, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_OFFSET_TIME_DIGITIZED to TagMapper(ExifDirectoryBase.TAG_TIME_ZONE_DIGITIZED, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_OFFSET_TIME_ORIGINAL to TagMapper(ExifDirectoryBase.TAG_TIME_ZONE_ORIGINAL, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_ORIENTATION to TagMapper(ExifDirectoryBase.TAG_ORIENTATION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY to TagMapper(ExifDirectoryBase.TAG_ISO_EQUIVALENT, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_PHOTOMETRIC_INTERPRETATION to TagMapper(ExifDirectoryBase.TAG_PHOTOMETRIC_INTERPRETATION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_PIXEL_X_DIMENSION to TagMapper(ExifDirectoryBase.TAG_EXIF_IMAGE_WIDTH, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_PIXEL_Y_DIMENSION to TagMapper(ExifDirectoryBase.TAG_EXIF_IMAGE_HEIGHT, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_PLANAR_CONFIGURATION to TagMapper(ExifDirectoryBase.TAG_PLANAR_CONFIGURATION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_PRIMARY_CHROMATICITIES to TagMapper(ExifDirectoryBase.TAG_PRIMARY_CHROMATICITIES, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_RECOMMENDED_EXPOSURE_INDEX to TagMapper(ExifDirectoryBase.TAG_RECOMMENDED_EXPOSURE_INDEX, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_REFERENCE_BLACK_WHITE to TagMapper(ExifDirectoryBase.TAG_REFERENCE_BLACK_WHITE, DirType.EXIF_IFD0, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_RELATED_SOUND_FILE to TagMapper(ExifDirectoryBase.TAG_RELATED_SOUND_FILE, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_RESOLUTION_UNIT to TagMapper(ExifDirectoryBase.TAG_RESOLUTION_UNIT, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_ROWS_PER_STRIP to TagMapper(ExifDirectoryBase.TAG_ROWS_PER_STRIP, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_SAMPLES_PER_PIXEL to TagMapper(ExifDirectoryBase.TAG_SAMPLES_PER_PIXEL, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SATURATION to TagMapper(ExifDirectoryBase.TAG_SATURATION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SCENE_CAPTURE_TYPE to TagMapper(ExifDirectoryBase.TAG_SCENE_CAPTURE_TYPE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SCENE_TYPE to TagMapper(ExifDirectoryBase.TAG_SCENE_TYPE, DirType.EXIF_IFD0, TagFormat.SHORT), // spec format: UNDEFINED
        ExifInterface.TAG_SENSING_METHOD to TagMapper(ExifDirectoryBase.TAG_SENSING_METHOD, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SENSITIVITY_TYPE to TagMapper(ExifDirectoryBase.TAG_SENSITIVITY_TYPE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SHARPNESS to TagMapper(ExifDirectoryBase.TAG_SHARPNESS, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SHUTTER_SPEED_VALUE to TagMapper(ExifDirectoryBase.TAG_SHUTTER_SPEED, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_SOFTWARE to TagMapper(ExifDirectoryBase.TAG_SOFTWARE, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_SPATIAL_FREQUENCY_RESPONSE to TagMapper(ExifDirectoryBase.TAG_SPATIAL_FREQ_RESPONSE, DirType.EXIF_IFD0, TagFormat.UNDEFINED),
        ExifInterface.TAG_SPECTRAL_SENSITIVITY to TagMapper(ExifDirectoryBase.TAG_SPECTRAL_SENSITIVITY, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_STANDARD_OUTPUT_SENSITIVITY to TagMapper(ExifDirectoryBase.TAG_STANDARD_OUTPUT_SENSITIVITY, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_STRIP_BYTE_COUNTS to TagMapper(ExifDirectoryBase.TAG_STRIP_BYTE_COUNTS, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_STRIP_OFFSETS to TagMapper(ExifDirectoryBase.TAG_STRIP_OFFSETS, DirType.EXIF_IFD0, TagFormat.LONG),
        ExifInterface.TAG_SUBFILE_TYPE to TagMapper(ExifDirectoryBase.TAG_SUBFILE_TYPE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SUBJECT_AREA to TagMapper(ExifDirectoryBase.TAG_SUBJECT_LOCATION_TIFF_EP, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SUBJECT_DISTANCE to TagMapper(ExifDirectoryBase.TAG_SUBJECT_DISTANCE, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_SUBJECT_DISTANCE_RANGE to TagMapper(ExifDirectoryBase.TAG_SUBJECT_DISTANCE_RANGE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SUBJECT_LOCATION to TagMapper(ExifDirectoryBase.TAG_SUBJECT_LOCATION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_SUBSEC_TIME to TagMapper(ExifDirectoryBase.TAG_SUBSECOND_TIME, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_SUBSEC_TIME_DIGITIZED to TagMapper(ExifDirectoryBase.TAG_SUBSECOND_TIME_DIGITIZED, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_SUBSEC_TIME_ORIGINAL to TagMapper(ExifDirectoryBase.TAG_SUBSECOND_TIME_ORIGINAL, DirType.EXIF_IFD0, TagFormat.ASCII),
        ExifInterface.TAG_THUMBNAIL_IMAGE_LENGTH to TagMapper(ExifDirectoryBase.TAG_IMAGE_HEIGHT, DirType.EXIF_IFD0, TagFormat.LONG), // IFD_THUMBNAIL_TAGS 0x0101
        ExifInterface.TAG_THUMBNAIL_IMAGE_WIDTH to TagMapper(ExifDirectoryBase.TAG_IMAGE_WIDTH, DirType.EXIF_IFD0, TagFormat.LONG), // IFD_THUMBNAIL_TAGS 0x0100
        ExifInterface.TAG_TRANSFER_FUNCTION to TagMapper(ExifDirectoryBase.TAG_TRANSFER_FUNCTION, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_USER_COMMENT to TagMapper(ExifDirectoryBase.TAG_USER_COMMENT, DirType.EXIF_IFD0, TagFormat.COMMENT),
        ExifInterface.TAG_WHITE_BALANCE to TagMapper(ExifDirectoryBase.TAG_WHITE_BALANCE, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_WHITE_POINT to TagMapper(ExifDirectoryBase.TAG_WHITE_POINT, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_X_RESOLUTION to TagMapper(ExifDirectoryBase.TAG_X_RESOLUTION, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_Y_CB_CR_COEFFICIENTS to TagMapper(ExifDirectoryBase.TAG_YCBCR_COEFFICIENTS, DirType.EXIF_IFD0, TagFormat.RATIONAL),
        ExifInterface.TAG_Y_CB_CR_POSITIONING to TagMapper(ExifDirectoryBase.TAG_YCBCR_POSITIONING, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_Y_CB_CR_SUB_SAMPLING to TagMapper(ExifDirectoryBase.TAG_YCBCR_SUBSAMPLING, DirType.EXIF_IFD0, TagFormat.SHORT),
        ExifInterface.TAG_Y_RESOLUTION to TagMapper(ExifDirectoryBase.TAG_Y_RESOLUTION, DirType.EXIF_IFD0, TagFormat.RATIONAL),
    )

    private val thumbnailTags: Map<String, TagMapper?> = mapOf(
        ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT to TagMapper(ExifThumbnailDirectory.TAG_THUMBNAIL_OFFSET, DirType.EXIF_THUMBNAIL, TagFormat.LONG), // IFD_TIFF_TAGS or IFD_THUMBNAIL_TAGS 0x0201
        ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT_LENGTH to TagMapper(ExifThumbnailDirectory.TAG_THUMBNAIL_LENGTH, DirType.EXIF_THUMBNAIL, TagFormat.LONG), // IFD_TIFF_TAGS or IFD_THUMBNAIL_TAGS 0x0202
    )

    private val gpsTags: Map<String, TagMapper?> = mapOf(
        ExifInterface.TAG_GPS_ALTITUDE to TagMapper(GpsDirectory.TAG_ALTITUDE, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_ALTITUDE_REF to TagMapper(GpsDirectory.TAG_ALTITUDE_REF, DirType.GPS, TagFormat.BYTE),
        ExifInterface.TAG_GPS_AREA_INFORMATION to TagMapper(GpsDirectory.TAG_AREA_INFORMATION, DirType.GPS, TagFormat.COMMENT),
        ExifInterface.TAG_GPS_DATESTAMP to TagMapper(GpsDirectory.TAG_DATE_STAMP, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_DEST_BEARING to TagMapper(GpsDirectory.TAG_DEST_BEARING, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_DEST_BEARING_REF to TagMapper(GpsDirectory.TAG_DEST_BEARING_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_DEST_DISTANCE to TagMapper(GpsDirectory.TAG_DEST_DISTANCE, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_DEST_DISTANCE_REF to TagMapper(GpsDirectory.TAG_DEST_DISTANCE_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_DEST_LATITUDE to TagMapper(GpsDirectory.TAG_DEST_LATITUDE, DirType.GPS, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_GPS_DEST_LATITUDE_REF to TagMapper(GpsDirectory.TAG_DEST_LATITUDE_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_DEST_LONGITUDE to TagMapper(GpsDirectory.TAG_DEST_LONGITUDE, DirType.GPS, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_GPS_DEST_LONGITUDE_REF to TagMapper(GpsDirectory.TAG_DEST_LONGITUDE_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_DIFFERENTIAL to TagMapper(GpsDirectory.TAG_DIFFERENTIAL, DirType.GPS, TagFormat.SHORT),
        ExifInterface.TAG_GPS_DOP to TagMapper(GpsDirectory.TAG_DOP, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_H_POSITIONING_ERROR to TagMapper(GpsDirectory.TAG_H_POSITIONING_ERROR, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_IMG_DIRECTION to TagMapper(GpsDirectory.TAG_IMG_DIRECTION, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_IMG_DIRECTION_REF to TagMapper(GpsDirectory.TAG_IMG_DIRECTION_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_LATITUDE to TagMapper(GpsDirectory.TAG_LATITUDE, DirType.GPS, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_GPS_LATITUDE_REF to TagMapper(GpsDirectory.TAG_LATITUDE_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_LONGITUDE to TagMapper(GpsDirectory.TAG_LONGITUDE, DirType.GPS, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_GPS_LONGITUDE_REF to TagMapper(GpsDirectory.TAG_LONGITUDE_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_MAP_DATUM to TagMapper(GpsDirectory.TAG_MAP_DATUM, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_MEASURE_MODE to TagMapper(GpsDirectory.TAG_MEASURE_MODE, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_PROCESSING_METHOD to TagMapper(GpsDirectory.TAG_PROCESSING_METHOD, DirType.GPS, TagFormat.COMMENT),
        ExifInterface.TAG_GPS_SATELLITES to TagMapper(GpsDirectory.TAG_SATELLITES, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_SPEED to TagMapper(GpsDirectory.TAG_SPEED, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_SPEED_REF to TagMapper(GpsDirectory.TAG_SPEED_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_STATUS to TagMapper(GpsDirectory.TAG_STATUS, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_TIMESTAMP to TagMapper(GpsDirectory.TAG_TIME_STAMP, DirType.GPS, TagFormat.RATIONAL_ARRAY),
        ExifInterface.TAG_GPS_TRACK to TagMapper(GpsDirectory.TAG_TRACK, DirType.GPS, TagFormat.RATIONAL),
        ExifInterface.TAG_GPS_TRACK_REF to TagMapper(GpsDirectory.TAG_TRACK_REF, DirType.GPS, TagFormat.ASCII),
        ExifInterface.TAG_GPS_VERSION_ID to TagMapper(GpsDirectory.TAG_VERSION_ID, DirType.GPS, TagFormat.BYTE),
    )

    private val xmpTags: Map<String, TagMapper?> = mapOf(
        ExifInterface.TAG_XMP to null, // IFD_TIFF_TAGS 0x02BC
    )

    private val rawTags: Map<String, TagMapper?> = mapOf(
        // DNG
        ExifInterface.TAG_DEFAULT_CROP_SIZE to null, // IFD_EXIF_TAGS 0xC620
        ExifInterface.TAG_DNG_VERSION to null, // IFD_EXIF_TAGS 0xC612
        // ORF
        ExifInterface.TAG_ORF_ASPECT_FRAME to TagMapper(OlympusImageProcessingMakernoteDirectory.TagAspectFrame, DirType.OIPM, TagFormat.LONG), // ORF_IMAGE_PROCESSING_TAGS 0x1113
        ExifInterface.TAG_ORF_PREVIEW_IMAGE_LENGTH to TagMapper(OlympusCameraSettingsMakernoteDirectory.TagPreviewImageLength, DirType.OCSM, TagFormat.LONG), // ORF_CAMERA_SETTINGS_TAGS 0x0102
        ExifInterface.TAG_ORF_PREVIEW_IMAGE_START to TagMapper(OlympusCameraSettingsMakernoteDirectory.TagPreviewImageStart, DirType.OCSM, TagFormat.LONG), // ORF_CAMERA_SETTINGS_TAGS 0x0101
        ExifInterface.TAG_ORF_THUMBNAIL_IMAGE to TagMapper(OlympusMakernoteDirectory.TAG_THUMBNAIL_IMAGE, DirType.OM, TagFormat.UNDEFINED), // ORF_MAKER_NOTE_TAGS 0x0100
        // RW2
        ExifInterface.TAG_RW2_ISO to TagMapper(PanasonicRawIFD0Directory.TagIso, DirType.PRIFD0, TagFormat.LONG), // IFD_TIFF_TAGS 0x0017
        ExifInterface.TAG_RW2_JPG_FROM_RAW to TagMapper(PanasonicRawIFD0Directory.TagJpgFromRaw, DirType.PRIFD0, TagFormat.UNDEFINED), // IFD_TIFF_TAGS 0x002E
        ExifInterface.TAG_RW2_SENSOR_BOTTOM_BORDER to TagMapper(PanasonicRawIFD0Directory.TagSensorBottomBorder, DirType.PRIFD0, TagFormat.LONG), // IFD_TIFF_TAGS 0x0006
        ExifInterface.TAG_RW2_SENSOR_LEFT_BORDER to TagMapper(PanasonicRawIFD0Directory.TagSensorLeftBorder, DirType.PRIFD0, TagFormat.LONG), // IFD_TIFF_TAGS 0x0005
        ExifInterface.TAG_RW2_SENSOR_RIGHT_BORDER to TagMapper(PanasonicRawIFD0Directory.TagSensorRightBorder, DirType.PRIFD0, TagFormat.LONG), // IFD_TIFF_TAGS 0x0007
        ExifInterface.TAG_RW2_SENSOR_TOP_BORDER to TagMapper(PanasonicRawIFD0Directory.TagSensorTopBorder, DirType.PRIFD0, TagFormat.LONG), // IFD_TIFF_TAGS 0x0004
    )

    // list of known ExifInterface tags (as of androidx.exifinterface:exifinterface:1.3.0)
    // mapped to metadata-extractor tags (as of v2.14.0)
    val allTags: Map<String, TagMapper?> = hashMapOf<String, TagMapper?>(
    ).apply {
        putAll(baseTags)
        putAll(thumbnailTags)
        putAll(gpsTags)
        putAll(xmpTags)
        putAll(rawTags)
    }

    fun describeAll(exif: ExifInterface): Map<String, Map<String, String>> {
        // initialize metadata-extractor directories that we will fill
        // by tags converted from the ExifInterface attributes
        // so that we can rely on metadata-extractor descriptions
        val dirs = DirType.entries.associateWith { it.createDirectory() }

        // exclude Exif directory when it only includes image size
        val isUselessExif = fun(it: Map<String, String>): Boolean {
            return it.size == 2 && it.containsKey("Image Height") && it.containsKey("Image Width")
        }

        return HashMap<String, Map<String, String>>().apply {
            put("Exif", describeDir(exif, dirs, baseTags).takeUnless(isUselessExif) ?: hashMapOf())
            put("Exif Thumbnail", describeDir(exif, dirs, thumbnailTags))
            put(Metadata.DIR_GPS, describeDir(exif, dirs, gpsTags))
            put(Metadata.DIR_XMP, describeDir(exif, dirs, xmpTags))
            put("Exif Raw", describeDir(exif, dirs, rawTags))
        }.filterValues { it.isNotEmpty() }
    }

    private fun describeDir(exif: ExifInterface, metadataExtractorDirs: Map<DirType, Directory>, tags: Map<String, TagMapper?>): Map<String, String> {
        val dirMap = HashMap<String, String>()

        fillMetadataExtractorDir(exif, metadataExtractorDirs, tags)

        for ((exifInterfaceTag, mapper) in tags) {
            if (exif.hasAttribute(exifInterfaceTag)) {
                val value: String? = exif.getAttribute(exifInterfaceTag)
                if (value != null && !(value == "0" && isNeverNull(exifInterfaceTag))) {
                    if (mapper != null) {
                        val dir = metadataExtractorDirs[mapper.dirType] ?: error("Directory type ${mapper.dirType} does not have a matching Directory instance")
                        val type = mapper.type
                        val tagName = dir.getTagName(type)

                        val description: String? = dir.getDescription(type)
                        if (description != null) {
                            dirMap[tagName] = description
                        } else {
                            Log.w(LOG_TAG, "failed to get description for tag=$exifInterfaceTag value=$value")
                            dirMap[tagName] = value
                        }
                    } else {
                        dirMap[exifInterfaceTag] = value
                    }
                }
            }
        }
        return dirMap
    }

    private fun fillMetadataExtractorDir(exif: ExifInterface, metadataExtractorDirs: Map<DirType, Directory>, tags: Map<String, TagMapper?>) {
        for ((exifInterfaceTag, mapper) in tags) {
            if (exif.hasAttribute(exifInterfaceTag) && mapper != null) {
                val value: String? = exif.getAttribute(exifInterfaceTag)
                if (value != null && (value != "0" || !neverNullTags.contains(exifInterfaceTag))) {
                    val obj: Any? = when (mapper.format) {
                        TagFormat.ASCII, TagFormat.COMMENT, TagFormat.UNDEFINED -> value
                        TagFormat.BYTE -> exif.getAttributeBytes(exifInterfaceTag)
                        TagFormat.SHORT -> value.toShortOrNull()
                        TagFormat.LONG -> value.toLongOrNull()
                        TagFormat.RATIONAL -> toRational(value)
                        TagFormat.RATIONAL_ARRAY -> toRationalArray(value)
                        null -> null
                    }
                    if (obj != null) {
                        val dir = metadataExtractorDirs[mapper.dirType] ?: error("Directory type ${mapper.dirType} does not have a matching Directory instance")
                        dir.setObject(mapper.type, obj)
                    }
                }
            }
        }
    }

    private fun toRational(s: String?): Rational? {
        s ?: return null

        // e.g. "12345/100" to Rational(12345, 100)
        val parts = s.split("/")
        if (parts.size == 2) {
            val numerator = parts[0].toLongOrNull() ?: return null
            val denominator = parts[1].toLongOrNull() ?: return null
            return Rational(numerator, denominator)
        }

        var d = s.toDoubleOrNull() ?: return null
        if (d == 0.0) return Rational(0, 1)

        // e.g. "0.02564102564102564" to Rational(1, 39)
        if (d < 1) {
            val numerator = 1L
            val f = numerator / d
            val denominator = f.roundToLong()
            if (abs(f - denominator) < PRECISION_ERROR_TOLERANCE) {
                return Rational(numerator, denominator)
            }
        }

        // e.g. "123.45" to Rational(12345, 100)
        var denominator: Long = 1
        while (d != floor(d)) {
            denominator *= 10
            d *= 10
            if (denominator > 10000000000) {
                // let's not get irrational
                return null
            }
        }
        val numerator: Long = d.roundToLong()
        return Rational(numerator, denominator)
    }

    private fun toRationalArray(s: String?): Array<Rational>? {
        s ?: return null
        val list = s.split(",").mapNotNull { toRational(it) }
        if (list.isEmpty()) return null
        return list.toTypedArray()
    }

    // extensions

    fun ExifInterface.getSafeInt(tag: String, acceptZero: Boolean = true, save: (value: Int) -> Unit) {
        if (this.hasAttribute(tag)) {
            val value = this.getAttributeInt(tag, 0)
            if (acceptZero || value != 0) {
                save(value)
            }
        }
    }

    fun ExifInterface.getSafeDouble(tag: String, save: (value: Double) -> Unit) {
        if (this.hasAttribute(tag)) {
            val value = this.getAttributeDouble(tag, Double.NaN)
            if (!value.isNaN()) {
                save(value)
            }
        }
    }

    fun ExifInterface.getSafeRational(tag: String, save: (value: Rational) -> Unit) {
        if (this.hasAttribute(tag)) {
            val value = toRational(this.getAttribute(tag))
            if (value != null) {
                save(value)
            }
        }
    }

    fun ExifInterface.getSafeDateMillis(tag: String, subSecTag: String?, save: (value: Long) -> Unit) {
        if (this.hasAttribute(tag)) {
            val dateString = this.getAttribute(tag)
            if (dateString != null) {
                try {
                    DATETIME_FORMAT.parse(dateString)?.let { date ->
                        var dateMillis = date.time
                        if (subSecTag != null && this.hasAttribute(subSecTag)) {
                            dateMillis += Metadata.parseSubSecond(this.getAttribute(subSecTag))
                        }
                        save(dateMillis)
                    }
                } catch (e: ParseException) {
                    Log.w(LOG_TAG, "failed to parse date=$dateString", e)
                }
            }
        }
    }
}

enum class DirType {
    EXIF_IFD0 {
        override fun createDirectory() = ExifIFD0Directory()
    },
    EXIF_THUMBNAIL {
        override fun createDirectory() = ExifThumbnailDirectory(0)
    },
    GPS {
        override fun createDirectory() = GpsDirectory()
    },
    OIPM {
        override fun createDirectory() = OlympusImageProcessingMakernoteDirectory()
    },
    OCSM {
        override fun createDirectory() = OlympusCameraSettingsMakernoteDirectory()
    },
    OM {
        override fun createDirectory() = OlympusMakernoteDirectory()
    },
    PRIFD0 {
        override fun createDirectory() = PanasonicRawIFD0Directory()
    };

    abstract fun createDirectory(): Directory
}

enum class TagFormat {
    ASCII, COMMENT, BYTE, SHORT, LONG, RATIONAL, RATIONAL_ARRAY, UNDEFINED
}

data class TagMapper(val type: Int, val dirType: DirType, val format: TagFormat?)
