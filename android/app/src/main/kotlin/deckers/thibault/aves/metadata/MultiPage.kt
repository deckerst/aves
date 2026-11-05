package deckers.thibault.aves.metadata

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import com.adobe.internal.xmp.XMPMeta
import com.drew.imaging.jpeg.JpegSegmentType
import com.drew.metadata.exif.ExifDirectoryBase
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.glide.TiffFetcher
import deckers.thibault.aves.metadata.ExifInterfaceHelper.getSafeInt
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeInt
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper.getSafeLong
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper
import deckers.thibault.aves.metadata.metadataextractor.MetadataExtractorHelper.getSafeInt
import deckers.thibault.aves.metadata.metadataextractor.mpf.MpEntry
import deckers.thibault.aves.metadata.metadataextractor.mpf.MpEntryDirectory
import deckers.thibault.aves.metadata.xmp.GoogleXMP
import deckers.thibault.aves.metadata.xmp.XMP
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.storage.StorageUtils
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.canReadWithMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isHeic
import deckers.thibault.aves.utils.MimeTypes.isIsoBMFFImage
import deckers.thibault.aves.utils.indexOfBytes
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.DataInputStream
import java.io.EOFException
import androidx.exifinterface.media.ExifInterfaceFork as ExifInterface

object MultiPage {
    private val LOG_TAG = LogUtils.createTag<MultiPage>()

    // TODO TLAD more generic support, (e.g. 0x00000014 + `ftyp` + `qt  `)
    // atom length (variable, e.g. `0x00000018`) + atom type (`ftyp`) + type (variable, e.g. `mp42`, `qt`)
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
        val tracks = ArrayList<FieldMap>()
        val extractor = MediaExtractor()
        extractor.setDataSource(context, uri, null)
        for (pageIndex in 0..<extractor.trackCount) {
            try {
                val format = extractor.getTrackFormat(pageIndex)
                format.getString(MediaFormat.KEY_MIME)?.let { mime ->
                    val trackMime = if (mime == MediaFormat.MIMETYPE_IMAGE_ANDROID_HEIC) MimeTypes.HEIC else mime
                    val track: FieldMap = hashMapOf(
                        KEY_PAGE to pageIndex,
                        KEY_MIME_TYPE to trackMime,
                    )

                    // do not use `MediaFormat.KEY_TRACK_ID` as it is actually not unique between tracks
                    // e.g. there could be both a video track and an image track with KEY_TRACK_ID == 1

                    format.getSafeInt(MediaFormat.KEY_WIDTH) { track[KEY_WIDTH] = it }
                    format.getSafeInt(MediaFormat.KEY_HEIGHT) { track[KEY_HEIGHT] = it }
                    format.getSafeInt(MediaFormat.KEY_IS_DEFAULT) { track[KEY_IS_DEFAULT] = it != 0 }
                    format.getSafeInt(MediaFormat.KEY_ROTATION) { track[KEY_ROTATION_DEGREES] = it }
                    if (MimeTypes.isVideo(trackMime)) {
                        format.getSafeLong(MediaFormat.KEY_DURATION) { track[KEY_DURATION] = it / 1000 }
                    }
                    tracks.add(track)
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get HEIC track information for uri=$uri, pageIndex=$pageIndex", e)
            }
        }
        extractor.release()
        return tracks
    }

    fun isIsoBMFFImageSefdMotionPhoto(context: Context, uri: Uri): Boolean {
        return getIsoBMFFImageSefdMotionPhotoVideoSizing(context, uri) != null
    }

    private fun getIsoBMFFImageSefdMotionPhotoVideoSizing(context: Context, uri: Uri): Pair<Long, Long>? {
        Mp4ParserHelper.getSamsungSefd(context, uri)?.let { (sefdOffset, sefdBytes) ->
            // we could properly parse each tag until we find the "embedded video" tag (0x0a30)
            // but it seems that decoding the SEFT trailer is necessary for this,
            // so we simply search for the "MotionPhoto_Data" sequence instead
            val name = Mp4ParserHelper.SEFD_MOTION_PHOTO_NAME
            val index = sefdBytes.indexOfBytes(name.toByteArray(Charsets.UTF_8))
            if (index != -1) {
                val videoOffset = sefdOffset + index + name.length
                val videoSize = sefdBytes.size - (videoOffset - sefdOffset)
                return Pair(videoOffset, videoSize)
            }
        }
        return null
    }

