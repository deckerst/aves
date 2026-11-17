// entry fields exported and imported from/to the platform side
// should match `EntryFields` on platform side
class EntryFields {
  static const id = 'id'; // int
  static const origin = 'origin'; // int
  static const uri = 'uri'; // string
  static const contentId = 'contentId'; // long
  static const path = 'path'; // string
  static const pageId = 'pageId'; // int
  static const mimeType = 'mimeType'; // string

  static const width = 'width'; // int
  static const height = 'height'; // int
  static const rotationDegrees = 'rotationDegrees'; // int
  static const isFlipped = 'isFlipped'; // boolean

  static const dateAddedSecs = 'dateAddedSecs'; // long
  static const dateModifiedMillis = 'dateModifiedMillis'; // long
  static const sourceDateTakenMillis = 'sourceDateTakenMillis'; // long
  static const durationMillis = 'durationMillis'; // long

  static const sizeBytes = 'sizeBytes'; // long
  static const trashed = 'trashed'; // boolean
  static const trashPath = 'trashPath'; // string
  static const title = 'title'; // string

  // catalog metadata
  static const dateMillis = 'dateMillis'; // long
  static const timeZoneOffsetMinutes = 'timeZoneOffsetMinutes'; // int
  static const flags = 'flags';
  static const latitude = 'latitude'; // double
  static const longitude = 'longitude'; // double
  static const rating = 'rating'; // int
  static const xmpSubjects = 'xmpSubjects'; // string
  static const xmpTitle = 'xmpTitle'; // string

  // overlay metadata
  static const aperture = 'aperture'; // double
  static const description = 'description'; // string
  static const exposureTime = 'exposureTime'; // string
  static const focalLength = 'focalLength'; // double
  static const iso = 'iso'; // int
}
