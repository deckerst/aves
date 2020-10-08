package deckers.thibault.aves.utils

import android.media.MediaMetadataRetriever
import android.os.Build

object MediaMetadataRetrieverHelper {
    @JvmField
    val allKeys = hashMapOf(
            MediaMetadataRetriever.METADATA_KEY_ALBUM to "Album",
            MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST to "Album Artist",
            MediaMetadataRetriever.METADATA_KEY_ARTIST to "Artist",
            MediaMetadataRetriever.METADATA_KEY_AUTHOR to "Author",
            MediaMetadataRetriever.METADATA_KEY_BITRATE to "Bitrate",
            MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE to "Capture Framerate",
            MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER to "CD Track Number",
            MediaMetadataRetriever.METADATA_KEY_COLOR_RANGE to "Color Range",
            MediaMetadataRetriever.METADATA_KEY_COLOR_STANDARD to "Color Standard",
            MediaMetadataRetriever.METADATA_KEY_COLOR_TRANSFER to "Color Transfer",
            MediaMetadataRetriever.METADATA_KEY_COMPILATION to "Compilation",
            MediaMetadataRetriever.METADATA_KEY_COMPOSER to "Composer",
            MediaMetadataRetriever.METADATA_KEY_DATE to "Date",
            MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER to "Disc Number",
            MediaMetadataRetriever.METADATA_KEY_DURATION to "Duration",
            MediaMetadataRetriever.METADATA_KEY_EXIF_LENGTH to "EXIF Length",
            MediaMetadataRetriever.METADATA_KEY_EXIF_OFFSET to "EXIF Offset",
            MediaMetadataRetriever.METADATA_KEY_GENRE to "Genre",
            MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO to "Has Audio",
            MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO to "Has Video",
            MediaMetadataRetriever.METADATA_KEY_LOCATION to "Location",
            MediaMetadataRetriever.METADATA_KEY_MIMETYPE to "MIME Type",
            MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS to "Number of Tracks",
            MediaMetadataRetriever.METADATA_KEY_TITLE to "Title",
            MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT to "Video Height",
            MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION to "Video Rotation",
            MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH to "Video Width",
            MediaMetadataRetriever.METADATA_KEY_WRITER to "Writer",
            MediaMetadataRetriever.METADATA_KEY_YEAR to "Year",
    ).apply {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            putAll(hashMapOf(
                    MediaMetadataRetriever.METADATA_KEY_HAS_IMAGE to "Has Image",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_COUNT to "Image Count",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT to "Image Height",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_PRIMARY to "Image Primary",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION to "Image Rotation",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH to "Image Width",
                    MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT to "Video Frame Count",
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
        val dateMillis = Metadata.parseVideoMetadataDate(dateString)
        // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
        if (dateMillis > 0) save(dateMillis)
    }
}