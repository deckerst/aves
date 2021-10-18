package deckers.thibault.aves.model.provider

import android.content.Context
import android.net.Uri
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.util.Log
import com.drew.imaging.ImageMetadataReader
import com.drew.metadata.file.FileTypeDirectory
import deckers.thibault.aves.metadata.Metadata
import deckers.thibault.aves.metadata.MetadataExtractorHelper.getSafeString
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.model.SourceEntry
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils

internal class ContentImageProvider : ImageProvider() {
    override fun fetchSingle(context: Context, uri: Uri, sourceMimeType: String?, callback: ImageOpCallback) {
        // source MIME type may be incorrect, so we get a second opinion if possible
        var extractorMimeType: String? = null
        try {
            val safeUri = Uri.fromFile(Metadata.createPreviewFile(context, uri))
            StorageUtils.openInputStream(context, safeUri)?.use { input ->
                val metadata = ImageMetadataReader.readMetadata(input)
                for (dir in metadata.getDirectoriesOfType(FileTypeDirectory::class.java)) {
                    // `metadata-extractor` is the most reliable, except for `tiff` (false positives, false negatives)
                    // cf https://github.com/drewnoakes/metadata-extractor/issues/296
                    dir.getSafeString(FileTypeDirectory.TAG_DETECTED_FILE_MIME_TYPE) {
                        if (it != MimeTypes.TIFF) {
                            extractorMimeType = it
                            if (extractorMimeType != sourceMimeType) {
                                Log.d(LOG_TAG, "source MIME type is $sourceMimeType but extracted MIME type is $extractorMimeType for uri=$uri")
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get MIME type by metadata-extractor for uri=$uri", e)
        } catch (e: NoClassDefFoundError) {
            Log.w(LOG_TAG, "failed to get MIME type by metadata-extractor for uri=$uri", e)
        }

        val mimeType = extractorMimeType ?: sourceMimeType
        if (mimeType == null) {
            callback.onFailure(Exception("MIME type is null for uri=$uri"))
            return
        }

        val fields: FieldMap = hashMapOf(
            "uri" to uri.toString(),
            "sourceMimeType" to mimeType,
        )
        try {
            val cursor = context.contentResolver.query(uri, projection, null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME).let { if (it != -1) fields["title"] = cursor.getString(it) }
                cursor.getColumnIndex(OpenableColumns.SIZE).let { if (it != -1) fields["sizeBytes"] = cursor.getLong(it) }
                cursor.getColumnIndex(PATH).let { if (it != -1) fields["path"] = cursor.getString(it) }
                cursor.close()
            }
        } catch (e: Exception) {
            callback.onFailure(e)
            return
        }

        val entry = SourceEntry(fields).fillPreCatalogMetadata(context)
        if (entry.isSized || entry.isSvg || entry.isVideo) {
            callback.onSuccess(entry.toMap())
        } else {
            callback.onFailure(Exception("entry has no size"))
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ContentImageProvider>()

        @Suppress("DEPRECATION")
        const val PATH = MediaStore.MediaColumns.DATA

        private val projection = arrayOf(
            // standard columns for openable URI
            OpenableColumns.DISPLAY_NAME,
            OpenableColumns.SIZE,
            // optional path underlying media content
            PATH,
        )
    }
}