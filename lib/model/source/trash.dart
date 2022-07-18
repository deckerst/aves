import 'dart:async';

import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';

mixin TrashMixin on SourceBase {
  static const Duration binKeepDuration = Duration(days: 30);

  Future<void> loadTrashDetails() async {
    final saved = await metadataDb.loadAllTrashDetails();
    final idMap = entryById;
    saved.forEach((details) => idMap[details.id]?.trashDetails = details);
  }

  Future<Set<String>> deleteExpiredTrash() async {
    final expiredEntries = trashedEntries.where((entry) => entry.isExpiredTrash).toSet();
    if (expiredEntries.isEmpty) return {};

    final processed = <ImageOpEvent>{};
    final completer = Completer<Set<String>>();
    mediaEditService.delete(entries: expiredEntries).listen(
      processed.add,
      onError: completer.completeError,
      onDone: () async {
        final successOps = processed.where((e) => e.success).toSet();
        final deletedOps = successOps.where((e) => !e.skipped).toSet();
        final deletedUris = deletedOps.map((event) => event.uri).toSet();
        completer.complete(deletedUris);
      },
    );
    return await completer.future;
  }
}
