package deckers.thibault.aves.utils

import androidx.exifinterface.media.ExifInterface
import com.drew.metadata.Directory
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifThumbnailDirectory
import com.drew.metadata.exif.GpsDirectory
import com.drew.metadata.exif.PanasonicRawIFD0Directory
import com.drew.metadata.exif.makernotes.OlympusCameraSettingsMakernoteDirectory
import com.drew.metadata.exif.makernotes.OlympusImageProcessingMakernoteDirectory
import com.drew.metadata.exif.makernotes.OlympusMakernoteDirectory
import java.util.*

object ExifInterfaceHelper {
    private val exifThumbnailDirectory = ExifThumbnailDirectory()
    private val gpsDir = GpsDirectory()
    private val olympusImageProcessingMakernoteDirectory = OlympusImageProcessingMakernoteDirectory()
    private val olympusCameraSettingsMakernoteDirectory = OlympusCameraSettingsMakernoteDirectory()
    private val olympusMakernoteDirectory = OlympusMakernoteDirectory()
    private val panasonicRawIFD0Directory = PanasonicRawIFD0Directory()

    private val baseTags: Map<String, Pair<Int, Directory>?> = hashMapOf(
            ExifInterface.TAG_APERTURE_VALUE to Pair(ExifDirectoryBase.TAG_APERTURE, gpsDir),
            ExifInterface.TAG_ARTIST to Pair(ExifDirectoryBase.TAG_ARTIST, gpsDir),
            ExifInterface.TAG_BITS_PER_SAMPLE to Pair(ExifDirectoryBase.TAG_BITS_PER_SAMPLE, gpsDir),
            ExifInterface.TAG_BODY_SERIAL_NUMBER to Pair(ExifDirectoryBase.TAG_BODY_SERIAL_NUMBER, gpsDir),
            ExifInterface.TAG_BRIGHTNESS_VALUE to Pair(ExifDirectoryBase.TAG_BRIGHTNESS_VALUE, gpsDir),
            ExifInterface.TAG_CAMERA_OWNER_NAME to Pair(ExifDirectoryBase.TAG_CAMERA_OWNER_NAME, gpsDir),
            ExifInterface.TAG_CFA_PATTERN to Pair(ExifDirectoryBase.TAG_CFA_PATTERN, gpsDir),
            ExifInterface.TAG_COLOR_SPACE to Pair(ExifDirectoryBase.TAG_COLOR_SPACE, gpsDir),
            ExifInterface.TAG_COMPONENTS_CONFIGURATION to Pair(ExifDirectoryBase.TAG_COMPONENTS_CONFIGURATION, gpsDir),
            ExifInterface.TAG_COMPRESSED_BITS_PER_PIXEL to Pair(ExifDirectoryBase.TAG_COMPRESSED_AVERAGE_BITS_PER_PIXEL, gpsDir),
            ExifInterface.TAG_COMPRESSION to Pair(ExifDirectoryBase.TAG_COMPRESSION, gpsDir),
            ExifInterface.TAG_CONTRAST to Pair(ExifDirectoryBase.TAG_CONTRAST, gpsDir),
            ExifInterface.TAG_COPYRIGHT to Pair(ExifDirectoryBase.TAG_COPYRIGHT, gpsDir),
            ExifInterface.TAG_CUSTOM_RENDERED to Pair(ExifDirectoryBase.TAG_CUSTOM_RENDERED, gpsDir),
            ExifInterface.TAG_DATETIME to Pair(ExifDirectoryBase.TAG_DATETIME, gpsDir),
            ExifInterface.TAG_DATETIME_DIGITIZED to Pair(ExifDirectoryBase.TAG_DATETIME_DIGITIZED, gpsDir),
            ExifInterface.TAG_DATETIME_ORIGINAL to Pair(ExifDirectoryBase.TAG_DATETIME_ORIGINAL, gpsDir),
            ExifInterface.TAG_DEVICE_SETTING_DESCRIPTION to Pair(ExifDirectoryBase.TAG_DEVICE_SETTING_DESCRIPTION, gpsDir),
            ExifInterface.TAG_DIGITAL_ZOOM_RATIO to Pair(ExifDirectoryBase.TAG_DIGITAL_ZOOM_RATIO, gpsDir),
            ExifInterface.TAG_EXIF_VERSION to Pair(ExifDirectoryBase.TAG_EXIF_VERSION, gpsDir),
            ExifInterface.TAG_EXPOSURE_BIAS_VALUE to Pair(ExifDirectoryBase.TAG_EXPOSURE_BIAS, gpsDir),
            ExifInterface.TAG_EXPOSURE_INDEX to Pair(ExifDirectoryBase.TAG_EXPOSURE_INDEX, gpsDir),
            ExifInterface.TAG_EXPOSURE_MODE to Pair(ExifDirectoryBase.TAG_EXPOSURE_MODE, gpsDir),
            ExifInterface.TAG_EXPOSURE_PROGRAM to Pair(ExifDirectoryBase.TAG_EXPOSURE_PROGRAM, gpsDir),
            ExifInterface.TAG_EXPOSURE_TIME to Pair(ExifDirectoryBase.TAG_EXPOSURE_TIME, gpsDir),
            ExifInterface.TAG_FILE_SOURCE to Pair(ExifDirectoryBase.TAG_FILE_SOURCE, gpsDir),
            ExifInterface.TAG_FLASH to Pair(ExifDirectoryBase.TAG_FLASH, gpsDir),
            ExifInterface.TAG_FLASHPIX_VERSION to Pair(ExifDirectoryBase.TAG_FLASHPIX_VERSION, gpsDir),
            ExifInterface.TAG_FLASH_ENERGY to Pair(ExifDirectoryBase.TAG_FLASH_ENERGY, gpsDir),
            ExifInterface.TAG_FOCAL_LENGTH to Pair(ExifDirectoryBase.TAG_FOCAL_LENGTH, gpsDir),
            ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM to Pair(ExifDirectoryBase.TAG_35MM_FILM_EQUIV_FOCAL_LENGTH, gpsDir),
            ExifInterface.TAG_FOCAL_PLANE_RESOLUTION_UNIT to Pair(ExifDirectoryBase.TAG_FOCAL_PLANE_RESOLUTION_UNIT, gpsDir),
            ExifInterface.TAG_FOCAL_PLANE_X_RESOLUTION to Pair(ExifDirectoryBase.TAG_FOCAL_PLANE_X_RESOLUTION, gpsDir),
            ExifInterface.TAG_FOCAL_PLANE_Y_RESOLUTION to Pair(ExifDirectoryBase.TAG_FOCAL_PLANE_Y_RESOLUTION, gpsDir),
            ExifInterface.TAG_F_NUMBER to Pair(ExifDirectoryBase.TAG_FNUMBER, gpsDir),
            ExifInterface.TAG_GAIN_CONTROL to Pair(ExifDirectoryBase.TAG_GAIN_CONTROL, gpsDir),
            ExifInterface.TAG_GAMMA to Pair(ExifDirectoryBase.TAG_GAMMA, gpsDir),
            ExifInterface.TAG_IMAGE_DESCRIPTION to Pair(ExifDirectoryBase.TAG_IMAGE_DESCRIPTION, gpsDir),
            ExifInterface.TAG_IMAGE_LENGTH to Pair(ExifDirectoryBase.TAG_IMAGE_HEIGHT, gpsDir),
            ExifInterface.TAG_IMAGE_UNIQUE_ID to Pair(ExifDirectoryBase.TAG_IMAGE_UNIQUE_ID, gpsDir),
            ExifInterface.TAG_IMAGE_WIDTH to Pair(ExifDirectoryBase.TAG_IMAGE_WIDTH, gpsDir),
            ExifInterface.TAG_INTEROPERABILITY_INDEX to Pair(ExifDirectoryBase.TAG_INTEROP_INDEX, gpsDir),
            ExifInterface.TAG_ISO_SPEED to Pair(ExifDirectoryBase.TAG_ISO_SPEED, gpsDir),
            ExifInterface.TAG_ISO_SPEED_LATITUDE_YYY to Pair(ExifDirectoryBase.TAG_ISO_SPEED_LATITUDE_YYY, gpsDir),
            ExifInterface.TAG_ISO_SPEED_LATITUDE_ZZZ to Pair(ExifDirectoryBase.TAG_ISO_SPEED_LATITUDE_ZZZ, gpsDir),
            ExifInterface.TAG_LENS_MAKE to Pair(ExifDirectoryBase.TAG_LENS_MAKE, gpsDir),
            ExifInterface.TAG_LENS_MODEL to Pair(ExifDirectoryBase.TAG_LENS_MODEL, gpsDir),
            ExifInterface.TAG_LENS_SERIAL_NUMBER to Pair(ExifDirectoryBase.TAG_LENS_SERIAL_NUMBER, gpsDir),
            ExifInterface.TAG_LENS_SPECIFICATION to Pair(ExifDirectoryBase.TAG_LENS_SPECIFICATION, gpsDir),
            ExifInterface.TAG_LIGHT_SOURCE to Pair(ExifDirectoryBase.TAG_WHITE_BALANCE, gpsDir),
            ExifInterface.TAG_MAKE to Pair(ExifDirectoryBase.TAG_MAKE, gpsDir),
            ExifInterface.TAG_MAKER_NOTE to Pair(ExifDirectoryBase.TAG_MAKERNOTE, gpsDir),
            ExifInterface.TAG_MAX_APERTURE_VALUE to Pair(ExifDirectoryBase.TAG_MAX_APERTURE, gpsDir),
            ExifInterface.TAG_METERING_MODE to Pair(ExifDirectoryBase.TAG_METERING_MODE, gpsDir),
            ExifInterface.TAG_MODEL to Pair(ExifDirectoryBase.TAG_MODEL, gpsDir),
            ExifInterface.TAG_NEW_SUBFILE_TYPE to Pair(ExifDirectoryBase.TAG_NEW_SUBFILE_TYPE, gpsDir),
            ExifInterface.TAG_OECF to Pair(ExifDirectoryBase.TAG_OPTO_ELECTRIC_CONVERSION_FUNCTION, gpsDir),
            ExifInterface.TAG_OFFSET_TIME to Pair(ExifDirectoryBase.TAG_TIME_ZONE, gpsDir),
            ExifInterface.TAG_OFFSET_TIME_DIGITIZED to Pair(ExifDirectoryBase.TAG_TIME_ZONE_DIGITIZED, gpsDir),
            ExifInterface.TAG_OFFSET_TIME_ORIGINAL to Pair(ExifDirectoryBase.TAG_TIME_ZONE_ORIGINAL, gpsDir),
            ExifInterface.TAG_ORIENTATION to Pair(ExifDirectoryBase.TAG_ORIENTATION, gpsDir),
            ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY to Pair(ExifDirectoryBase.TAG_ISO_EQUIVALENT, gpsDir),
            ExifInterface.TAG_PHOTOMETRIC_INTERPRETATION to Pair(ExifDirectoryBase.TAG_PHOTOMETRIC_INTERPRETATION, gpsDir),
            ExifInterface.TAG_PIXEL_X_DIMENSION to Pair(ExifDirectoryBase.TAG_EXIF_IMAGE_WIDTH, gpsDir),
            ExifInterface.TAG_PIXEL_Y_DIMENSION to Pair(ExifDirectoryBase.TAG_EXIF_IMAGE_HEIGHT, gpsDir),
            ExifInterface.TAG_PLANAR_CONFIGURATION to Pair(ExifDirectoryBase.TAG_PLANAR_CONFIGURATION, gpsDir),
            ExifInterface.TAG_PRIMARY_CHROMATICITIES to Pair(ExifDirectoryBase.TAG_PRIMARY_CHROMATICITIES, gpsDir),
            ExifInterface.TAG_RECOMMENDED_EXPOSURE_INDEX to Pair(ExifDirectoryBase.TAG_RECOMMENDED_EXPOSURE_INDEX, gpsDir),
            ExifInterface.TAG_REFERENCE_BLACK_WHITE to Pair(ExifDirectoryBase.TAG_REFERENCE_BLACK_WHITE, gpsDir),
            ExifInterface.TAG_RELATED_SOUND_FILE to Pair(ExifDirectoryBase.TAG_RELATED_SOUND_FILE, gpsDir),
            ExifInterface.TAG_RESOLUTION_UNIT to Pair(ExifDirectoryBase.TAG_RESOLUTION_UNIT, gpsDir),
            ExifInterface.TAG_ROWS_PER_STRIP to Pair(ExifDirectoryBase.TAG_ROWS_PER_STRIP, gpsDir),
            ExifInterface.TAG_SAMPLES_PER_PIXEL to Pair(ExifDirectoryBase.TAG_SAMPLES_PER_PIXEL, gpsDir),
            ExifInterface.TAG_SATURATION to Pair(ExifDirectoryBase.TAG_SATURATION, gpsDir),
            ExifInterface.TAG_SCENE_CAPTURE_TYPE to Pair(ExifDirectoryBase.TAG_SCENE_CAPTURE_TYPE, gpsDir),
            ExifInterface.TAG_SCENE_TYPE to Pair(ExifDirectoryBase.TAG_SCENE_TYPE, gpsDir),
            ExifInterface.TAG_SENSING_METHOD to Pair(ExifDirectoryBase.TAG_SENSING_METHOD, gpsDir),
            ExifInterface.TAG_SENSITIVITY_TYPE to Pair(ExifDirectoryBase.TAG_SENSITIVITY_TYPE, gpsDir),
            ExifInterface.TAG_SHARPNESS to Pair(ExifDirectoryBase.TAG_SHARPNESS, gpsDir),
            ExifInterface.TAG_SHUTTER_SPEED_VALUE to Pair(ExifDirectoryBase.TAG_SHUTTER_SPEED, gpsDir),
            ExifInterface.TAG_SOFTWARE to Pair(ExifDirectoryBase.TAG_SOFTWARE, gpsDir),
            ExifInterface.TAG_SPATIAL_FREQUENCY_RESPONSE to Pair(ExifDirectoryBase.TAG_SPATIAL_FREQ_RESPONSE, gpsDir),
            ExifInterface.TAG_SPECTRAL_SENSITIVITY to Pair(ExifDirectoryBase.TAG_SPECTRAL_SENSITIVITY, gpsDir),
            ExifInterface.TAG_STANDARD_OUTPUT_SENSITIVITY to Pair(ExifDirectoryBase.TAG_STANDARD_OUTPUT_SENSITIVITY, gpsDir),
            ExifInterface.TAG_STRIP_BYTE_COUNTS to Pair(ExifDirectoryBase.TAG_STRIP_BYTE_COUNTS, gpsDir),
            ExifInterface.TAG_STRIP_OFFSETS to Pair(ExifDirectoryBase.TAG_STRIP_OFFSETS, gpsDir),
            ExifInterface.TAG_SUBFILE_TYPE to Pair(ExifDirectoryBase.TAG_SUBFILE_TYPE, gpsDir),
            ExifInterface.TAG_SUBJECT_AREA to Pair(ExifDirectoryBase.TAG_SUBJECT_LOCATION_TIFF_EP, gpsDir),
            ExifInterface.TAG_SUBJECT_DISTANCE to Pair(ExifDirectoryBase.TAG_SUBJECT_DISTANCE, gpsDir),
            ExifInterface.TAG_SUBJECT_DISTANCE_RANGE to Pair(ExifDirectoryBase.TAG_SUBJECT_DISTANCE_RANGE, gpsDir),
            ExifInterface.TAG_SUBJECT_LOCATION to Pair(ExifDirectoryBase.TAG_SUBJECT_LOCATION, gpsDir),
            ExifInterface.TAG_SUBSEC_TIME to Pair(ExifDirectoryBase.TAG_SUBSECOND_TIME, gpsDir),
            ExifInterface.TAG_SUBSEC_TIME_DIGITIZED to Pair(ExifDirectoryBase.TAG_SUBSECOND_TIME_DIGITIZED, gpsDir),
            ExifInterface.TAG_SUBSEC_TIME_ORIGINAL to Pair(ExifDirectoryBase.TAG_SUBSECOND_TIME_ORIGINAL, gpsDir),
            ExifInterface.TAG_THUMBNAIL_IMAGE_LENGTH to Pair(ExifDirectoryBase.TAG_IMAGE_HEIGHT, gpsDir), // IFD_THUMBNAIL_TAGS 0x0101
            ExifInterface.TAG_THUMBNAIL_IMAGE_WIDTH to Pair(ExifDirectoryBase.TAG_IMAGE_WIDTH, gpsDir), // IFD_THUMBNAIL_TAGS 0x0100
            ExifInterface.TAG_TRANSFER_FUNCTION to Pair(ExifDirectoryBase.TAG_TRANSFER_FUNCTION, gpsDir),
            ExifInterface.TAG_USER_COMMENT to Pair(ExifDirectoryBase.TAG_USER_COMMENT, gpsDir),
            ExifInterface.TAG_WHITE_BALANCE to Pair(ExifDirectoryBase.TAG_WHITE_BALANCE, gpsDir),
            ExifInterface.TAG_WHITE_POINT to Pair(ExifDirectoryBase.TAG_WHITE_POINT, gpsDir),
            ExifInterface.TAG_X_RESOLUTION to Pair(ExifDirectoryBase.TAG_X_RESOLUTION, gpsDir),
            ExifInterface.TAG_Y_CB_CR_COEFFICIENTS to Pair(ExifDirectoryBase.TAG_YCBCR_COEFFICIENTS, gpsDir),
            ExifInterface.TAG_Y_CB_CR_POSITIONING to Pair(ExifDirectoryBase.TAG_YCBCR_POSITIONING, gpsDir),
            ExifInterface.TAG_Y_CB_CR_SUB_SAMPLING to Pair(ExifDirectoryBase.TAG_YCBCR_SUBSAMPLING, gpsDir),
            ExifInterface.TAG_Y_RESOLUTION to Pair(ExifDirectoryBase.TAG_Y_RESOLUTION, gpsDir),
    )

