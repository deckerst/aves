package deckers.thibault.aves.utils

import android.media.MediaMetadataRetriever
import android.os.Build

object MediaMetadataRetrieverHelper {
    @JvmField
    val allKeys = hashMapOf(
            MediaMetadataRetriever.METADATA_KEY_ALBUM to "ALBUM",
            MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST to "ALBUMARTIST",
            MediaMetadataRetriever.METADATA_KEY_ARTIST to "ARTIST",
            MediaMetadataRetriever.METADATA_KEY_AUTHOR to "AUTHOR",
            MediaMetadataRetriever.METADATA_KEY_BITRATE to "BITRATE",
            MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE to "CAPTURE_FRAMERATE",
            MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER to "CD_TRACK_NUMBER",
            MediaMetadataRetriever.METADATA_KEY_COLOR_RANGE to "COLOR_RANGE",
            MediaMetadataRetriever.METADATA_KEY_COLOR_STANDARD to "COLOR_STANDARD",
            MediaMetadataRetriever.METADATA_KEY_COLOR_TRANSFER to "COLOR_TRANSFER",
            MediaMetadataRetriever.METADATA_KEY_COMPILATION to "COMPILATION",
            MediaMetadataRetriever.METADATA_KEY_COMPOSER to "COMPOSER",
            MediaMetadataRetriever.METADATA_KEY_DATE to "DATE",
            MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER to "DISC_NUMBER",
            MediaMetadataRetriever.METADATA_KEY_DURATION to "DURATION",
            MediaMetadataRetriever.METADATA_KEY_EXIF_LENGTH to "EXIF_LENGTH",
            MediaMetadataRetriever.METADATA_KEY_EXIF_OFFSET to "EXIF_OFFSET",
            MediaMetadataRetriever.METADATA_KEY_GENRE to "GENRE",
            MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO to "HAS_AUDIO",
            MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO to "HAS_VIDEO",
            MediaMetadataRetriever.METADATA_KEY_LOCATION to "LOCATION",
            MediaMetadataRetriever.METADATA_KEY_MIMETYPE to "MIMETYPE",
            MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS to "NUM_TRACKS",
            MediaMetadataRetriever.METADATA_KEY_TITLE to "TITLE",
            MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT to "VIDEO_HEIGHT",
            MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION to "VIDEO_ROTATION",
            MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH to "VIDEO_WIDTH",
            MediaMetadataRetriever.METADATA_KEY_WRITER to "WRITER",
            MediaMetadataRetriever.METADATA_KEY_YEAR to "YEAR",
    ).apply {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            putAll(hashMapOf(
                    MediaMetadataRetriever.METADATA_KEY_HAS_IMAGE to "HAS_IMAGE",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_COUNT to "IMAGE_COUNT",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT to "IMAGE_HEIGHT",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_PRIMARY to "IMAGE_PRIMARY",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION to "IMAGE_ROTATION",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH to "IMAGE_WIDTH",
                    MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT to "VIDEO_FRAME_COUNT",
            ))
        }
    }

    // extensions

    fun MediaMetadataRetriever.getSafeString(tag: Int, save: (value: String) -> Unit) {
        val value = this.extractMetadata(tag)
        if (value != null) save(value)
    }

    fun MediaMetadataRetriever.getSafeInt(tag: Int, save: (value: Int) -> Unit) {
        val value = this.extractMetadata(tag)?.toIntOrNull()
        if (value != null) save(value)
    }

    fun MediaMetadataRetriever.getSafeLong(tag: Int, save: (value: Long) -> Unit) {
        val value = this.extractMetadata(tag)?.toLongOrNull()
        if (value != null) save(value)
    }

    fun MediaMetadataRetriever.getSafeDateMillis(tag: Int, save: (value: Long) -> Unit) {
        val dateString = this.extractMetadata(tag)
        val dateMillis = MetadataHelper.parseVideoMetadataDate(dateString)
        // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
        if (dateMillis > 0) save(dateMillis)
    }
}