// entry fields exported and imported from/to the platform side
// should match `EntryFields` on platform side
class EntryFields {
  static const id = 'id'; // int
  static const origin = 'origin'; // int
  static const uri = 'uri'; // string
  static const contentId = 'contentId'; // long
  static const path = 'path'; // string
  static const pageId = 'pageId'; // int
  static const sourceMimeType = 'sourceMimeType'; // string
  static const mimeType = 'mimeType'; // string

  static const width = 'width'; // int
  static const height = 'height'; // int
  static const sourceRotationDegrees = 'sourceRotationDegrees'; // int
  static const rotationDegrees = 'rotationDegrees'; // int
  static const isFlipped = 'isFlipped'; // boolean

  static const dateAddedSecs = 'dateAddedSecs'; // long
  static const dateModifiedSecs = 'dateModifiedSecs'; // long
  static const sourceDateTakenMillis = 'sourceDateTakenMillis'; // long
  static const durationMillis = 'durationMillis'; // long

  static const sizeBytes = 'sizeBytes'; // long
  static const trashed = 'trashed'; // boolean
  static const trashPath = 'trashPath'; // string
  static const title = 'title'; // string
}
