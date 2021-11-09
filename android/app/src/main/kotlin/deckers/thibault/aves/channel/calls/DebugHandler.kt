package deckers.thibault.aves.channel.calls

import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.graphics.BitmapFactory
import android.media.MediaCodecInfo
import android.media.MediaCodecList
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.drew.imaging.ImageMetadataReader
import com.drew.metadata.file.FileTypeDirectory
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.metadata.ExifInterfaceHelper
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.PixyMetaHelper
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes.canReadWithExifInterface
import deckers.thibault.aves.utils.MimeTypes.canReadWithMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.canReadWithPixyMeta
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.UriUtils.tryParseId
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.beyka.tiffbitmapfactory.TiffBitmapFactory
import java.io.IOException
import java.util.*

class DebugHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "crash" -> Handler(Looper.getMainLooper()).postDelayed({ throw TestException() }, 50)
            "exception" -> throw TestException()
            "safeException" -> safe(call, result) { _, _ -> throw TestException() }
            "exceptionInCoroutine" -> GlobalScope.launch(Dispatchers.IO) { throw TestException() }
            "safeExceptionInCoroutine" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result) { _, _ -> throw TestException() } }

            "getContextDirs" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getContextDirs) }
            "getCodecs" -> safe(call, result, ::getCodecs)
            "getEnv" -> safe(call, result, ::getEnv)

            "getBitmapFactoryInfo" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getBitmapFactoryInfo) }
            "getContentResolverMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getContentResolverMetadata) }
            "getExifInterfaceMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getExifInterfaceMetadata) }
            "getMediaMetadataRetrieverMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getMediaMetadataRetrieverMetadata) }
            "getMetadataExtractorSummary" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getMetadataExtractorSummary) }
            "getPixyMetadata" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getPixyMetadata) }
            "getTiffStructure" -> GlobalScope.launch(Dispatchers.IO) { safe(call, result, ::getTiffStructure) }
            else -> result.notImplemented()
        }
    }

    private fun getContextDirs(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val dirs = hashMapOf(
            "cacheDir" to context.cacheDir,
            "filesDir" to context.filesDir,
            "obbDir" to context.obbDir,
            "externalCacheDir" to context.externalCacheDir,
        ).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                putAll(
                    hashMapOf(
                        "codeCacheDir" to context.codeCacheDir,
                        "noBackupFilesDir" to context.noBackupFilesDir,
                    )
                )
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                put("dataDir", context.dataDir)
            }
        }.mapValues { it.value?.path }

        result.success(dirs)
    }

    private fun getCodecs(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        val codecs = ArrayList<FieldMap>()

        fun getFields(info: MediaCodecInfo): FieldMap {
            val fields: FieldMap = hashMapOf(
                "name" to info.name,
                "isEncoder" to info.isEncoder,
                "supportedTypes" to info.supportedTypes.joinToString(", "),
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                if (info.canonicalName != info.name) fields["canonicalName"] = info.canonicalName
                if (info.isAlias) fields["isAlias"] to info.isAlias
                if (info.isHardwareAccelerated) fields["isHardwareAccelerated"] to info.isHardwareAccelerated
                if (info.isSoftwareOnly) fields["isSoftwareOnly"] to info.isSoftwareOnly
                if (info.isVendor) fields["isVendor"] to info.isVendor
            }
            return fields
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            codecs.addAll(MediaCodecList(MediaCodecList.REGULAR_CODECS).codecInfos.map(::getFields))
        } else {
            @Suppress("deprecation")
            val count = MediaCodecList.getCodecCount()
            for (i in 0 until count) {
                @Suppress("deprecation")
                val info = MediaCodecList.getCodecInfoAt(i)
                codecs.add(getFields(info))
            }
        }

        result.success(codecs)
    }

    private fun getEnv(@Suppress("unused_parameter") call: MethodCall, result: MethodChannel.Result) {
        result.success(System.getenv())
    }

    private fun getBitmapFactoryInfo(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (uri == null) {
            result.error("getBitmapDecoderInfo-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        try {
            StorageUtils.openInputStream(context, uri)?.use { input ->
                val options = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                BitmapFactory.decodeStream(input, null, options)
                options.outMimeType?.let { metadataMap["MimeType"] = it }
                options.outWidth.takeIf { it >= 0 }?.let { metadataMap["Width"] = it.toString() }
                options.outHeight.takeIf { it >= 0 }?.let { metadataMap["Height"] = it.toString() }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    options.outColorSpace?.let { metadataMap["ColorSpace"] = it.toString() }
                    options.outConfig?.let { metadataMap["Config"] = it.toString() }
                }
            }
        } catch (e: IOException) {
            // ignore
        }
        result.success(metadataMap)
    }

    private fun getContentResolverMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (mimeType == null || uri == null) {
            result.error("getContentResolverMetadata-args", "failed because of missing arguments", null)
            return
        }

        var contentUri: Uri = uri
        if (StorageUtils.isMediaStoreContentUri(uri)) {
            uri.tryParseId()?.let { id ->
                contentUri = when {
                    isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    else -> uri
                }
                contentUri = StorageUtils.getOriginalUri(context, contentUri)
            }
        }

        // prefer image/video content URI, fallback to original URI (possibly a file content URI)
        val metadataMap = getContentResolverMetadataForUri(contentUri) ?: getContentResolverMetadataForUri(uri)
        if (metadataMap != null) {
            result.success(metadataMap)
        } else {
            result.error("getContentResolverMetadata-null", "failed to get cursor for contentUri=$contentUri", null)
        }
    }

    private fun getContentResolverMetadataForUri(contentUri: Uri): FieldMap? {
        val cursor = context.contentResolver.query(contentUri, null, null, null, null)
        if (cursor != null && cursor.moveToFirst()) {
            val metadataMap = HashMap<String, Any?>()
            val columnCount = cursor.columnCount
            val columnNames = cursor.columnNames
            for (i in 0 until columnCount) {
                val key = columnNames[i]
                try {
                    metadataMap[key] = when (cursor.getType(i)) {
                        Cursor.FIELD_TYPE_NULL -> null
                        Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(i)
                        Cursor.FIELD_TYPE_FLOAT -> cursor.getFloat(i)
                        Cursor.FIELD_TYPE_STRING -> cursor.getString(i)
                        Cursor.FIELD_TYPE_BLOB -> cursor.getBlob(i)
                        else -> null
                    }
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "failed to get value for key=$key", e)
                }
            }
            cursor.close()
            return metadataMap
        }
        return null
    }

    private fun getExifInterfaceMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getExifInterfaceMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String?>()
        if (canReadWithExifInterface(mimeType, strict = false)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val exif = ExifInterface(input)
                    for (tag in ExifInterfaceHelper.allTags.keys.filter { exif.hasAttribute(it) }) {
                        metadataMap[tag] = exif.getAttribute(tag)
                    }
                }
            } catch (e: Exception) {
                // ExifInterface initialization can fail with a RuntimeException
                // caused by an internal MediaMetadataRetriever failure
                result.error("getExifInterfaceMetadata-failure", "failed to get exif for uri=$uri", e.message)
                return
            }
        }
        result.success(metadataMap)
    }

    private fun getMediaMetadataRetrieverMetadata(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (uri == null) {
            result.error("getMediaMetadataRetrieverMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        val retriever = StorageUtils.openMetadataRetriever(context, uri)
        if (retriever != null) {
            try {
                for ((code, name) in MediaMetadataRetrieverHelper.allKeys) {
                    retriever.extractMetadata(code)?.let { metadataMap[name] = it }
                }
            } catch (e: Exception) {
                // ignore
            } finally {
                // cannot rely on `MediaMetadataRetriever` being `AutoCloseable` on older APIs
                retriever.release()
            }
        }
        result.success(metadataMap)
    }

    private fun getMetadataExtractorSummary(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        val sizeBytes = call.argument<Number>("sizeBytes")?.toLong()
        if (mimeType == null || uri == null) {
            result.error("getMetadataExtractorSummary-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        if (canReadWithMetadataExtractor(mimeType)) {
            try {
                Metadata.openSafeInputStream(context, uri, mimeType, sizeBytes)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input)
                    metadataMap["mimeType"] = metadata.getDirectoriesOfType(FileTypeDirectory::class.java).joinToString { dir ->
                        if (dir.containsTag(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)) {
                            dir.getString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE)
                        } else ""
                    }
                    metadataMap["typeName"] = metadata.getDirectoriesOfType(FileTypeDirectory::class.java).joinToString { dir ->
                        if (dir.containsTag(FileTypeDirectory.TAG_DETECTED_FILE_TYPE_NAME)) {
                            dir.getString(FileTypeDirectory.TAG_DETECTED_FILE_TYPE_NAME)
                        } else ""
                    }
                    for (dir in metadata.directories) {
                        val dirName = dir.name ?: ""
                        var index = 0
                        while (metadataMap.containsKey("$dirName ($index)")) index++
                        var value = "${dir.tagCount} tags"
                        dir.parent?.let { value += ", parent: ${it.name}" }
                        metadataMap["$dirName ($index)"] = value
                    }
                }
            } catch (e: Exception) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            } catch (e: NoClassDefFoundError) {
                Log.w(LOG_TAG, "failed to get metadata by metadata-extractor for uri=$uri", e)
            }
        }
        result.success(metadataMap)
    }

    private fun getPixyMetadata(call: MethodCall, result: MethodChannel.Result) {
        val mimeType = call.argument<String>("mimeType")
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (mimeType == null || uri == null) {
            result.error("getPixyMetadata-args", "failed because of missing arguments", null)
            return
        }

        val metadataMap = HashMap<String, String>()
        if (canReadWithPixyMeta(mimeType)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    metadataMap.putAll(PixyMetaHelper.describe(input))
                }
            } catch (e: Exception) {
                result.error("getPixyMetadata-exception", e.message, e.stackTraceToString())
                return
            }
        }
        result.success(metadataMap)
    }

    private fun getTiffStructure(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
        if (uri == null) {
            result.error("getTiffStructure-args", "failed because of missing arguments", null)
            return
        }

        try {
            val metadataMap = HashMap<String, FieldMap>()
            var fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
            if (fd == null) {
                result.error("getTiffStructure-fd", "failed to get file descriptor", null)
                return
            }
            var options = TiffBitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            TiffBitmapFactory.decodeFileDescriptor(fd, options)
            metadataMap["0"] = tiffOptionsToMap(options)
            val dirCount = options.outDirectoryCount
            for (page in 1 until dirCount) {
                fd = context.contentResolver.openFileDescriptor(uri, "r")?.detachFd()
                if (fd == null) {
                    result.error("getTiffStructure-fd", "failed to get file descriptor", null)
                    return
                }
                options = TiffBitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                    inDirectoryNumber = page
                }
                TiffBitmapFactory.decodeFileDescriptor(fd, options)
                metadataMap["$page"] = tiffOptionsToMap(options)
            }
            result.success(metadataMap)
        } catch (e: Exception) {
            result.error("getTiffStructure-read", "failed to read tiff", e.message)
        }
    }

    private fun tiffOptionsToMap(options: TiffBitmapFactory.Options): FieldMap = hashMapOf(
        "Author" to options.outAuthor,
        "BitsPerSample" to options.outBitsPerSample.toString(),
        "CompressionScheme" to options.outCompressionScheme?.toString(),
        "Copyright" to options.outCopyright,
        "CurDirectoryNumber" to options.outCurDirectoryNumber.toString(),
        "Datetime" to options.outDatetime,
        "DirectoryCount" to options.outDirectoryCount.toString(),
        "FillOrder" to options.outFillOrder?.toString(),
        "Height" to options.outHeight.toString(),
        "HostComputer" to options.outHostComputer,
        "ImageDescription" to options.outImageDescription,
        "ImageOrientation" to options.outImageOrientation?.toString(),
        "NumberOfStrips" to options.outNumberOfStrips.toString(),
        "Photometric" to options.outPhotometric?.toString(),
        "PlanarConfig" to options.outPlanarConfig?.toString(),
        "ResolutionUnit" to options.outResolutionUnit?.toString(),
        "RowPerStrip" to options.outRowPerStrip.toString(),
        "SamplePerPixel" to options.outSamplePerPixel.toString(),
        "Software" to options.outSoftware,
        "StripSize" to options.outStripSize.toString(),
        "TileHeight" to options.outTileHeight.toString(),
        "TileWidth" to options.outTileWidth.toString(),
        "Width" to options.outWidth.toString(),
        "XResolution" to options.outXResolution.toString(),
        "YResolution" to options.outYResolution.toString(),
    )

    companion object {
        private val LOG_TAG = LogUtils.createTag<DebugHandler>()
        const val CHANNEL = "deckers.thibault/aves/debug"
    }

    class TestException internal constructor() : RuntimeException("oops")
}