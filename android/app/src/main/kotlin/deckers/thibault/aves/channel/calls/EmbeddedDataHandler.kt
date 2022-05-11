package deckers.thibault.aves.channel.calls

import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import androidx.exifinterface.media.ExifInterface
import com.adobe.internal.xmp.XMPException
import com.adobe.internal.xmp.XMPUtils
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import com.drew.metadata.xmp.XmpDirectory
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.channel.calls.Coresult.Companion.safeSuspend
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.MetadataExtractorHelper
import deckers.thibault.aves.metadata.MultiPage
import deckers.thibault.aves.metadata.XMP
import deckers.thibault.aves.metadata.XMP.getSafeStructField
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.provider.ContentImageProvider
import deckers.thibault.aves.model.provider.ImageProvider
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.BitmapUtils.getBytes
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
import java.io.File
import java.io.InputStream

class EmbeddedDataHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getExifThumbnails" -> ioScope.launch { safeSuspend(call, result, ::getExifThumbnails) }
            "extractMotionPhotoVideo" -> ioScope.launch { safe(call, result, ::extractMotionPhotoVideo) }
            "extractVideoEmbeddedPicture" -> ioScope.launch { safe(call, result, ::extractVideoEmbeddedPicture) }
            "extractXmpDataProp" -> ioScope.launch { safe(call, result, ::extractXmpDataProp) }
            else -> result.notImplemented()
        }
    }

    private suspend fun getExifThumbnails(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getExifThumbnails-args", "failed because of missing arguments", null)
            return
        }

        val thumbnails = ArrayList<ByteArray>()
        if (canReadWithExifInterface(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    @Suppress("BlockingMethodInNonBlockingContext")
                    val exif = ExifInterface(input)
                    val orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
                    exif.thumbnailBitmap?.let { bitmap ->
                        TransformationUtils.rotateImageExif(BitmapUtils.getBitmapPool(context), bitmap, orientation)?.let {
                            it.getBytes(canHaveAlpha = false, recycle = false)?.let { bytes -> thumbnails.add(bytes) }
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

    private fun extractMotionPhotoVideo(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        if (mimeType == null || uri == null || sizeBytes == null) {
            result.error("extractMotionPhotoVideo-args", "failed because of missing arguments", null)
            return
        }

        MultiPage.getMotionPhotoOffset(context, uri, mimeType, sizeBytes)?.let { videoSizeBytes ->
            val videoStartOffset = sizeBytes - videoSizeBytes
            StorageUtils.openInputStream(context, uri)?.let { input ->
                input.skip(videoStartOffset)
                copyEmbeddedBytes(result, MimeTypes.MP4, displayName, input)
            }
            return
        }

        result.error("extractMotionPhotoVideo-empty", "failed to extract video from motion photo at uri=$uri", null)
    }

    private fun extractVideoEmbeddedPicture(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val displayName = call.argument<String>("displayName")
        if (uri == null) {
            result.error("extractVideoEmbeddedPicture-args", "failed because of missing arguments", null)
            return
        }

        val retriever = StorageUtils.openMetadataRetriever(context, uri)
        if (retriever != null) {
            try {
                retriever.embeddedPicture?.let { bytes ->
                    var embedMimeType: String? = null
                    bytes.inputStream().use { input ->
                        MetadataExtractorHelper.readMimeType(input)?.let { embedMimeType = it }
                    }
                    embedMimeType?.let { mime ->
                        copyEmbeddedBytes(result, mime, displayName, bytes.inputStream())
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
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        val displayName = call.argument<String>("displayName")
        val dataPropPath = call.argument<String>("propPath")
        val embedMimeType = call.argument<String>("propMimeType")
        if (mimeType == null || uri == null || dataPropPath == null || embedMimeType == null) {
            result.error("extractXmpDataProp-args", "failed because of missing arguments", null)
            return
        }

        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = MetadataExtractorHelper.safeRead(input, sizeBytes)
                    // data can be large and stored in "Extended XMP",
                    // which is returned as a second XMP directory
                    val xmpDirs = metadata.getDirectoriesOfType(XmpDirectory::class.java)
                    try {
                        val embedBytes: ByteArray = if (!dataPropPath.contains('/')) {
                            val propNs = XMP.namespaceForPropPath(dataPropPath)
                            xmpDirs.mapNotNull { it.xmpMeta.getPropertyBase64(propNs, dataPropPath) }.first()
                        } else {
                            xmpDirs.mapNotNull { it.xmpMeta.getSafeStructField(dataPropPath) }.first().let {
                                XMPUtils.decodeBase64(it.value)
                            }
                        }

                        copyEmbeddedBytes(result, embedMimeType, displayName, embedBytes.inputStream())
                        return
                    } catch (e: XMPException) {
                        result.error("extractXmpDataProp-xmp", "failed to read XMP directory for uri=$uri prop=$dataPropPath", e.message)
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
        result.error("extractXmpDataProp-empty", "failed to extract file from XMP uri=$uri prop=$dataPropPath", null)
    }

    private fun copyEmbeddedBytes(result: MethodChannel.Result, mimeType: String, displayName: String?, embeddedByteStream: InputStream) {
        val extension = extensionFor(mimeType)
        val file = File.createTempFile("aves", extension, context.cacheDir).apply {
            deleteOnExit()
            outputStream().use { output ->
                embeddedByteStream.use { input ->
                    input.copyTo(output)
                }
            }
        }
        val authority = "${context.applicationContext.packageName}.file_provider"
        val uri = if (displayName != null) {
            // add extension to ease type identification when sharing this content
            val displayNameWithExtension = if (extension == null || displayName.endsWith(extension, ignoreCase = true)) {
                displayName
            } else {
                "$displayName$extension"
            }
            FileProvider.getUriForFile(context, authority, file, displayNameWithExtension)
        } else {
            FileProvider.getUriForFile(context, authority, file)
        }
        val resultFields: FieldMap = hashMapOf(
            "uri" to uri.toString(),
            "mimeType" to mimeType,
        )
        if (isImage(mimeType) || isVideo(mimeType)) {
            ioScope.launch {
                ContentImageProvider().fetchSingle(context, uri, mimeType, object : ImageProvider.ImageOpCallback {
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