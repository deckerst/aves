package deckers.thibault.aves.model

import java.io.File

enum class NameConflictStrategy {
    RENAME, REPLACE, SKIP;

    companion object {
        fun get(name: String?): NameConflictStrategy? {
            name ?: return null
            return valueOf(name.uppercase())
        }
    }
}

class NameConflictResolution(var nameWithoutExtension: String?, var replacementFile: File?)