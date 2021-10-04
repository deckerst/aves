package deckers.thibault.aves.model

enum class NameConflictStrategy {
    SKIP, REPLACE, RENAME;

    companion object {
        fun get(name: String?): NameConflictStrategy? {
            name ?: return null
            return valueOf(name.uppercase())
        }
    }
}