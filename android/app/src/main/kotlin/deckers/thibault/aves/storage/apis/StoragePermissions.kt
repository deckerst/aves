package deckers.thibault.aves.storage.apis

import android.content.Context

interface StoragePermissions {
    // returns whether it is possible to use this API to edit media files in the provided directory,
    // possibly requiring user interaction to provide explicit access grants
    fun canEditWithUserInteraction(context: Context, dirPath: String, insertion: Boolean): Boolean
}