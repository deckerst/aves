package deckers.thibault.aves.metadata.c2pa

import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.utils.LogUtils
import org.contentauth.c2pa.ByteArrayStream
import org.contentauth.c2pa.C2PAContext
import org.contentauth.c2pa.C2PAError
import org.contentauth.c2pa.C2PASettings
import org.contentauth.c2pa.FileStream
import org.contentauth.c2pa.Reader
import org.contentauth.c2pa.settings.C2PASettingsDefinition
import org.contentauth.c2pa.settings.TrustSettings
import org.json.JSONObject
import java.io.File

object C2paReading {
    private val LOG_TAG = LogUtils.createTag<C2paReading>()
    private const val KEY_VALIDATION_STATE = "validation_state"

    private fun read(
        context: Context,
        contentAddress: ContentAddress,
        inputStream: FileStream,
    ): Reader {
        val settingsDefinition = C2PASettingsDefinition(
            trust = TrustSettings(
                trustAnchors = C2paCommon.getTrustAnchors(context),
            ),
        )
        C2PASettings.fromDefinition(settingsDefinition).use { settings ->
            C2PAContext.fromSettings(settings).use { c2paContext ->
                return Reader.fromContext(c2paContext).withStream(contentAddress.mimeType, inputStream)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.P)
    fun getValidity(context: Context, contentAddress: ContentAddress): C2paValidity {
        val path = contentAddress.path ?: return C2paValidity.UNKNOWN
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        FileStream(File(path), FileStream.Mode.READ).use { inputStream ->
            try {
                read(context, contentAddress, inputStream).use { reader ->
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

    @RequiresApi(Build.VERSION_CODES.P)
    fun getManifestJson(context: Context, contentAddress: ContentAddress): String? {
        val path = contentAddress.path ?: return null
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        FileStream(File(path), FileStream.Mode.READ).use { inputStream ->
            try {
                read(context, contentAddress, inputStream).use { reader ->
                    return reader.json()
                }
            } catch (_: C2PAError.Api) {
                // ignore
                return null
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.P)
    fun openResource(context: Context, contentAddress: ContentAddress, uri: String): ByteArray? {
        val path = contentAddress.path ?: return null
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        FileStream(File(path), FileStream.Mode.READ).use { inputStream ->
            try {
                read(context, contentAddress, inputStream).use { reader ->
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