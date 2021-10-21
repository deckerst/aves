package deckers.thibault.aves.model

enum class NameConflictStrategy {
    RENAME, REPLACE, SKIP;

    companion object {
        fun get(name: String?): NameConflictStrategy? {
            name ?: return null
            return valueOf(name.uppercase())
        }
    }
}