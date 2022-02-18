package deckers.thibault.aves.model

import android.net.Uri

class AvesEntry(map: FieldMap) {
    val uri: Uri = Uri.parse(map["uri"] as String) // content or file URI
    val path = map["path"] as String? // best effort to get local path
    val pageId = map["pageId"] as Int? // null means the main entry
    val mimeType = map["mimeType"] as String
    val width = map["width"] as Int
    val height = map["height"] as Int
    val rotationDegrees = map["rotationDegrees"] as Int
    val isFlipped = map["isFlipped"] as Boolean
    val trashed = map["trashed"] as Boolean
    val trashPath = map["trashPath"] as String?
}