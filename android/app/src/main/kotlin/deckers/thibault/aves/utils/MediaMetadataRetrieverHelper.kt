package deckers.thibault.aves.utils

import android.media.MediaMetadataRetriever
import android.os.Build

object MediaMetadataRetrieverHelper {
    @JvmField
    val allKeys: Map<String, Int> = hashMapOf(
            "METADATA_KEY_ALBUM" to MediaMetadataRetriever.METADATA_KEY_ALBUM,
            "METADATA_KEY_ALBUMARTIST" to MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST,
            "METADATA_KEY_ARTIST" to MediaMetadataRetriever.METADATA_KEY_ARTIST,
            "METADATA_KEY_AUTHOR" to MediaMetadataRetriever.METADATA_KEY_AUTHOR,
            "METADATA_KEY_BITRATE" to MediaMetadataRetriever.METADATA_KEY_BITRATE,
            "METADATA_KEY_CAPTURE_FRAMERATE" to MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE,
            "METADATA_KEY_CD_TRACK_NUMBER" to MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER,
            "METADATA_KEY_COLOR_RANGE" to MediaMetadataRetriever.METADATA_KEY_COLOR_RANGE,
            "METADATA_KEY_COLOR_STANDARD" to MediaMetadataRetriever.METADATA_KEY_COLOR_STANDARD,
            "METADATA_KEY_COLOR_TRANSFER" to MediaMetadataRetriever.METADATA_KEY_COLOR_TRANSFER,
            "METADATA_KEY_COMPILATION" to MediaMetadataRetriever.METADATA_KEY_COMPILATION,
            "METADATA_KEY_COMPOSER" to MediaMetadataRetriever.METADATA_KEY_COMPOSER,
            "METADATA_KEY_DATE" to MediaMetadataRetriever.METADATA_KEY_DATE,
            "METADATA_KEY_DISC_NUMBER" to MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER,
            "METADATA_KEY_DURATION" to MediaMetadataRetriever.METADATA_KEY_DURATION,
            "METADATA_KEY_EXIF_LENGTH" to MediaMetadataRetriever.METADATA_KEY_EXIF_LENGTH,
            "METADATA_KEY_EXIF_OFFSET" to MediaMetadataRetriever.METADATA_KEY_EXIF_OFFSET,
            "METADATA_KEY_GENRE" to MediaMetadataRetriever.METADATA_KEY_GENRE,
            "METADATA_KEY_HAS_AUDIO" to MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO,
            "METADATA_KEY_HAS_VIDEO" to MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO,
            "METADATA_KEY_LOCATION" to MediaMetadataRetriever.METADATA_KEY_LOCATION,
            "METADATA_KEY_MIMETYPE" to MediaMetadataRetriever.METADATA_KEY_MIMETYPE,
            "METADATA_KEY_NUM_TRACKS" to MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS,
            "METADATA_KEY_TITLE" to MediaMetadataRetriever.METADATA_KEY_TITLE,
            "METADATA_KEY_VIDEO_HEIGHT" to MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT,
            "METADATA_KEY_VIDEO_ROTATION" to MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION,
            "METADATA_KEY_VIDEO_WIDTH" to MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH,
            "METADATA_KEY_WRITER" to MediaMetadataRetriever.METADATA_KEY_WRITER,
            "METADATA_KEY_YEAR" to MediaMetadataRetriever.METADATA_KEY_YEAR,
    ).apply {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            putAll(hashMapOf(
                    "METADATA_KEY_HAS_IMAGE" to MediaMetadataRetriever.METADATA_KEY_HAS_IMAGE,
                    "METADATA_KEY_IMAGE_COUNT" to MediaMetadataRetriever.METADATA_KEY_IMAGE_COUNT,
                    "METADATA_KEY_IMAGE_HEIGHT" to MediaMetadataRetriever.METADATA_KEY_IMAGE_HEIGHT,
                    "METADATA_KEY_IMAGE_PRIMARY" to MediaMetadataRetriever.METADATA_KEY_IMAGE_PRIMARY,
                    "METADATA_KEY_IMAGE_ROTATION" to MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION,
                    "METADATA_KEY_IMAGE_WIDTH" to MediaMetadataRetriever.METADATA_KEY_IMAGE_WIDTH,
                    "METADATA_KEY_VIDEO_FRAME_COUNT" to MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT,
            ))
        }
    }
}