    private val thumbnailTags: Map<String, Pair<Int, Directory>?> = hashMapOf(
            ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT to Pair(ExifThumbnailDirectory.TAG_THUMBNAIL_OFFSET, exifThumbnailDirectory), // IFD_TIFF_TAGS or IFD_THUMBNAIL_TAGS 0x0201
            ExifInterface.TAG_JPEG_INTERCHANGE_FORMAT_LENGTH to Pair(ExifThumbnailDirectory.TAG_THUMBNAIL_LENGTH, exifThumbnailDirectory), // IFD_TIFF_TAGS or IFD_THUMBNAIL_TAGS 0x0202
    )

    private val gpsTags: Map<String, Pair<Int, Directory>?> = hashMapOf(
            // GPS
            ExifInterface.TAG_GPS_ALTITUDE to Pair(GpsDirectory.TAG_ALTITUDE, gpsDir),
            ExifInterface.TAG_GPS_ALTITUDE_REF to Pair(GpsDirectory.TAG_ALTITUDE_REF, gpsDir),
            ExifInterface.TAG_GPS_AREA_INFORMATION to Pair(GpsDirectory.TAG_AREA_INFORMATION, gpsDir),
            ExifInterface.TAG_GPS_DATESTAMP to Pair(GpsDirectory.TAG_DATE_STAMP, gpsDir),
            ExifInterface.TAG_GPS_DEST_BEARING to Pair(GpsDirectory.TAG_DEST_BEARING, gpsDir),
            ExifInterface.TAG_GPS_DEST_BEARING_REF to Pair(GpsDirectory.TAG_DEST_BEARING_REF, gpsDir),
            ExifInterface.TAG_GPS_DEST_DISTANCE to Pair(GpsDirectory.TAG_DEST_DISTANCE, gpsDir),
            ExifInterface.TAG_GPS_DEST_DISTANCE_REF to Pair(GpsDirectory.TAG_DEST_DISTANCE_REF, gpsDir),
            ExifInterface.TAG_GPS_DEST_LATITUDE to Pair(GpsDirectory.TAG_DEST_LATITUDE, gpsDir),
            ExifInterface.TAG_GPS_DEST_LATITUDE_REF to Pair(GpsDirectory.TAG_DEST_LATITUDE_REF, gpsDir),
            ExifInterface.TAG_GPS_DEST_LONGITUDE to Pair(GpsDirectory.TAG_DEST_LONGITUDE, gpsDir),
            ExifInterface.TAG_GPS_DEST_LONGITUDE_REF to Pair(GpsDirectory.TAG_DEST_LONGITUDE_REF, gpsDir),
            ExifInterface.TAG_GPS_DIFFERENTIAL to Pair(GpsDirectory.TAG_DIFFERENTIAL, gpsDir),
            ExifInterface.TAG_GPS_DOP to Pair(GpsDirectory.TAG_DOP, gpsDir),
            ExifInterface.TAG_GPS_H_POSITIONING_ERROR to Pair(GpsDirectory.TAG_H_POSITIONING_ERROR, gpsDir),
            ExifInterface.TAG_GPS_IMG_DIRECTION to Pair(GpsDirectory.TAG_IMG_DIRECTION, gpsDir),
            ExifInterface.TAG_GPS_IMG_DIRECTION_REF to Pair(GpsDirectory.TAG_IMG_DIRECTION_REF, gpsDir),
            ExifInterface.TAG_GPS_LATITUDE to Pair(GpsDirectory.TAG_LATITUDE, gpsDir),
            ExifInterface.TAG_GPS_LATITUDE_REF to Pair(GpsDirectory.TAG_LATITUDE_REF, gpsDir),
            ExifInterface.TAG_GPS_LONGITUDE to Pair(GpsDirectory.TAG_LONGITUDE, gpsDir),
            ExifInterface.TAG_GPS_LONGITUDE_REF to Pair(GpsDirectory.TAG_LONGITUDE_REF, gpsDir),
            ExifInterface.TAG_GPS_MAP_DATUM to Pair(GpsDirectory.TAG_MAP_DATUM, gpsDir),
            ExifInterface.TAG_GPS_MEASURE_MODE to Pair(GpsDirectory.TAG_MEASURE_MODE, gpsDir),
            ExifInterface.TAG_GPS_PROCESSING_METHOD to Pair(GpsDirectory.TAG_PROCESSING_METHOD, gpsDir),
            ExifInterface.TAG_GPS_SATELLITES to Pair(GpsDirectory.TAG_SATELLITES, gpsDir),
            ExifInterface.TAG_GPS_SPEED to Pair(GpsDirectory.TAG_SPEED, gpsDir),
            ExifInterface.TAG_GPS_SPEED_REF to Pair(GpsDirectory.TAG_SPEED_REF, gpsDir),
            ExifInterface.TAG_GPS_STATUS to Pair(GpsDirectory.TAG_STATUS, gpsDir),
            ExifInterface.TAG_GPS_TIMESTAMP to Pair(GpsDirectory.TAG_TIME_STAMP, gpsDir),
            ExifInterface.TAG_GPS_TRACK to Pair(GpsDirectory.TAG_TRACK, gpsDir),
            ExifInterface.TAG_GPS_TRACK_REF to Pair(GpsDirectory.TAG_TRACK_REF, gpsDir),
            ExifInterface.TAG_GPS_VERSION_ID to Pair(GpsDirectory.TAG_VERSION_ID, gpsDir),
    )

