import 'package:aves/model/entry.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/media/media_file_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'media_store_service.dart';

class FakeMediaFileService extends Fake implements MediaFileService {
  @override
  Stream<MoveOpEvent> rename(
    Iterable<AvesEntry> entries, {
    required String newName,
  }) {
    final contentId = FakeMediaStoreService.nextContentId;
    final entry = entries.first;
    return Stream.value(MoveOpEvent(
      success: true,
      skipped: false,
      uri: entry.uri,
      newFields: {
        'uri': 'content://media/external/images/media/$contentId',
        'contentId': contentId,
        'path': '${entry.directory}/$newName',
        'displayName': newName,
        'title': newName.substring(0, newName.length - entry.extension!.length),
        'dateModifiedSecs': FakeMediaStoreService.dateSecs,
      },
    ));
  }
}
