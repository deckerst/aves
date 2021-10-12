package deckers.thibault.aves.utils

object LogUtils {
    const val LOG_TAG_MAX_LENGTH = 23

    val LOG_TAG_PACKAGE_PATTERN = Regex("(\\w)(\\w*)\\.")
    val LOWER_CASE_PATTERN = Regex("[a-z]")

    // create an Android logger friendly log tag for the specified class
    inline fun <reified T> createTag(): String {
        val kClass = T::class
        // shorten class name to "a.b.CccDdd"
        var logTag = LOG_TAG_PACKAGE_PATTERN.replace(kClass.qualifiedName!!, "$1.")
        if (logTag.length > LOG_TAG_MAX_LENGTH) {
            // shorten class name to "a.b.CD"
            val simpleName = kClass.simpleName!!
            val shortSimpleName = simpleName.replace(LOWER_CASE_PATTERN, "")
            logTag = logTag.replace(simpleName, shortSimpleName)
            if (logTag.length > LOG_TAG_MAX_LENGTH) {
                // shorten class name to "CD"
                logTag = shortSimpleName
            }
        }
        return logTag
    }
}