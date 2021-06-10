import 'package:aves/model/entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'media_store_service.dart';

class FakeImageFileService extends Fake implements ImageFileService {
  @override
  Future<Map<String, dynamic>> rename(AvesEntry entry, String newName) {
    final contentId = FakeMediaStoreService.nextContentId;
    return SynchronousFuture({
      'uri': 'content://media/external/images/media/$contentId',
      'contentId': contentId,
      'path': '${entry.directory}/$newName',
      'displayName': newName,
      'title': newName.substring(0, newName.length - entry.extension!.length),
      'dateModifiedSecs': FakeMediaStoreService.dateSecs,
    });
  }
}
