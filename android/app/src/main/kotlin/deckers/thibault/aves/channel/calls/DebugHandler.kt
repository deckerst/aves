package deckers.thibault.aves.channel.calls

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import com.drew.imaging.ImageMetadataReader
import com.drew.metadata.file.FileTypeDirectory
import deckers.thibault.aves.metadata.ExifInterfaceHelper
import deckers.thibault.aves.metadata.MediaMetadataRetrieverHelper
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes.isImage
import deckers.thibault.aves.utils.MimeTypes.isSupportedByExifInterface
import deckers.thibault.aves.utils.MimeTypes.isSupportedByMetadataExtractor
import deckers.thibault.aves.utils.MimeTypes.isVideo
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.IOException
import java.util.*

class DebugHandler(private val context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getContextDirs" -> result.success(getContextDirs())
            "getEnv" -> result.success(System.getenv())
            "getBitmapFactoryInfo" -> GlobalScope.launch { getBitmapFactoryInfo(call, Coresult(result)) }
            "getContentResolverMetadata" -> GlobalScope.launch { getContentResolverMetadata(call, Coresult(result)) }
            "getExifInterfaceMetadata" -> GlobalScope.launch { getExifInterfaceMetadata(call, Coresult(result)) }
            "getMediaMetadataRetrieverMetadata" -> GlobalScope.launch { getMediaMetadataRetrieverMetadata(call, Coresult(result)) }
            "getMetadataExtractorSummary" -> GlobalScope.launch { getMetadataExtractorSummary(call, Coresult(result)) }
            else -> result.notImplemented()
        }
    }

    private fun getContextDirs() = hashMapOf(
        "dataDir" to context.dataDir,
        "cacheDir" to context.cacheDir,
        "codeCacheDir" to context.codeCacheDir,
        "filesDir" to context.filesDir,
        "noBackupFilesDir" to context.noBackupFilesDir,
        "obbDir" to context.obbDir,
        "externalCacheDir" to context.externalCacheDir,
    ).mapValues { it.value?.path }

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
        if (uri.scheme == ContentResolver.SCHEME_CONTENT && MediaStore.AUTHORITY.equals(uri.host, ignoreCase = true)) {
            try {
                val id = ContentUris.parseId(uri)
                contentUri = when {
                    isImage(mimeType) -> ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    isVideo(mimeType) -> ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    else -> uri
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    contentUri = MediaStore.setRequireOriginal(contentUri)
                }
            } catch (e: NumberFormatException) {
                // ignore
            }
        }

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
            result.success(metadataMap)
        } else {
            result.error("getContentResolverMetadata-null", "failed to get cursor for contentUri=$contentUri", null)
        }
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
        if (isSupportedByExifInterface(mimeType, sizeBytes, strict = false)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
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
        if (isSupportedByMetadataExtractor(mimeType, sizeBytes)) {
            try {
                StorageUtils.openInputStream(context, uri)?.use { input ->
                    val metadata = ImageMetadataReader.readMetadata(input, sizeBytes ?: -1)
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

    companion object {
        private val LOG_TAG = LogUtils.createTag(DebugHandler::class.java)
        const val CHANNEL = "deckers.thibault/aves/debug"
    }
}