    private val xmpTags: Map<String, Pair<Int, Directory>?> = hashMapOf(
            ExifInterface.TAG_XMP to null, // IFD_TIFF_TAGS 0x02BC
    )

    private val rawTags: Map<String, Pair<Int, Directory>?> = hashMapOf(
            // DNG
            ExifInterface.TAG_DEFAULT_CROP_SIZE to null, // IFD_EXIF_TAGS 0xC620
            ExifInterface.TAG_DNG_VERSION to null, // IFD_EXIF_TAGS 0xC612
            // ORF
            ExifInterface.TAG_ORF_ASPECT_FRAME to Pair(OlympusImageProcessingMakernoteDirectory.TagAspectFrame, olympusImageProcessingMakernoteDirectory), // ORF_IMAGE_PROCESSING_TAGS 0x1113
            ExifInterface.TAG_ORF_PREVIEW_IMAGE_LENGTH to Pair(OlympusCameraSettingsMakernoteDirectory.TagPreviewImageLength, olympusCameraSettingsMakernoteDirectory), // ORF_CAMERA_SETTINGS_TAGS 0x0102
            ExifInterface.TAG_ORF_PREVIEW_IMAGE_START to Pair(OlympusCameraSettingsMakernoteDirectory.TagPreviewImageStart, olympusCameraSettingsMakernoteDirectory), // ORF_CAMERA_SETTINGS_TAGS 0x0101
            ExifInterface.TAG_ORF_THUMBNAIL_IMAGE to Pair(OlympusMakernoteDirectory.TAG_THUMBNAIL_IMAGE, olympusMakernoteDirectory), // ORF_MAKER_NOTE_TAGS 0x0100
            // RW2
            ExifInterface.TAG_RW2_ISO to Pair(PanasonicRawIFD0Directory.TagIso, panasonicRawIFD0Directory), // IFD_TIFF_TAGS 0x0017
            ExifInterface.TAG_RW2_JPG_FROM_RAW to Pair(PanasonicRawIFD0Directory.TagJpgFromRaw, panasonicRawIFD0Directory), // IFD_TIFF_TAGS 0x002E
            ExifInterface.TAG_RW2_SENSOR_BOTTOM_BORDER to Pair(PanasonicRawIFD0Directory.TagSensorBottomBorder, panasonicRawIFD0Directory), // IFD_TIFF_TAGS 0x0006
            ExifInterface.TAG_RW2_SENSOR_LEFT_BORDER to Pair(PanasonicRawIFD0Directory.TagSensorLeftBorder, panasonicRawIFD0Directory), // IFD_TIFF_TAGS 0x0005
            ExifInterface.TAG_RW2_SENSOR_RIGHT_BORDER to Pair(PanasonicRawIFD0Directory.TagSensorRightBorder, panasonicRawIFD0Directory), // IFD_TIFF_TAGS 0x0007
            ExifInterface.TAG_RW2_SENSOR_TOP_BORDER to Pair(PanasonicRawIFD0Directory.TagSensorTopBorder, panasonicRawIFD0Directory), // IFD_TIFF_TAGS 0x0004
    )

