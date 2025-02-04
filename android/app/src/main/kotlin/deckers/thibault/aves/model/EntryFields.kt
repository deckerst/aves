package deckers.thibault.aves.model

// entry fields exported and imported from/to the platform side
// should match `EntryFields` on Dart side
object EntryFields {
    const val ORIGIN = "origin" // int
    const val URI = "uri" // string
    const val CONTENT_ID = "contentId" // long
    const val PATH = "path" // string
    const val PAGE_ID = "pageId" // int
    const val SOURCE_MIME_TYPE = "sourceMimeType" // string
    const val MIME_TYPE = "mimeType" // string

    const val WIDTH = "width" // int
    const val HEIGHT = "height" // int
    const val SOURCE_ROTATION_DEGREES = "sourceRotationDegrees" // int
    const val ROTATION_DEGREES = "rotationDegrees" // int
    const val IS_FLIPPED = "isFlipped" // boolean

    const val DATE_ADDED_SECS = "dateAddedSecs" // long
    const val DATE_MODIFIED_SECS = "dateModifiedSecs" // long
    const val SOURCE_DATE_TAKEN_MILLIS = "sourceDateTakenMillis" // long
    const val DURATION_MILLIS = "durationMillis" // long

    const val SIZE_BYTES = "sizeBytes" // long
    const val TRASHED = "trashed" // boolean
    const val TRASH_PATH = "trashPath" // string
    const val TITLE = "title" // string
}