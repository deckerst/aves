package deckers.thibault.aves.metadata

import android.os.Build
import android.util.Log
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.utils.LogUtils
import org.contentauth.c2pa.ByteArrayStream
import org.contentauth.c2pa.C2PAError
import org.contentauth.c2pa.FileStream
import org.contentauth.c2pa.Reader
import org.json.JSONObject
import java.io.File

enum class C2paValidity {
    UNKNOWN, INVALID, VALID, TRUSTED
}

object C2paHelper {
    private val LOG_TAG = LogUtils.createTag<C2paHelper>()
    const val KEY_VALIDATION_STATE = "validation_state"

    fun getValidity(contentAddress: ContentAddress): C2paValidity {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return C2paValidity.UNKNOWN
        }

        val path = contentAddress.path ?: return C2paValidity.UNKNOWN
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        val imageStream = FileStream(File(path), FileStream.Mode.READ)
        imageStream.use { imageStream ->
            try {
                Reader.fromStream(contentAddress.mimeType, imageStream).use { reader ->
                    val json = JSONObject(reader.json())
                    if (json.has(KEY_VALIDATION_STATE)) {
                        return when (val validationState = json.getString(KEY_VALIDATION_STATE)) {
                            "Invalid" -> C2paValidity.INVALID
                            "Valid" -> C2paValidity.VALID
                            "Trusted" -> C2paValidity.TRUSTED
                            else -> throw Exception("unknown validation state=$validationState")
                        }
                    }
                }
            } catch (ex: C2PAError.Api) {
                if (!ex.message.contains("ManifestNotFound")) {
                    Log.w(LOG_TAG, "failed to read C2PA manifest from $contentAddress", ex)
                }
            }
        }

        return C2paValidity.UNKNOWN
    }

    fun getManifestJson(contentAddress: ContentAddress): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return null
        }

        val path = contentAddress.path ?: return null
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        val imageStream = FileStream(File(path), FileStream.Mode.READ)
        imageStream.use { imageStream ->
            try {
                Reader.fromStream(contentAddress.mimeType, imageStream).use { reader ->
                    return reader.json()
                }
            } catch (_: C2PAError.Api) {
                // ignore
                return null
            }
        }
    }

    fun openResource(contentAddress: ContentAddress, uri: String): ByteArray? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return null
        }

        val path = contentAddress.path ?: return null
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        val imageStream = FileStream(File(path), FileStream.Mode.READ)
        imageStream.use { imageStream ->
            try {
                Reader.fromStream(contentAddress.mimeType, imageStream).use { reader ->
                    ByteArrayStream().use { outputStream ->
                        reader.resource(uri, outputStream)
                        return outputStream.getData()
                    }
                }
            } catch (_: C2PAError.Api) {
                // ignore
                return null
            }
        }
    }
}