    // list of known ExifInterface tags (as of androidx.exifinterface:exifinterface:1.3.0)
    // mapped to metadata-extractor tags (as of v2.14.0)
    @JvmField
    val allTags: Map<String, Pair<Int, Directory>?> = hashMapOf<String, Pair<Int, Directory>?>(
    ).apply {
        putAll(baseTags)
        putAll(thumbnailTags)
        putAll(gpsTags)
        putAll(xmpTags)
        putAll(rawTags)
    }

    @JvmStatic
    fun describeAll(exif: ExifInterface): Map<String, Map<String, String>> {
        return HashMap<String, Map<String, String>>().apply {
            put("Exif", describeDir(exif, baseTags))
            put("Exif Thumbnail", describeDir(exif, thumbnailTags))
            put("GPS", describeDir(exif, gpsTags))
            put("XMP", describeDir(exif, xmpTags))
            put("Exif Raw", describeDir(exif, rawTags))
        }.filterValues { it.isNotEmpty() }
    }

    private fun describeDir(exif: ExifInterface, tags: Map<String, Pair<Int, Directory>?>): Map<String, String> {
        val dirMap = HashMap<String, String>()
        for (kv in tags) {
            val exifInterfaceTag: String = kv.key
            if (exif.hasAttribute(exifInterfaceTag)) {
                val mapper = kv.value
                val tagName = if (mapper != null) {
                    val extractorTagType = mapper.first
                    val extractorDir = mapper.second
                    extractorDir.getTagName(extractorTagType)
                } else {
                    exifInterfaceTag
                }
                val tagValue: String? = exif.getAttribute(exifInterfaceTag)
                if (tagValue != null) {
                    dirMap[tagName] = tagValue
                }
            }
        }
        return dirMap
    }
}
