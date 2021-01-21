package deckers.thibault.aves.model

import android.net.Uri
import deckers.thibault.aves.model.provider.FieldMap

class AvesEntry(map: FieldMap) {
    val uri: Uri = Uri.parse(map["uri"] as String) // content or file URI
    val path = map["path"] as String? // best effort to get local path
    val mimeType = map["mimeType"] as String
    val width = map["width"] as Int
    val height = map["height"] as Int
    val rotationDegrees = map["rotationDegrees"] as Int
}