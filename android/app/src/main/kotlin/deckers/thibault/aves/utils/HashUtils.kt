package deckers.thibault.aves.utils

import java.io.InputStream
import java.math.BigInteger
import java.security.MessageDigest

object HashUtils {
    fun getHash(input: InputStream, algorithm: HashAlgorithm): String {
        val digest = MessageDigest.getInstance(algorithm.toMessageDigestAlgorithm())
        val buffer = ByteArray(1 shl 14)
        var read: Int
        while ((input.read(buffer).also { read = it }) > 0) {
            digest.update(buffer, 0, read)
        }
        val md5sum = digest.digest()
        val output = BigInteger(1, md5sum).toString(16)

        return when (algorithm) {
            HashAlgorithm.MD5 -> output.padStart(32, '0') // 128 bits = 32 hex digits
            HashAlgorithm.SHA1 -> output.padStart(40, '0') // 160 bits = 40 hex digits
            HashAlgorithm.SHA256 -> output.padStart(64, '0') // 256 bits = 64 hex digits
        }
    }
}

enum class HashAlgorithm {
    MD5, SHA1, SHA256;

    fun toMessageDigestAlgorithm(): String {
        return when (this) {
            MD5 -> "MD5"
            SHA1 -> "SHA-1"
            SHA256 -> "SHA-256"
        }
    }

    companion object {
        fun fromKey(name: String?): HashAlgorithm? {
            name ?: return null
            return HashAlgorithm.valueOf(name.uppercase())
        }
    }
}