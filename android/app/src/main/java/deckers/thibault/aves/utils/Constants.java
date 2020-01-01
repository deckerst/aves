package deckers.thibault.aves.utils;

import android.media.MediaMetadataRetriever;

import java.util.HashMap;
import java.util.Map;

public class Constants {
    public static final int SD_CARD_PERMISSION_REQUEST_CODE = 1;

    // mime types

    public static final String MIME_GIF = "image/gif";
    public static final String MIME_JPEG = "image/jpeg";
    public static final String MIME_PNG = "image/png";
    public static final String MIME_MP2T = "video/mp2t"; // .m2ts
    public static final String MIME_VIDEO = "video";

    // video metadata keys, from android.media.MediaMetadataRetriever

    public static final Map<Integer, String> MEDIA_METADATA_KEYS = new HashMap<Integer, String>() {
        {
            put(MediaMetadataRetriever.METADATA_KEY_MIMETYPE, "MIME Type");
            put(MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS, "Number of Tracks");
            put(MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO, "Has Audio");
            put(MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO, "Has Video");
            put(MediaMetadataRetriever.METADATA_KEY_BITRATE, "Bitrate");
            put(MediaMetadataRetriever.METADATA_KEY_DATE, "Date");
            put(MediaMetadataRetriever.METADATA_KEY_LOCATION, "Location");
            put(MediaMetadataRetriever.METADATA_KEY_YEAR, "Year");
            put(MediaMetadataRetriever.METADATA_KEY_ARTIST, "Artist");
            put(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST, "Album Artist");
            put(MediaMetadataRetriever.METADATA_KEY_ALBUM, "Album");
            put(MediaMetadataRetriever.METADATA_KEY_TITLE, "Title");
            put(MediaMetadataRetriever.METADATA_KEY_AUTHOR, "Author");
            put(MediaMetadataRetriever.METADATA_KEY_COMPOSER, "Composer");
            put(MediaMetadataRetriever.METADATA_KEY_WRITER, "Writer");
            put(MediaMetadataRetriever.METADATA_KEY_GENRE, "Genre");
        }
    };
}
