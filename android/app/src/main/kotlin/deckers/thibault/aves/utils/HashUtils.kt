package deckers.thibault.aves.utils

import java.io.InputStream
import java.math.BigInteger
import java.security.MessageDigest

object HashUtils {
    fun getHash(input: InputStream, algorithmKey: String): String {
        val algorithm = toMessageDigestAlgorithm(algorithmKey)
        val digest = MessageDigest.getInstance(algorithm)
        val buffer = ByteArray(1 shl 14)
        var read: Int
        while ((input.read(buffer).also { read = it }) > 0) {
            digest.update(buffer, 0, read)
        }
        val md5sum = digest.digest()
        val output = BigInteger(1, md5sum).toString(16)

        return when (algorithm) {
            "MD5" -> output.padStart(32, '0') // 128 bits = 32 hex digits
            "SHA-1" -> output.padStart(40, '0') // 160 bits = 40 hex digits
            "SHA-256" -> output.padStart(64, '0') // 256 bits = 64 hex digits
            else -> throw IllegalArgumentException("unsupported hash algorithm: $algorithmKey")
        }
    }

    private fun toMessageDigestAlgorithm(algorithmKey: String): String {
        return when (algorithmKey) {
            "md5" -> "MD5"
            "sha1" -> "SHA-1"
            "sha256" -> "SHA-256"
            else -> throw IllegalArgumentException("unsupported hash algorithm: $algorithmKey")
        }
    }
}
