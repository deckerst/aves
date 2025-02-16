import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/keys.dart';
import 'package:aves/model/entry/origins.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:test/fake.dart';

class FakeMediaStoreService extends Fake implements MediaStoreService {
  late Set<AvesEntry> entries;
  Duration? latency;

  void reset() {
    entries = {};
    latency = null;
  }

  @override
  Future<List<int>> checkObsoleteContentIds(List<int?> knownContentIds) async {
    if (latency != null) await Future.delayed(latency!);
    return [];
  }

  @override
  Future<List<int>> checkObsoletePaths(Map<int?, String?> knownPathById) async {
    if (latency != null) await Future.delayed(latency!);
    return [];
  }

  @override
  Future<int?> getGeneration() async {
    if (latency != null) await Future.delayed(latency!);
    return 0;
  }

  @override
  Stream<AvesEntry> getEntries(Map<int?, int?> knownEntries, {String? directory}) => Stream.fromIterable(entries);

  static var _lastId = 1;

  static int get nextId => _lastId++;

  static int get dateMillis => DateTime.now().millisecondsSinceEpoch;

  static AvesEntry newImage(String album, String filenameWithoutExtension, {int? id, int? contentId}) {
    id ??= nextId;
    contentId ??= id;
    final _dateMillis = dateMillis;
    final _dateSecs = _dateMillis ~/ 1000;
    return AvesEntry(
      origin: EntryOrigins.mediaStoreContent,
      id: id,
      uri: 'content://media/external/images/media/$contentId',
      path: '$album/$filenameWithoutExtension.jpg',
      contentId: contentId,
      pageId: null,
      sourceMimeType: MimeTypes.jpeg,
      width: 360,
      height: 720,
      sourceRotationDegrees: 0,
      sizeBytes: 42,
      sourceTitle: filenameWithoutExtension,
      dateAddedSecs: _dateSecs,
      dateModifiedMillis: _dateMillis,
      sourceDateTakenMillis: _dateMillis,
      durationMillis: null,
      trashed: false,
    );
  }

  static MoveOpEvent moveOpEventForMove(AvesEntry entry, String sourceAlbum, String destinationAlbum) {
    final newContentId = nextId;
    return MoveOpEvent(
      success: true,
      skipped: false,
      uri: entry.uri,
      newFields: {
        EntryFields.uri: 'content://media/external/images/media/$newContentId',
        EntryFields.contentId: newContentId,
        EntryFields.path: entry.path!.replaceFirst(sourceAlbum, destinationAlbum),
        EntryFields.dateModifiedMillis: FakeMediaStoreService.dateMillis,
      },
      deleted: false,
    );
  }

  static MoveOpEvent moveOpEventForRename(AvesEntry entry, String newName) {
    final newContentId = nextId;
    final oldName = entry.filenameWithoutExtension!;
    return MoveOpEvent(
      success: true,
      skipped: false,
      uri: entry.uri,
      newFields: {
        EntryFields.uri: 'content://media/external/images/media/$newContentId',
        EntryFields.contentId: newContentId,
        EntryFields.path: entry.path!.replaceFirst(oldName, newName),
        EntryFields.dateModifiedMillis: FakeMediaStoreService.dateMillis,
      },
      deleted: false,
    );
  }
}
