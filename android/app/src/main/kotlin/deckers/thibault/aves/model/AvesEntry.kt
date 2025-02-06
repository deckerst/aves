package deckers.thibault.aves.model

import android.net.Uri
import androidx.core.net.toUri

class AvesEntry(map: FieldMap) {
    val uri: Uri = (map[EntryFields.URI] as String).toUri() // content or file URI
    val path = map[EntryFields.PATH] as String? // best effort to get local path
    val pageId = map[EntryFields.PAGE_ID] as Int? // null means the main entry
    val mimeType = map[EntryFields.MIME_TYPE] as String
    val width = map[EntryFields.WIDTH] as Int
    val height = map[EntryFields.HEIGHT] as Int
    val rotationDegrees = map[EntryFields.ROTATION_DEGREES] as Int
    val isFlipped = map[EntryFields.IS_FLIPPED] as Boolean
    val sizeBytes = toLong(map[EntryFields.SIZE_BYTES])
    val trashed = map[EntryFields.TRASHED] as Boolean
    val trashPath = map[EntryFields.TRASH_PATH] as String?

    private val isRotated: Boolean
        get() = rotationDegrees % 180 == 90

    val displayWidth: Int
        get() = if (isRotated) height else width

    val displayHeight: Int
        get() = if (isRotated) width else height

    companion object {
        // convenience method
        private fun toLong(o: Any?): Long? = when (o) {
            is Int -> o.toLong()
            else -> o as? Long
        }
    }
}