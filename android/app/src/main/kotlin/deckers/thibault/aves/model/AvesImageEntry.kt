package deckers.thibault.aves.model

import android.net.Uri

class AvesImageEntry(map: Map<String?, Any?>) {
    @JvmField
    val uri: Uri = Uri.parse(map["uri"] as String) // content or file URI

    @JvmField
    val path = map["path"] as String? // best effort to get local path

    @JvmField
    val mimeType = map["mimeType"] as String

    @JvmField
    val width = map["width"] as Int

    @JvmField
    val height = map["height"] as Int

    @JvmField
    val rotationDegrees = map["rotationDegrees"] as Int
}