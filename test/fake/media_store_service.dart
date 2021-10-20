import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMediaStoreService extends Fake implements MediaStoreService {
  Set<AvesEntry> entries = {};

  @override
  Future<List<int>> checkObsoleteContentIds(List<int> knownContentIds) => SynchronousFuture([]);

  @override
  Future<List<int>> checkObsoletePaths(Map<int, String?> knownPathById) => SynchronousFuture([]);

  @override
  Stream<AvesEntry> getEntries(Map<int, int> knownEntries) => Stream.fromIterable(entries);

  static var _lastContentId = 1;

  static int get nextContentId => _lastContentId++;

  static int get dateSecs => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static AvesEntry newImage(String album, String filenameWithoutExtension) {
    final contentId = nextContentId;
    final date = dateSecs;
    return AvesEntry(
      uri: 'content://media/external/images/media/$contentId',
      contentId: contentId,
      path: '$album/$filenameWithoutExtension.jpg',
      pageId: null,
      sourceMimeType: MimeTypes.jpeg,
      width: 360,
      height: 720,
      sourceRotationDegrees: 0,
      sizeBytes: 42,
      sourceTitle: filenameWithoutExtension,
      dateModifiedSecs: date,
      sourceDateTakenMillis: date,
      durationMillis: null,
    );
  }

  static MoveOpEvent moveOpEventFor(AvesEntry entry, String sourceAlbum, String destinationAlbum) {
    final newContentId = nextContentId;
    return MoveOpEvent(
      success: true,
      uri: entry.uri,
      newFields: {
        'uri': 'content://media/external/images/media/$newContentId',
        'contentId': newContentId,
        'path': entry.path!.replaceFirst(sourceAlbum, destinationAlbum),
        'displayName': '${entry.filenameWithoutExtension}${entry.extension}',
        'title': entry.filenameWithoutExtension,
        'dateModifiedSecs': FakeMediaStoreService.dateSecs,
      },
    );
  }
}
