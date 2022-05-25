import 'package:aves/model/entry.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/media/media_file_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'media_store_service.dart';

class FakeMediaFileService extends Fake implements MediaFileService {
  @override
  Stream<MoveOpEvent> rename({
    String? opId,
    required Map<AvesEntry, String> entriesToNewName,
  }) {
    final contentId = FakeMediaStoreService.nextId;
    final kv = entriesToNewName.entries.first;
    final entry = kv.key;
    final newName = kv.value;
    return Stream.value(MoveOpEvent(
      success: true,
      skipped: false,
      uri: entry.uri,
      newFields: {
        'uri': 'content://media/external/images/media/$contentId',
        'contentId': contentId,
        'path': '${entry.directory}/$newName',
        'dateModifiedSecs': FakeMediaStoreService.dateSecs,
      },
      deleted: false,
    ));
  }
}