    private fun getJpegMpfPrimaryRotation(context: Context, contentAddress: ContentAddress, sizeBytes: Long): Int {
        val mimeType = MimeTypes.JPEG
        var rotationDegrees = 0

        var foundExif = false
        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                    foundExif = metadata.directories.any { it is ExifDirectoryBase && it.tagCount > 0 }
                    for (dir in metadata.getDirectoriesOfType(ExifIFD0Directory::class.java)) {
                        dir.getSafeInt(ExifDirectoryBase.TAG_ORIENTATION) {
                            rotationDegrees = Metadata.getRotationDegreesForExifCode(it)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to read metadata by metadata-extractor for $contentAddress", e)
            }
        }

        if (!foundExif) {
            // fallback to read EXIF via `ExifInterface`
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    val exifInterface = ExifInterface(input)
                    exifInterface.getSafeInt(ExifInterface.TAG_ORIENTATION, acceptZero = false) {
                        rotationDegrees = exifInterface.rotationDegrees
                    }
                }
            } catch (e: Exception) {
                // `ExifInterface` initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                Log.w(LOG_TAG, "failed to get metadata by ExifInterface for $contentAddress", e)
            }
        }

        return rotationDegrees
    }

    // starts after `[APP2 marker (1 byte)] [segment size (2 bytes)] [MPF marker (4 bytes)]`
    fun getJpegMpfBaseOffset(context: Context, contentAddress: ContentAddress, sizeBytes: Long?): Int? {
        val endMarker = 0xFF
        val app2Marker = JpegSegmentType.APP2.byteValue
        val mpfMarker = "MPF".toByteArray() + 0x00

        try {
            Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                var offset = 0
                val marker = ByteArray(4)
                while (true) {
                    // look for APP2 marker (0xFFE2)
                    var found = false
                    while (!found) {
                        var i = input.read()
                        if (i == -1) throw EOFException()
                        offset++
                        if (i == endMarker) {
                            i = input.read()
                            if (i == -1) throw EOFException()
                            offset++
                            found = i.toByte() == app2Marker
                        }
                    }
                    // skip 2 bytes for segment size
                    input.skip(2)
                    offset += 2
                    input.read(marker, 0, marker.size)
                    offset += 4
                    if (marker.contentEquals(mpfMarker)) {
                        return offset
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get MPF base offset from $contentAddress", e)
        }
        return null
    }

    fun getJpegMpfEntries(context: Context, contentAddress: ContentAddress, sizeBytes: Long?): List<MpEntry>? {
        try {
            Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                return metadata.getDirectoriesOfType(MpEntryDirectory::class.java).map { it.entry }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to find MPF entries", e)
        } catch (e: NoClassDefFoundError) {
            Log.w(LOG_TAG, "failed to find MPF entries", e)
        } catch (e: AssertionError) {
            Log.w(LOG_TAG, "failed to find MPF entries", e)
        }
        return null
    }

    fun getJpegMpfPages(context: Context, contentAddress: ContentAddress, sizeBytes: Long): ArrayList<FieldMap> {
        val uri = contentAddress.uri

        val primaryRotation = getJpegMpfPrimaryRotation(context, contentAddress, sizeBytes)

        val pages = ArrayList<FieldMap>()
        val baseOffset = getJpegMpfBaseOffset(context, contentAddress, sizeBytes)
        val mpEntries = getJpegMpfEntries(context, contentAddress, sizeBytes)
        if (mpEntries != null && baseOffset != null) {
            for ((pageIndex, mpEntry) in mpEntries.withIndex()) {
                mpEntry.mimeType?.let { embedMimeType ->
                    val page = hashMapOf<String, Any?>(
                        KEY_PAGE to pageIndex,
                        KEY_MIME_TYPE to embedMimeType,
                        KEY_IS_DEFAULT to (pageIndex == 0),
                        KEY_ROTATION_DEGREES to primaryRotation,
                    )

                    var dataOffset = mpEntry.dataOffset
                    if (dataOffset > 0) {
                        dataOffset += baseOffset
                    }
                    StorageUtils.openInputStream(context, uri)?.let { input ->
                        input.skip(dataOffset)
                        val options = BitmapFactory.Options().apply {
                            inJustDecodeBounds = true
                        }
                        BitmapFactory.decodeStream(input, null, options)
                        options.outWidth.takeIf { it >= 0 }?.let { page[KEY_WIDTH] = it }
                        options.outHeight.takeIf { it >= 0 }?.let { page[KEY_HEIGHT] = it }

                        pages.add(page)
                    }
                }
            }
        }

        return pages
    }

    fun getJpegMpfBitmap(context: Context, contentAddress: ContentAddress): Bitmap? {
        val uri = contentAddress.uri
        val pageIndex = contentAddress.pageId ?: 0

        val mpEntries = getJpegMpfEntries(context, contentAddress, null)
        if (mpEntries != null && pageIndex < mpEntries.size) {
            val mpEntry = mpEntries[pageIndex]
            var dataOffset = mpEntry.dataOffset
            if (dataOffset > 0) {
                val baseOffset = getJpegMpfBaseOffset(context, contentAddress, null)
                if (baseOffset != null) {
                    dataOffset += baseOffset
                }
            }
            StorageUtils.openInputStream(context, uri)?.let { input ->
                input.skip(dataOffset)
                return BitmapFactory.decodeStream(input)
            }
        }
        return null
    }

    fun getMotionPhotoPages(context: Context, contentAddress: ContentAddress, sizeBytes: Long): ArrayList<FieldMap> {
        val mimeType = contentAddress.mimeType

        val pages = ArrayList<FieldMap>()
        getMotionPhotoVideoInfo(context, contentAddress, sizeBytes)?.let { videoInfo ->
            // set the original image as the first and default track
            var pageIndex = 0
            pages.add(
                hashMapOf(
                    KEY_PAGE to pageIndex++,
                    KEY_MIME_TYPE to mimeType,
                    KEY_IS_DEFAULT to true,
                )
            )
            // add video tracks from the appended video
            videoInfo.getString(MediaFormat.KEY_MIME)?.let { mime ->
                if (MimeTypes.isVideo(mime)) {
                    val page: FieldMap = hashMapOf(
                        KEY_PAGE to pageIndex,
                        KEY_MIME_TYPE to MimeTypes.MP4,
                        KEY_IS_DEFAULT to false,
                    )
                    videoInfo.getSafeInt(MediaFormat.KEY_WIDTH) { page[KEY_WIDTH] = it }
                    videoInfo.getSafeInt(MediaFormat.KEY_HEIGHT) { page[KEY_HEIGHT] = it }
                    videoInfo.getSafeInt(MediaFormat.KEY_ROTATION) { page[KEY_ROTATION_DEGREES] = it }
                    videoInfo.getSafeLong(MediaFormat.KEY_DURATION) { page[KEY_DURATION] = it / 1000 }
                    pages.add(page)
                }
            }
        }
        return pages
    }

    fun getTrailerVideoSize(context: Context, contentAddress: ContentAddress, sizeBytes: Long): Long? {
        val mimeType = contentAddress.mimeType

        if (isHeic(mimeType)) {
            // XMP in HEIC motion photos (as taken with a Samsung Camera v12.0.01.50) indicates an `Item:Length` of 68 bytes for the video.
            // This item does not contain the video itself, but only some kind of metadata (no doc, no spec),
            // so we ignore the `Item:Length` and look instead for the MP4 marker bytes indicating the start of the video.
            try {
                Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                    if (MemoryUtils.canAllocate(sizeBytes)) {
                        val bytes = ByteArray(sizeBytes.toInt())
                        DataInputStream(input).use {
                            it.readFully(bytes)
                        }
                        val index = bytes.indexOfBytes(heicMotionPhotoVideoStartIndicator)
                        if (index != -1) {
                            return sizeBytes - index
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get motion photo offset from $contentAddress", e)
            }
        }

        var offsetFromEnd: Long? = null
        var foundXmp = false

        fun processXmp(xmpMeta: XMPMeta) {
            offsetFromEnd = offsetFromEnd ?: GoogleXMP.getTrailingVideoOffsetFromEnd(xmpMeta)
        }

        try {
            Metadata.openSafeInputStream(context, contentAddress, sizeBytes)?.use { input ->
                val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes, contentAddress.path)
                foundXmp = metadata.directories.any { it is XmpDirectory && it.tagCount > 0 }
                metadata.getDirectoriesOfType(XmpDirectory::class.java).map { it.xmpMeta }.forEach(::processXmp)
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get motion photo offset from $contentAddress", e)
        } catch (e: NoClassDefFoundError) {
            Log.w(LOG_TAG, "failed to get motion photo offset from $contentAddress", e)
        } catch (e: AssertionError) {
            Log.w(LOG_TAG, "failed to get motion photo offset from $contentAddress", e)
        }

        XMP.checkIsoBMFFImage(context, contentAddress, foundXmp, ::processXmp)

        return offsetFromEnd
    }

    private fun getMotionPhotoVideoInfo(context: Context, contentAddress: ContentAddress, sizeBytes: Long): MediaFormat? {
        getMotionPhotoVideoSizing(context, contentAddress, sizeBytes)?.let { (videoOffset, videoSize) ->
            return getEmbedVideoInfo(context, contentAddress, videoOffset, videoSize)
        }
        return null
    }

    fun getTrailerVideoInfo(context: Context, contentAddress: ContentAddress, fileSize: Long, videoSize: Long): MediaFormat? {
        return getEmbedVideoInfo(context, contentAddress, videoOffset = fileSize - videoSize, videoSize = videoSize)
    }

    private fun getEmbedVideoInfo(context: Context, contentAddress: ContentAddress, videoOffset: Long, videoSize: Long): MediaFormat? {
        val uri = contentAddress.uri

        val extractor = MediaExtractor()
        var pfd: ParcelFileDescriptor? = null
        try {
            pfd = context.contentResolver.openFileDescriptor(uri, "r")
            pfd?.fileDescriptor?.let { fd ->
                extractor.setDataSource(fd, videoOffset, videoSize)
                // video track may be after an audio track
                for (trackIndex in 0..<extractor.trackCount) {
                    try {
                        val format = extractor.getTrackFormat(trackIndex)
                        format.getString(MediaFormat.KEY_MIME)?.let {
                            if (MimeTypes.isVideo(it)) {
                                return format
                            }
                        }
                    } catch (e: Exception) {
                        Log.w(LOG_TAG, "failed to get track information for $contentAddress, track num=$trackIndex", e)
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to open motion photo for $contentAddress", e)
        } finally {
            extractor.release()
            pfd?.close()
        }
        return null
    }

    fun getMotionPhotoVideoSizing(context: Context, contentAddress: ContentAddress, sizeBytes: Long): Pair<Long, Long>? {
        // default to trailer videos
        getTrailerVideoSize(context, contentAddress, sizeBytes)?.let { videoSize ->
            val videoOffset = sizeBytes - videoSize
            return Pair(videoOffset, videoSize)
        }

        val mimeType = contentAddress.mimeType
        val uri = contentAddress.uri

        if (isIsoBMFFImage(mimeType)) {
            // fallback to video within Samsung SEFD box
            return getIsoBMFFImageSefdMotionPhotoVideoSizing(context, uri)
        }

        return null
    }

    fun getTiffPages(context: Context, uri: Uri): ArrayList<FieldMap> {
        fun toMap(pageIndex: Int, options: TiffBitmapFactory.Options): FieldMap {
            return hashMapOf(
                KEY_PAGE to pageIndex,
                KEY_MIME_TYPE to MimeTypes.TIFF,
                KEY_WIDTH to options.outWidth,
                KEY_HEIGHT to options.outHeight,
            )
        }

        val pages = ArrayList<FieldMap>()
        getTiffPageInfo(context, uri, 0)?.let { first ->
            pages.add(toMap(0, first))
            val pageCount = first.outDirectoryCount
            for (pageIndex in 1..<pageCount) {
                getTiffPageInfo(context, uri, pageIndex)?.let { pages.add(toMap(pageIndex, it)) }
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
            val options = TiffFetcher.buildOptions().apply {
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
