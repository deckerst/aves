package deckers.thibault.aves.metadata.c2pa

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import deckers.thibault.aves.utils.TimeUtils
import org.bouncycastle.asn1.x500.X500Name
import org.bouncycastle.asn1.x509.BasicConstraints
import org.bouncycastle.asn1.x509.ExtendedKeyUsage
import org.bouncycastle.asn1.x509.Extension
import org.bouncycastle.asn1.x509.KeyPurposeId
import org.bouncycastle.asn1.x509.KeyUsage
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo
import org.bouncycastle.cert.X509v3CertificateBuilder
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter
import org.bouncycastle.cert.jcajce.JcaX509ExtensionUtils
import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder
import org.bouncycastle.pkcs.PKCS10CertificationRequest
import org.bouncycastle.util.io.pem.PemObject
import org.bouncycastle.util.io.pem.PemReader
import org.bouncycastle.util.io.pem.PemWriter
import java.io.StringReader
import java.io.StringWriter
import java.math.BigInteger
import java.security.KeyFactory
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.PrivateKey
import java.security.PublicKey
import java.security.Security
import java.security.cert.X509Certificate
import java.security.spec.ECGenParameterSpec
import java.security.spec.X509EncodedKeySpec
import java.util.Date
import javax.security.auth.x500.X500Principal
import kotlin.time.Clock

object BouncyHelper {
    private const val ANDROID_KEY_STORE_PROVIDER = "AndroidKeyStore"
    private const val EC_P256_STANDARD_NAME = "secp256r1"
    private const val PEM_TYPE_CERTIFICATE = "CERTIFICATE"

    private const val KEYSTORE_VALIDITY_MILLIS = TimeUtils.YEAR_IN_MILLIS
    private const val ROOT_CERTIFICATE_VALIDITY_DAYS = TimeUtils.DAYS_PER_YEAR * 10
    private const val INTERMEDIATE_CERTIFICATE_VALIDITY_DAYS = TimeUtils.DAYS_PER_YEAR * 5
    private const val LEAF_CERTIFICATE_VALIDITY_DAYS = TimeUtils.DAYS_PER_YEAR

    private const val COUNTRY = "FR"
    private const val KEYSTORE_X500_NAME = "CN=Android User, O=Self-Signed, C=$COUNTRY"
    private const val ROOT_CA_X500_NAME = "CN=Aves C2PA Root CA, O=C2PA Signing Server, OU=Certificate Authority, C=${COUNTRY}"
    private const val INTERMEDIATE_CA_X500_NAME = "CN=Aves C2PA Intermediate CA, O=C2PA Signing Server, OU=Certificate Authority, C=${COUNTRY}"

    fun createKeystoreKey(alias: String, useHardware: Boolean) {
        val keyGenSpec = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY,
        ).apply {
            setAlgorithmParameterSpec(ECGenParameterSpec(EC_P256_STANDARD_NAME))
            setDigests(KeyProperties.DIGEST_SHA256)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                setIsStrongBoxBacked(useHardware)
            }

