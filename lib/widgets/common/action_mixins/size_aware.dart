import 'dart:async';
import 'dart:math';

import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

mixin SizeAwareMixin {
  Future<bool> checkFreeSpaceForMove(
    BuildContext context,
    Set<AvesEntry > selection,
    String destinationAlbum,
    MoveType moveType,
  ) async {
    // assume we have enough space if we cannot find the volume or its remaining free space
    final destinationVolume = androidFileUtils.getStorageVolume(destinationAlbum);
    if (destinationVolume == null) return true;

    final free = await storageService.getFreeSpace(destinationVolume);
    if (free == null) return true;

    late int needed;
    int sumSize(sum, entry) => sum + entry.sizeBytes ?? 0;
    switch (moveType) {
      case MoveType.copy:
      case MoveType.export:
        needed = selection.fold(0, sumSize);
        break;
      case MoveType.move:
        // when moving, we only need space for the entries that are not already on the destination volume
        final byVolume = Map.fromEntries(groupBy<AvesEntry, StorageVolume?>(selection, (entry) => androidFileUtils.getStorageVolume(entry.path)).entries.where((kv) => kv.key != null).cast<MapEntry<StorageVolume, List<AvesEntry>>>());
        final otherVolumes = byVolume.keys.where((volume) => volume != destinationVolume);
        final fromOtherVolumes = otherVolumes.fold<int>(0, (sum, volume) => sum + byVolume[volume]!.fold(0, sumSize));
        // and we need at least as much space as the largest entry because individual entries are copied then deleted
        final largestSingle = selection.fold<int>(0, (largest, entry) => max(largest, entry.sizeBytes ?? 0));
        needed = max(fromOtherVolumes, largestSingle);
        break;
    }

    final hasEnoughSpace = needed < free;
    if (!hasEnoughSpace) {
      await showDialog(
        context: context,
        builder: (context) {
          final neededSize = formatFilesize(needed);
          final freeSize = formatFilesize(free);
          final volume = destinationVolume.getDescription(context);
          return AvesDialog(
            context: context,
            title: context.l10n.notEnoughSpaceDialogTitle,
            content: Text(context.l10n.notEnoughSpaceDialogMessage(neededSize, freeSize, volume)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
        },
      );
    }
    return hasEnoughSpace;
  }
}
