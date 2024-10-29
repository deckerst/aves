import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TrashMixin on SourceBase {
  static const Duration binKeepDuration = Duration(days: 30);

  Future<void> loadTrashDetails() async {
    final saved = await localMediaDb.loadAllTrashDetails();
    final idMap = entryById;
    saved.forEach((details) => idMap[details.id]?.trashDetails = details);
  }

  Future<Set<String>> deleteExpiredTrash() async {
    final expiredEntries = trashedEntries.where((entry) => entry.isExpiredTrash).toSet();
    if (expiredEntries.isEmpty) return {};

    final processed = <ImageOpEvent>{};
    final opCompleter = Completer<Set<String>>();
    mediaEditService.delete(entries: expiredEntries).listen(
      processed.add,
      onError: opCompleter.completeError,
      onDone: () async {
        final successOps = processed.where((e) => e.success).toSet();
        final deletedOps = successOps.where((e) => !e.skipped).toSet();
        final deletedUris = deletedOps.map((event) => event.uri).toSet();
        opCompleter.complete(deletedUris);
      },
    );
    return await opCompleter.future;
  }

  Future<Set<AvesEntry>> recoverUntrackedTrashItems() async {
    final newEntries = <AvesEntry>{};

    final knownPaths = allEntries.map((v) => v.trashDetails?.path).nonNulls.toSet();
    final untrackedPaths = await storageService.getUntrackedTrashPaths(knownPaths);
    if (untrackedPaths.isNotEmpty) {
      debugPrint('Recovering ${untrackedPaths.length} untracked bin items');
      final recoveryPath = pContext.join(androidFileUtils.picturesPath, AndroidFileUtils.recoveryDir);
      await Future.forEach(untrackedPaths, (untrackedPath) async {
        TrashDetails _buildTrashDetails(int id) => TrashDetails(
              id: id,
              path: untrackedPath,
              dateMillis: DateTime.now().millisecondsSinceEpoch,
            );

        final uri = Uri.file(untrackedPath).toString();
        final entry = allEntries.firstWhereOrNull((v) => v.uri == uri);
        if (entry != null) {
          // there is already a matching entry
          // but missing trash details, and possibly not marked as trash
          final id = entry.id;
          entry.contentId = null;
          entry.trashed = true;
          entry.trashDetails = _buildTrashDetails(id);
          // persist
          await localMediaDb.updateEntry(id, entry);
          await localMediaDb.updateTrash(id, entry.trashDetails);
        } else {
          // there is no matching entry
          final sourceEntry = await mediaFetchService.getEntry(uri, null, allowUnsized: true);
          if (sourceEntry != null) {
            final id = localMediaDb.nextId;
            sourceEntry.id = id;
            sourceEntry.path = pContext.join(recoveryPath, pContext.basename(untrackedPath));
            sourceEntry.trashed = true;
            sourceEntry.trashDetails = _buildTrashDetails(id);
            newEntries.add(sourceEntry);
          } else {
            await reportService.recordError('Failed to recover untracked bin item at uri=$uri', null);
          }
        }
      });
    }
    return newEntries;
  }
}
