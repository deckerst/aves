package deckers.thibault.aves.metadata.c2pa

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import deckers.thibault.aves.model.ContentAddress
import deckers.thibault.aves.storage.StorageUtils
import org.contentauth.c2pa.Builder
import org.contentauth.c2pa.BuilderIntent
import org.contentauth.c2pa.C2PAContext
import org.contentauth.c2pa.C2PASettings
import org.contentauth.c2pa.CertificateManager
import org.contentauth.c2pa.FileStream
import org.contentauth.c2pa.KeyStoreSigner
import org.contentauth.c2pa.Signer
import org.contentauth.c2pa.SigningAlgorithm
import org.contentauth.c2pa.StrongBoxSigner
import org.contentauth.c2pa.manifest.ActionAssertion
import org.contentauth.c2pa.manifest.AssertionDefinition
import org.contentauth.c2pa.manifest.ClaimGeneratorInfo
import org.contentauth.c2pa.manifest.ManifestDefinition
import org.contentauth.c2pa.settings.BuilderSettingsDefinition
import org.contentauth.c2pa.settings.C2PASettingsDefinition
import org.contentauth.c2pa.settings.TrustSettings
import org.json.JSONObject
import java.io.File
import java.security.KeyStore

object C2paSigning {
    private const val C2PA_TSA_URL = "https://tsr.open-tsa.eu"

    private const val ANDROID_KEY_STORE_TYPE = "AndroidKeyStore"
    private const val ASSERTION_C2PA_METADATA = "c2pa.metadata"

    private const val SOFTWARE_SIGNER_KEY_ALIAS = "aves_gallery_software_key"
    private const val HARDWARE_SIGNER_KEY_ALIAS = "aves_gallery_hardware_key"

    // URI friendly name (i.e. no space)
    private const val MANIFEST_VENDOR = "aves_gallery"
    private const val COUNTRY = "FR"

    // to apply new config, remove/rename associated signer key alias
    private val LEAF_CERTIFICATE_CONFIG = CertificateManager.CertificateConfig(
        commonName = "Aves Gallery",
        organization = "Aves Gallery Self-Signed",
        organizationalUnit = "Mobile",
        country = COUNTRY,
    )

    @RequiresApi(Build.VERSION_CODES.P)
    fun sign(
        context: Context,
        contentAddress: ContentAddress,
        title: String,
        actions: List<String>,
    ): File? {
        val path = contentAddress.path ?: return null
        if (!File(path).exists()) throw Exception("file is missing at path=$path")

        val manifest = ManifestDefinition(
            format = contentAddress.mimeType,
            title = title,
            claimGeneratorInfo = listOf(ClaimGeneratorInfo.fromContext(context)),
            assertions = listOf(AssertionDefinition.actions(actions.map { ActionAssertion(it) })),
            vendor = MANIFEST_VENDOR,
        )

        val hasStrongBox = context.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
        val signer = if (hasStrongBox) createStrongBoxSigner(context) else createKeystoreSigner(context)

        val outputFile = StorageUtils.createTempFile(context)
        signStream(
            context = context,
            inputFile = File(path),
            outputFile = outputFile,
            manifest = manifest,
            signer = signer,
        )
        return outputFile
    }

    private fun signStream(
        context: Context,
        inputFile: File,
        outputFile: File,
        manifest: ManifestDefinition,
        signer: Signer,
    ) {
        val format = manifest.format ?: throw Exception("manifest format must be defined")
        val ingredientJson = JSONObject().apply {
            put("format", format)
            put("title", manifest.title)
            put("relationship", "parentOf")
        }

        val settingsDefinition = C2PASettingsDefinition(
            trust = TrustSettings(
                trustAnchors = C2paCommon.getTrustAnchors(context),
            ),
            builder = BuilderSettingsDefinition(
                createdAssertionLabels = Builder.DEFAULT_CREATED_ASSERTION_LABELS + listOf(ASSERTION_C2PA_METADATA)
            )
        )
        val builder = C2PASettings.fromDefinition(settingsDefinition).use { settings ->
            Builder.fromContext(C2PAContext.fromSettings(settings)).withDefinition(manifest.toJson())
        }

        FileStream(inputFile, FileStream.Mode.READ).use { sourceStream ->
            FileStream(outputFile, FileStream.Mode.WRITE).use { destStream ->
                signer.use { signer ->
                    builder.use { builder ->
                        builder.setIntent(BuilderIntent.Edit)
                        builder.addIngredient(ingredientJson.toString(), format, sourceStream)
                        builder.sign(
                            format = format,
                            source = sourceStream,
                            dest = destStream,
                            signer = signer,
                        )
                    }
                }
            }
        }
    }

    private fun createStrongBoxSigner(context: Context): Signer {
        val keyAlias = HARDWARE_SIGNER_KEY_ALIAS
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE_TYPE).apply { load(null) }

        val strongBoxConfig = StrongBoxSigner.Config(keyTag = keyAlias, requireUserAuthentication = false)
        if (!keyStore.containsAlias(keyAlias)) {
            try {
                StrongBoxSigner.createKey(strongBoxConfig)
            } catch (_: Exception) {
                // fallback to Trusted Execution Environment (TEE)
                BouncyHelper.createKeystoreKey(keyAlias, true)
            }
        }

        val certChain = getCertificateChain(context, keyAlias)

        return StrongBoxSigner.createSigner(
            algorithm = SigningAlgorithm.ES256,
            certificateChainPEM = certChain,
            config = strongBoxConfig,
            tsaURL = C2PA_TSA_URL
        )
    }

    private fun createKeystoreSigner(context: Context): Signer {
        val keyAlias = SOFTWARE_SIGNER_KEY_ALIAS
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE_TYPE).apply { load(null) }

        if (!keyStore.containsAlias(keyAlias)) {
            BouncyHelper.createKeystoreKey(keyAlias, false)
        }

        val certChain = getCertificateChain(context, keyAlias)

        return KeyStoreSigner.createSigner(
            algorithm = SigningAlgorithm.ES256,
            certificateChainPEM = certChain,
            keyAlias = keyAlias,
            tsaURL = C2PA_TSA_URL
        )
    }

    private fun getCertificateChain(context: Context, keyAlias: String): String {
        val certificateChainPem: String
        val fileCert = File(context.filesDir, "$keyAlias.cert")
        if (fileCert.exists()) {
            certificateChainPem = fileCert.readText()
        } else {
            val csrPEM = CertificateManager.createCSR(keyAlias, LEAF_CERTIFICATE_CONFIG)
            certificateChainPem = BouncyHelper.signCSR(csrPEM)
            fileCert.writeText(certificateChainPem)
        }
        return certificateChainPem
    }
}
