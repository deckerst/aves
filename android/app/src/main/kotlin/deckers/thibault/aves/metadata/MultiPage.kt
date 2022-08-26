package deckers.thibault.aves.metadata

import android.annotation.SuppressLint
import android.content.Context
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import com.adobe.internal.xmp.XMPMeta
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.metadata.XMP.countPropArrayItems
import deckers.thibault.aves.metadata.XMP.doesPropExist
import deckers.thibault.aves.metadata.XMP.getSafeLong
import deckers.thibault.aves.metadata.XMP.getSafeStructField
import deckers.thibault.aves.metadata.metadataextractor.Helper
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.indexOfBytes
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.DataInputStream

object MultiPage {
    private val LOG_TAG = LogUtils.createTag<MultiPage>()

    private val heicMotionPhotoVideoStartIndicator = byteArrayOf(0x00, 0x00, 0x00, 0x18) + "ftypmp42".toByteArray()

    // page info
    private const val KEY_MIME_TYPE = "mimeType"
    private const val KEY_HEIGHT = "height"
    private const val KEY_WIDTH = "width"
    private const val KEY_PAGE = "page"
    private const val KEY_IS_DEFAULT = "isDefault"
    private const val KEY_DURATION = "durationMillis"
    private const val KEY_ROTATION_DEGREES = "rotationDegrees"

    fun getHeicTracks(context: Context, uri: Uri): ArrayList<FieldMap> {
        fun MediaFormat.getSafeInt(key: String, save: (value: Int) -> Unit) {
            if (this.containsKey(key)) save(this.getInteger(key))
        }

        fun MediaFormat.getSafeLong(key: String, save: (value: Long) -> Unit) {
            if (this.containsKey(key)) save(this.getLong(key))
        }

        val tracks = ArrayList<FieldMap>()
        val extractor = MediaExtractor()
        extractor.setDataSource(context, uri, null)
        for (i in 0 until extractor.trackCount) {
            try {
                val format = extractor.getTrackFormat(i)
                format.getString(MediaFormat.KEY_MIME)?.let { mime ->
                    val trackMime = if (mime == MediaFormat.MIMETYPE_IMAGE_ANDROID_HEIC) MimeTypes.HEIC else mime
                    val track: FieldMap = hashMapOf(
                        KEY_PAGE to i,
                        KEY_MIME_TYPE to trackMime,
                    )

                    // do not use `MediaFormat.KEY_TRACK_ID` as it is actually not unique between tracks
                    // e.g. there could be both a video track and an image track with KEY_TRACK_ID == 1

                    format.getSafeInt(MediaFormat.KEY_WIDTH) { track[KEY_WIDTH] = it }
                    format.getSafeInt(MediaFormat.KEY_HEIGHT) { track[KEY_HEIGHT] = it }
                    @SuppressLint("ObsoleteSdkInt")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                        format.getSafeInt(MediaFormat.KEY_IS_DEFAULT) { track[KEY_IS_DEFAULT] = it != 0 }
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        format.getSafeInt(MediaFormat.KEY_ROTATION) { track[KEY_ROTATION_DEGREES] = it }
                    }
                    if (MimeTypes.isVideo(trackMime)) {
                        format.getSafeLong(MediaFormat.KEY_DURATION) { track[KEY_DURATION] = it / 1000 }
                    }
                    tracks.add(track)
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get HEIC track information for uri=$uri, track num=$i", e)
            }
        }
        extractor.release()
        return tracks
    }

