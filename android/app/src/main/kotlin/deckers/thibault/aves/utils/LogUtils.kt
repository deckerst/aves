package deckers.thibault.aves.utils

import java.util.regex.Pattern

object LogUtils {
    private const val LOG_TAG_MAX_LENGTH = 23
    private val LOG_TAG_PACKAGE_PATTERN = Pattern.compile("(\\w)(\\w*)\\.")

    // create an Android logger friendly log tag for the specified class
    fun createTag(clazz: Class<*>): String {
        // shorten class name to "a.b.CccDdd"
        var logTag = LOG_TAG_PACKAGE_PATTERN.matcher(clazz.name).replaceAll("$1.")
        if (logTag.length > LOG_TAG_MAX_LENGTH) {
            // shorten class name to "a.b.CD"
            val simpleName = clazz.simpleName
            val shortSimpleName = simpleName.replace("[a-z]".toRegex(), "")
            logTag = logTag.replace(simpleName, shortSimpleName)
            if (logTag.length > LOG_TAG_MAX_LENGTH) {
                // shorten class name to "CD"
                logTag = shortSimpleName
            }
        }
        return logTag
    }
}