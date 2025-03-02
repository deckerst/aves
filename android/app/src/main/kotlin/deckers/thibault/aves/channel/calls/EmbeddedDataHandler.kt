package deckers.thibault.aves.channel.calls

import android.content.Context
import android.util.Log
import androidx.core.content.FileProvider
import androidx.core.net.toUri
import androidx.exifinterface.media.ExifInterface
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPUtils
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.metadata.metadataextractor.Helper
import deckers.thibault.aves.metadata.xmp.GoogleDeviceContainer
import deckers.thibault.aves.metadata.xmp.GoogleXMP
import deckers.thibault.aves.metadata.xmp.XMP.getSafeStructField
import deckers.thibault.aves.metadata.xmp.XMPPropName
import deckers.thibault.aves.model.EntryFields
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.provider.ImageProvider
import deckers.thibault.aves.model.provider.ImageProviderFactory.getProvider
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getEncodedBytes
import deckers.thibault.aves.utils.FileUtils.transferFrom
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.MimeTypes.canReadWithExifInterface
import deckers.thibault.aves.utils.MimeTypes.canReadWithMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.extensionFor
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.io.InputStream

class EmbeddedDataHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getExifThumbnails" -> ioScope.launch { safeSuspend(call, result, ::getExifThumbnails) }
            "extractGoogleDeviceItem" -> ioScope.launch { safe(call, result, ::extractGoogleDeviceItem) }
            "extractJpegMpfItem" -> ioScope.launch { safe(call, result, ::extractJpegMpfItem) }
            "extractMotionPhotoImage" -> ioScope.launch { safe(call, result, ::extractMotionPhotoImage) }
            "extractMotionPhotoVideo" -> ioScope.launch { safe(call, result, ::extractMotionPhotoVideo) }
            "extractVideoEmbeddedPicture" -> ioScope.launch { safe(call, result, ::extractVideoEmbeddedPicture) }
            "extractXmpDataProp" -> ioScope.launch { safe(call, result, ::extractXmpDataProp) }
            else -> result.notImplemented()
        }
    }

    private suspend fun getExifThumbnails(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.toUri()
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getExifThumbnails-args", "missing arguments", null)
            return
        }

        val thumbnails = ArrayList<ByteArray>()
        if (canReadWithExifInterface(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val exif = ExifInterface(input)
                    val orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                    exif.thumbnailBitmap?.let { bitmap ->
                        TransformationUtils.rotateImageExif(BitmapUtils.getBitmapPool(context), bitmap, orientation)?.let {
                            it.getEncodedBytes(canHaveAlpha = false, recycle = false)?.let { bytes -> thumbnails.add(bytes) }
                        }
                    }
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
            }
        }
        result.success(thumbnails)
    }

    private fun extractGoogleDeviceItem(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.toUri()
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        val dataUri = call.argument<String>("dataUri")
        if (mimeType == null || uri == null || sizeBytes == null || dataUri == null) {
            result.error("extractGoogleDeviceItem-args", "missing arguments", null)
            return
        }

        var container: GoogleDeviceContainer? = null

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = Helper.safeRead(input, sizeBytes)
                    // data can be large and stored in "Extended XMP",
                    // which is returned as a second XMP directory
                    val xmpDirs = metadata.getDirectoriesOfType(XmpDirectory::class.java)
                    try {
                        container = xmpDirs.firstNotNullOfOrNull { GoogleXMP.getDeviceContainer(it.xmpMeta) }
                    } catch (e: XMPException) {
                        result.error("extractGoogleDeviceItem-xmp", "failed to read XMP directory for uri=$uri dataUri=$dataUri", e.message)
                        return
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            }
        }

        container?.let {
            it.findOffsets(context, uri, mimeType, sizeBytes)

            val index = it.itemIndex(dataUri)
            val itemStartOffset = it.itemStartOffset(index)
            val itemLength = it.itemLength(index)
            val itemMimeType = it.itemMimeType(index)
            if (itemStartOffset != null && itemLength != null && itemMimeType != null) {
                StorageUtils.openInputStream(context, uri)?.let { input ->
                    input.skip(itemStartOffset)
                    copyEmbeddedBytes(result, itemMimeType, displayName, input, itemLength)
                    return
                }
            }
        }

        result.error("extractGoogleDeviceItem-empty", "failed to extract item from Google Device XMP at uri=$uri dataUri=$dataUri", null)
    }

    private fun extractJpegMpfItem(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.toUri()
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        val id = call.argument<Int>("id")
        if (mimeType == null || uri == null || sizeBytes == null || id == null) {
            result.error("extractJpegMpfItem-args", "missing arguments", null)
            return
        }

        val pageIndex = id - 1
        val mpEntries = MultiPage.getJpegMpfEntries(context, uri, sizeBytes)
        if (mpEntries != null && pageIndex < mpEntries.size) {
            val mpEntry = mpEntries[pageIndex]
            mpEntry.mimeType?.let { embedMimeType ->
                var dataOffset = mpEntry.dataOffset
                if (dataOffset > 0) {
                    val baseOffset = MultiPage.getJpegMpfBaseOffset(context, uri, sizeBytes)
                    if (baseOffset != null) {
                        dataOffset += baseOffset
                    }
                }
                StorageUtils.openInputStream(context, uri)?.let { input ->
                    input.skip(dataOffset)
                    copyEmbeddedBytes(result, embedMimeType, displayName, input, mpEntry.size)
                }
                return
            }
        }

        result.error("extractJpegMpfItem-empty", "failed to extract file index=$id from MPF at uri=$uri", null)
    }

    private fun extractMotionPhotoImage(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.toUri()
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        if (mimeType == null || uri == null || sizeBytes == null) {
            result.error("extractMotionPhotoImage-args", "missing arguments", null)
            return
        }

        MultiPage.getTrailerVideoSize(context, uri, mimeType, sizeBytes)?.let { videoSizeBytes ->
            val imageSizeBytes = sizeBytes - videoSizeBytes
            StorageUtils.openInputStream(context, uri)?.let { input ->
                copyEmbeddedBytes(result, mimeType, displayName, input, imageSizeBytes)
            }
            return
        }

        result.error("extractMotionPhotoImage-empty", "failed to extract image from motion photo at uri=$uri", null)
    }

    private fun extractMotionPhotoVideo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.toUri()
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        if (mimeType == null || uri == null || sizeBytes == null) {
            result.error("extractMotionPhotoVideo-args", "missing arguments", null)
            return
        }

        MultiPage.getMotionPhotoVideoSizing(context, uri, mimeType, sizeBytes)?.let { (videoOffset, videoSize) ->
            StorageUtils.openInputStream(context, uri)?.let { input ->
                input.skip(videoOffset)
                copyEmbeddedBytes(result, MimeTypes.MP4, displayName, input, videoSize)
            }
            return
        }

        result.error("extractMotionPhotoVideo-empty", "failed to extract video from motion photo at uri=$uri", null)
    }

    private fun extractVideoEmbeddedPicture(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.toUri()
        val displayName = call.argument<String>("displayName")
        if (uri == null) {
            result.error("extractVideoEmbeddedPicture-args", "missing arguments", null)
            return
        }

        val retriever = StorageUtils.openMetadataRetriever(context, uri)
        if (retriever != null) {
            try {
                retriever.embeddedPicture?.let { bytes ->
                    var embedMimeType: String? = null
                    bytes.inputStream().use { input ->
                        Helper.readMimeType(input)?.let { embedMimeType = it }
                    }
                    embedMimeType?.let { mime ->
                        copyEmbeddedBytes(result, mime, displayName, bytes.inputStream(), bytes.size.toLong())
                        return
                    }
                }
            } catch (e: Exception) {
                result.error("extractVideoEmbeddedPicture-fetch", "failed to fetch picture for uri=$uri", e.message)
            } finally {
                // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                retriever.release()
            }
        }
        result.error("extractVideoEmbeddedPicture-empty", "failed to extract picture for uri=$uri", null)
    }

    private fun extractXmpDataProp(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.toUri()
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        val dataProp = call.argument<List<Any>>("propPath")
        val embedMimeType = call.argument<String>("propMimeType")
        if (mimeType == null || uri == null || dataProp == null || embedMimeType == null) {
            result.error("extractXmpDataProp-args", "missing arguments", null)
            return
        }

        val props = dataProp.mapNotNull {
            when (it) {
                is List<*> -> XMPPropName(it.first() as String, it.last() as String)
                is Int -> it
                else -> null
            }
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = Helper.safeRead(input, sizeBytes)
                    // data can be large and stored in "Extended XMP",
                    // which is returned as a second XMP directory
                    val xmpDirs = metadata.getDirectoriesOfType(XmpDirectory::class.java)
                    try {
                        val embedBytes: ByteArray = if (props.size == 1) {
                            val prop = props.first() as XMPPropName
                            xmpDirs.firstNotNullOf { it.xmpMeta.getPropertyBase64(prop.nsUri, prop.toString()) }
                        } else {
                            xmpDirs.firstNotNullOf { it.xmpMeta.getSafeStructField(props) }.let {
                                XMPUtils.decodeBase64(it.value)
                            }
                        }

                        copyEmbeddedBytes(result, embedMimeType, displayName, embedBytes.inputStream(), embedBytes.size.toLong())
                        return
                    } catch (e: XMPException) {
                        result.error("extractXmpDataProp-xmp", "failed to read XMP directory for uri=$uri prop=$dataProp", e.message)
                        return
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            } catch (e: AssertionError) {
                Log.w(LOG_TAG, "failed to extract file from XMP", e)
            }
        }
        result.error("extractXmpDataProp-empty", "failed to extract file from XMP uri=$uri prop=$dataProp", null)
    }

    private fun copyEmbeddedBytes(
        result: MethodChannel.Result,
        mimeType: String,
        displayName: String?,
        embeddedByteStream: InputStream,
        embeddedByteLength: Long,
    ) {
        val extension = extensionFor(mimeType)
        val targetFile = StorageUtils.createTempFile(context, extension).apply {
            transferFrom(embeddedByteStream, embeddedByteLength)
        }

        val authority = "${context.applicationContext.packageName}.file_provider"
        val uri = if (displayName != null) {
            // add extension to ease type identification when sharing this content
            val displayNameWithExtension = if (extension == null || displayName.endsWith(extension, ignoreCase = true)) {
                displayName
            } else {
                "$displayName$extension"
            }
            FileProvider.getUriForFile(context, authority, targetFile, displayNameWithExtension)
        } else {
            FileProvider.getUriForFile(context, authority, targetFile)
        }
        val resultFields: FieldMap = hashMapOf(
            EntryFields.URI to uri.toString(),
            EntryFields.MIME_TYPE to mimeType,
        )
        if (isImage(mimeType) || isVideo(mimeType)) {
            val provider = getProvider(context, uri)
            if (provider == null) {
                result.error("copyEmbeddedBytes-provider", "failed to find provider for uri=$uri", null)
                return
            }

            ioScope.launch {
                provider.fetchSingle(context, uri, mimeType, false, object : ImageProvider.ImageOpCallback {
                    override fun onSuccess(fields: FieldMap) {
                        resultFields.putAll(fields)
                        result.success(resultFields)
                    }

                    override fun onFailure(throwable: Throwable) = result.error("copyEmbeddedBytes-failure", "failed to get entry for uri=$uri mime=$mimeType", throwable.message)
                })
            }
        } else {
            result.success(resultFields)
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<EmbeddedDataHandler>()
        const val CHANNEL = "deckers.thibault/aves/embedded"
    }
}