            val nowMillis = Clock.System.now().toEpochMilliseconds()
            setCertificateNotBefore(Date())
            setCertificateNotAfter(Date(nowMillis + KEYSTORE_VALIDITY_MILLIS))
            setCertificateSerialNumber(BigInteger.valueOf(nowMillis))
            setCertificateSubject(X500Principal(KEYSTORE_X500_NAME))
        }.build()

        KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, ANDROID_KEY_STORE_PROVIDER).apply {
            initialize(keyGenSpec)
            generateKeyPair()
        }
    }

    // returns certificate chain
    fun signCSR(csrPEM: String): String {
        Security.addProvider(BouncyCastleProvider())

        // root CA
        val rootKeyPair = generateKeyPair()
        val rootCAPrivateKey = rootKeyPair.private
        val rootCASubject = X500Name(ROOT_CA_X500_NAME)
        val rootCA = generateCertificate(
            subject = rootCASubject,
            issuer = rootCASubject,
            publicKey = rootKeyPair.public,
            signerKey = rootCAPrivateKey,
            isCA = true,
            pathLenConstraint = 1,
            validityDays = ROOT_CERTIFICATE_VALIDITY_DAYS,
        )

        // intermediate CA
        val intermediateKeyPair = generateKeyPair()
        val intermediateCAPrivateKey = intermediateKeyPair.private
        val intermediateCASubject = X500Name(INTERMEDIATE_CA_X500_NAME)
        val intermediateCA = generateCertificate(
            subject = intermediateCASubject,
            issuer = X500Name(rootCA.subjectX500Principal.name),
            publicKey = intermediateKeyPair.public,
            signerKey = rootCAPrivateKey,
            isCA = true,
            pathLenConstraint = 0,
            validityDays = INTERMEDIATE_CERTIFICATE_VALIDITY_DAYS,
        )

        // leaf certificate
        val csrPemObject = PemReader(StringReader(csrPEM)).use { it.readPemObject() }
        val csr = PKCS10CertificationRequest(csrPemObject.content)
        val csrPublicKeySpec = X509EncodedKeySpec(csr.subjectPublicKeyInfo.encoded)
        val csrPublicKey = KeyFactory.getInstance(KeyProperties.KEY_ALGORITHM_EC).generatePublic(csrPublicKeySpec)
        val leafCertificate = generateCertificate(
            subject = csr.subject,
            issuer = X500Name(intermediateCA.subjectX500Principal.name),
            publicKey = csrPublicKey,
            signerKey = intermediateCAPrivateKey,
            isCA = false,
            pathLenConstraint = null,
            validityDays = LEAF_CERTIFICATE_VALIDITY_DAYS,
        )

        val certificateChain = listOf(leafCertificate, intermediateCA, rootCA).joinToString("\n", transform = ::toPem)
        return certificateChain
    }

    private fun generateCertificate(
        subject: X500Name,
        issuer: X500Name,
        publicKey: PublicKey,
        signerKey: PrivateKey,
        isCA: Boolean,
        pathLenConstraint: Int?,
        validityDays: Int,
    ): X509Certificate {
        val isSelfSigned = issuer == subject
        val nowMillis = Clock.System.now().toEpochMilliseconds()

        val certBuilder = X509v3CertificateBuilder(
            issuer,
            BigInteger.valueOf(nowMillis),
            Date(nowMillis - TimeUtils.MINUTE_IN_MILLIS * 5), // prevent clock skew issues
            Date(nowMillis + validityDays * TimeUtils.DAY_IN_MILLIS),
            subject,
            SubjectPublicKeyInfo.getInstance(publicKey.encoded),
        )

        val extensionUtils = JcaX509ExtensionUtils()
        certBuilder.addExtension(
            Extension.subjectKeyIdentifier,
            false,
            extensionUtils.createSubjectKeyIdentifier(publicKey),
        )
        if (!isSelfSigned) {
            certBuilder.addExtension(
                Extension.authorityKeyIdentifier,
                false,
                extensionUtils.createAuthorityKeyIdentifier(publicKey),
            )
        }
        certBuilder.addExtension(
            Extension.basicConstraints,
            true,
            if (pathLenConstraint != null) BasicConstraints(pathLenConstraint) else BasicConstraints(false),
        )
        certBuilder.addExtension(
            Extension.keyUsage,
            true,
            KeyUsage(if (isCA) KeyUsage.keyCertSign or KeyUsage.cRLSign else KeyUsage.digitalSignature),
        )
        if (!isCA) {
            certBuilder.addExtension(
                Extension.extendedKeyUsage,
                false,
                ExtendedKeyUsage(listOf(KeyPurposeId.id_kp_emailProtection).toTypedArray()),
            )
        }

        val contentSigner = JcaContentSignerBuilder("SHA256withECDSA").build(signerKey)
        val certHolder = certBuilder.build(contentSigner)
        val certificate = JcaX509CertificateConverter().getCertificate(certHolder)
        return certificate
    }

    private fun generateKeyPair(): KeyPair {
        return KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC).apply {
            initialize(ECGenParameterSpec(EC_P256_STANDARD_NAME))
        }.generateKeyPair()
    }

    private fun toPem(certificate: X509Certificate): String {
        return StringWriter().use { writer ->
            PemWriter(writer).use {
                it.writeObject(PemObject(PEM_TYPE_CERTIFICATE, certificate.encoded))
            }
            writer.toString()
        }
    }
}