    fun getMotionPhotoPages(context: Context, uri: Uri, mimeType: String, sizeBytes: Long): ArrayList<FieldMap> {
        fun MediaFormat.getSafeInt(key: String, save: (value: Int) -> Unit) {
            if (this.containsKey(key)) save(this.getInteger(key))
        }

        fun MediaFormat.getSafeLong(key: String, save: (value: Long) -> Unit) {
            if (this.containsKey(key)) save(this.getLong(key))
        }

        val tracks = ArrayList<FieldMap>()
        val extractor = MediaExtractor()
        var pfd: ParcelFileDescriptor? = null
        try {
            getMotionPhotoOffset(context, uri, mimeType, sizeBytes)?.let { videoSizeBytes ->
                val videoStartOffset = sizeBytes - videoSizeBytes
                pfd = context.contentResolver.openFileDescriptor(uri, "r")
                pfd?.fileDescriptor?.let { fd ->
                    extractor.setDataSource(fd, videoStartOffset, videoSizeBytes)
                    // set the original image as the first and default track
                    var trackCount = 0
                    tracks.add(
                        hashMapOf(
                            KEY_PAGE to trackCount++,
                            KEY_MIME_TYPE to mimeType,
                            KEY_IS_DEFAULT to true,
                        )
                    )
                    // add video tracks from the appended video
                    if (extractor.trackCount > 0) {
                        // only consider the first track to represent the appended video
                        val trackIndex = 0
                        try {
                            val format = extractor.getTrackFormat(trackIndex)
                            format.getString(MediaFormat.KEY_MIME)?.let { mime ->
                                if (MimeTypes.isVideo(mime)) {
                                    val track: FieldMap = hashMapOf(
                                        KEY_PAGE to trackCount++,
                                        KEY_MIME_TYPE to MimeTypes.MP4,
                                        KEY_IS_DEFAULT to false,
                                    )
                                    format.getSafeInt(MediaFormat.KEY_WIDTH) { track[KEY_WIDTH] = it }
                                    format.getSafeInt(MediaFormat.KEY_HEIGHT) { track[KEY_HEIGHT] = it }
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                        format.getSafeInt(MediaFormat.KEY_ROTATION) { track[KEY_ROTATION_DEGREES] = it }
                                    }
                                    format.getSafeLong(MediaFormat.KEY_DURATION) { track[KEY_DURATION] = it / 1000 }
                                    tracks.add(track)
                                }
                            }
                        } catch (e: Exception) {
                            Log.w(LOG_TAG, "failed to get motion photo track information for uri=$uri, track num=$trackIndex", e)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to open motion photo for uri=$uri", e)
        } finally {
            extractor.release()
            pfd?.close()
        }
        return tracks
    }

    fun getMotionPhotoOffset(context: Context, uri: Uri, mimeType: String, sizeBytes: Long): Long? {
        if (MimeTypes.isHeic(mimeType)) {
            // XMP in HEIC motion photos (as taken with a Samsung Camera v12.0.01.50) indicates an `Item:Length` of 68 bytes for the video.
            // This item does not contain the video itself, but only some kind of metadata (no doc, no spec),
            // so we ignore the `Item:Length` and look instead for the MP4 marker bytes indicating the start of the video.
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val bytes = ByteArray(sizeBytes.toInt())
                    DataInputStream(input).use {
                        it.readFully(bytes)
                    }
                    val index = bytes.indexOfBytes(heicMotionPhotoVideoStartIndicator)
                    if (index != -1) {
                        return sizeBytes - index
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get motion photo offset from uri=$uri", e)
            }
        }

        var offsetFromEnd: Long? = null
        var foundXmp = false

        fun processXmp(xmpMeta: XMPMeta) {
            if (xmpMeta.doesPropExist(XMP.GCAMERA_VIDEO_OFFSET_PROP_NAME)) {
                // `GCamera` motion photo
                xmpMeta.getSafeLong(XMP.GCAMERA_VIDEO_OFFSET_PROP_NAME) { offsetFromEnd = it }
            } else if (xmpMeta.doesPropExist(XMP.CONTAINER_DIRECTORY_PROP_NAME)) {
                // `Container` motion photo
                val count = xmpMeta.countPropArrayItems(XMP.CONTAINER_DIRECTORY_PROP_NAME)
                if (count == 2) {
                    // expect the video to be the second item
                    val i = 2
                    val mime = xmpMeta.getSafeStructField(listOf(XMP.CONTAINER_DIRECTORY_PROP_NAME, i, XMP.CONTAINER_ITEM_PROP_NAME, XMP.CONTAINER_ITEM_MIME_PROP_NAME))?.value
                    val length = xmpMeta.getSafeStructField(listOf(XMP.CONTAINER_DIRECTORY_PROP_NAME, i, XMP.CONTAINER_ITEM_PROP_NAME, XMP.CONTAINER_ITEM_LENGTH_PROP_NAME))?.value
                    if (MimeTypes.isVideo(mime) && length != null) {
                        offsetFromEnd = length.toLong()
                    }
                }
            }
        }

        try {
            Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                val metadata = Helper.safeRead(input)
                foundXmp = metadata.directories.any { it is XmpDirectory && it.tagCount > 0 }
                metadata.getDirectoriesOfType(XmpDirectory::class.java).map { it.xmpMeta }.forEach(::processXmp)
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get motion photo offset from uri=$uri", e)
        } catch (e: NoClassDefFoundError) {
            Log.w(LOG_TAG, "failed to get motion photo offset from uri=$uri", e)
        } catch (e: AssertionError) {
            Log.w(LOG_TAG, "failed to get motion photo offset from uri=$uri", e)
        }

        XMP.checkHeic(context, uri, mimeType, foundXmp, ::processXmp)

        return offsetFromEnd
    }

    fun getTiffPages(context: Context, uri: Uri): ArrayList<FieldMap> {
        fun toMap(page: Int, options: TiffBitmapFactory.Options): FieldMap {
            return hashMapOf(
                KEY_PAGE to page,
                KEY_MIME_TYPE to MimeTypes.TIFF,
                KEY_WIDTH to options.outWidth,
                KEY_HEIGHT to options.outHeight,
            )
        }

        val pages = ArrayList<FieldMap>()
        getTiffPageInfo(context, uri, 0)?.let { first ->
            pages.add(toMap(0, first))
            val pageCount = first.outDirectoryCount
            for (i in 1 until pageCount) {
                getTiffPageInfo(context, uri, i)?.let { pages.add(toMap(i, it)) }
            }
        }
        return pages
    }

    fun isMultiPageTiff(context: Context, uri: Uri) = (getTiffPageInfo(context, uri, 0)?.outDirectoryCount ?: 1) > 1

    private fun getTiffPageInfo(context: Context, uri: Uri, page: Int): TiffBitmapFactory.Options? {
        try {
            val fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
            if (fd == null) {
                Log.w(LOG_TAG, "failed to get TIFF file descriptor for uri=$uri")
                return null
            }
            val options = TiffBitmapFactory.Options().apply {
                inJustDecodeBounds = true
                inDirectoryNumber = page
            }
            TiffBitmapFactory.decodeFileDescriptor(fd, options)
            return options
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get TIFF page info for uri=$uri page=$page", e)
        }
        return null
    }
}
