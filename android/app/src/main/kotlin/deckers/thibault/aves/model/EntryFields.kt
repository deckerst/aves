package deckers.thibault.aves.model

// entry fields exported and imported from/to the platform side
// should match `EntryFields` on Dart side
object EntryFields {
    const val ORIGIN = "origin" // int
    const val URI = "uri" // string
    const val CONTENT_ID = "contentId" // long
    const val PATH = "path" // string
    const val PAGE_ID = "pageId" // int
    const val MIME_TYPE = "mimeType" // string

    const val WIDTH = "width" // int
    const val HEIGHT = "height" // int
    const val ROTATION_DEGREES = "rotationDegrees" // int
    const val IS_FLIPPED = "isFlipped" // boolean

    const val DATE_ADDED_SECS = "dateAddedSecs" // long
    const val DATE_MODIFIED_MILLIS = "dateModifiedMillis" // long
    const val SOURCE_DATE_TAKEN_MILLIS = "sourceDateTakenMillis" // long
    const val DURATION_MILLIS = "durationMillis" // long

    const val SIZE_BYTES = "sizeBytes" // long
    const val TRASHED = "trashed" // boolean
    const val TRASH_PATH = "trashPath" // string
    const val TITLE = "title" // string

    // catalog metadata
    const val DATE_MILLIS = "dateMillis"
    const val TIME_ZONE_OFFSET_MINUTES = "timeZoneOffsetMinutes"
    const val FLAGS = "flags"
    const val LATITUDE = "latitude"
    const val LONGITUDE = "longitude"
    const val RATING = "rating"
    const val XMP_SUBJECTS = "xmpSubjects"
    const val XMP_TITLE = "xmpTitle"

    // overlay metadata
    const val APERTURE = "aperture"
    const val DESCRIPTION = "description"
    const val EXPOSURE_TIME = "exposureTime"
    const val FOCAL_LENGTH = "focalLength"
    const val ISO = "iso"
}