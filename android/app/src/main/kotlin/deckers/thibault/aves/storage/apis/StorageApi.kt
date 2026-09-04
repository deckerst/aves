package deckers.thibault.aves.storage.apis

enum class StorageApi {
    FILE, MEDIA_STORE, SAF;

    fun getPermissionDelegate(): StoragePermissions {
        return when (this) {
            FILE -> FilePermissions
            MEDIA_STORE -> MediaStorePermissions
            SAF -> SafPermissions
        }
    }

    fun toKey(): String {
        return when (this) {
            FILE -> "file"
            MEDIA_STORE -> "mediaStore"
            SAF -> "saf"
        }
    }

    companion object {
        fun fromKey(key: String?): StorageApi? {
            return when (key) {
                "file" -> FILE
                "mediaStore" -> MEDIA_STORE
                "saf" -> SAF
                else -> null
            }
        }
    }
}