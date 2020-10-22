package deckers.thibault.aves.metadata

import android.content.Context
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.os.Build
import android.text.format.Formatter
import java.text.SimpleDateFormat
import java.util.*

object MediaMetadataRetrieverHelper {
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
            putAll(
                hashMapOf(
                    MediaMetadataRetriever.METADATA_KEY_HAS_IMAGE to "Has Image",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_COUNT to "Image Count",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT to "Image Height",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_PRIMARY to "Image Primary",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION to "Image Rotation",
                    MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH to "Image Width",
                    MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT to "Video Frame Count",
                )
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            putAll(
                hashMapOf(
                    MediaMetadataRetriever.METADATA_KEY_EXIF_LENGTH to "Exif Length",
                    MediaMetadataRetriever.METADATA_KEY_EXIF_OFFSET to "Exif Offset",
                )
            )
        }
    }

    private val durationFormat = SimpleDateFormat("HH:mm:ss.SSS", Locale.ROOT).apply { timeZone = TimeZone.getTimeZone("UTC") }

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

    fun MediaMetadataRetriever.getSafeDescription(tag: Int, context: Context, save: (value: String) -> Unit) {
        val value = this.extractMetadata(tag)
        if (value != null) {
            when (tag) {
                // format
                MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION,
                MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION -> "$value°"
                MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT, MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH,
                MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT, MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH -> "$value pixels"
                MediaMetadataRetriever.METADATA_KEY_BITRATE -> {
                    val bitrate = value.toLongOrNull() ?: 0
                    if (bitrate > 0) "${Formatter.formatFileSize(context, bitrate)}/sec" else null
                }
                MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE -> {
                    val framerate = value.toDoubleOrNull() ?: 0.0
                    if (framerate > 0.0) "$framerate" else null
                }
                MediaMetadataRetriever.METADATA_KEY_DURATION -> {
                    val dateMillis = value.toLongOrNull() ?: 0
                    if (dateMillis > 0) durationFormat.format(Date(dateMillis)) else null
                }
                MediaMetadataRetriever.METADATA_KEY_COLOR_RANGE -> {
                    when (value.toIntOrNull()) {
                        MediaFormat.COLOR_RANGE_FULL -> "Full"
                        MediaFormat.COLOR_RANGE_LIMITED -> "Limited"
                        else -> value
                    }
                }
                MediaMetadataRetriever.METADATA_KEY_COLOR_STANDARD -> {
                    when (value.toIntOrNull()) {
                        MediaFormat.COLOR_STANDARD_BT709 -> "BT.709"
                        MediaFormat.COLOR_STANDARD_BT601_PAL -> "BT.601 625 (PAL)"
                        MediaFormat.COLOR_STANDARD_BT601_NTSC -> "BT.601 525 (NTSC)"
                        MediaFormat.COLOR_STANDARD_BT2020 -> "BT.2020"
                        else -> value
                    }
                }
                MediaMetadataRetriever.METADATA_KEY_COLOR_TRANSFER -> {
                    when (value.toIntOrNull()) {
                        MediaFormat.COLOR_TRANSFER_LINEAR -> "Linear"
                        MediaFormat.COLOR_TRANSFER_SDR_VIDEO -> "SMPTE 170M"
                        MediaFormat.COLOR_TRANSFER_ST2084 -> "SMPTE ST 2084"
                        MediaFormat.COLOR_TRANSFER_HLG -> "ARIB STD-B67 (HLG)"
                        else -> value
                    }
                }
                // hide `0` values
                MediaMetadataRetriever.METADATA_KEY_COMPILATION,
                MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER,
                MediaMetadataRetriever.METADATA_KEY_YEAR -> if (value != "0") value else null
                MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER -> if (value != "0/0") value else null
                // hide
                MediaMetadataRetriever.METADATA_KEY_LOCATION,
                MediaMetadataRetriever.METADATA_KEY_MIMETYPE -> null
                // as is
                else -> value
            }?.let { save(it) }
        }
    }
}