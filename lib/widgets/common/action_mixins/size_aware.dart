import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

mixin SizeAwareMixin {
  Future<bool> checkFreeSpaceForMove(
    BuildContext context,
    Set<AvesEntry> selection,
    String destinationAlbum,
    MoveType moveType,
  ) async {
    if (moveType == MoveType.toBin) return true;

    // assume we have enough space if we cannot find the volume or its remaining free space
    final destinationVolume = androidFileUtils.getStorageVolume(destinationAlbum);
    if (destinationVolume == null) return true;

    final free = await storageService.getFreeSpace(destinationVolume);
    if (free == null) return true;

    late int needed;
    int sumSize(int sum, AvesEntry entry) => sum + (entry.sizeBytes ?? 0);
    switch (moveType) {
      case MoveType.copy:
      case MoveType.export:
        needed = selection.fold(0, sumSize);
      case MoveType.move:
      case MoveType.toBin:
      case MoveType.fromBin:
        // when moving, we only need space for the entries that are not already on the destination volume
        final byVolume = groupBy<AvesEntry, StorageVolume?>(selection, (entry) => androidFileUtils.getStorageVolume(entry.path)).whereNotNullKey();
        final otherVolumes = byVolume.keys.where((volume) => volume != destinationVolume);
        final fromOtherVolumes = otherVolumes.fold<int>(0, (sum, volume) => sum + byVolume[volume]!.fold(0, sumSize));
        // and we need at least as much space as the largest entry because individual entries are copied then deleted
        final largestSingle = selection.fold<int>(0, (largest, entry) => max(largest, entry.sizeBytes ?? 0));
        needed = max(fromOtherVolumes, largestSingle);
    }

    final hasEnoughSpace = needed < free;
    if (!hasEnoughSpace) {
      await _showNotEnoughSpaceDialog(context, needed, free, destinationVolume);
    }
    return hasEnoughSpace;
  }

  Future<bool> checkFreeSpace(
    BuildContext context,
    int needed,
    String destinationAlbum,
  ) async {
    // assume we have enough space if we cannot find the volume or its remaining free space
    final destinationVolume = androidFileUtils.getStorageVolume(destinationAlbum);
    if (destinationVolume == null) return true;

    final free = await storageService.getFreeSpace(destinationVolume);
    if (free == null) return true;

    final hasEnoughSpace = needed < free;
    if (!hasEnoughSpace) {
      await _showNotEnoughSpaceDialog(context, needed, free, destinationVolume);
    }
    return hasEnoughSpace;
  }

  Future<void> _showNotEnoughSpaceDialog(BuildContext context, int needed, int free, StorageVolume destinationVolume) async {
    await showDialog(
      context: context,
      builder: (context) {
        final locale = context.locale;
        final neededSize = formatFileSize(locale, needed);
        final freeSize = formatFileSize(locale, free);
        final volume = destinationVolume.getDescription(context);
        return AvesDialog(
          content: Text(context.l10n.notEnoughSpaceDialogMessage(neededSize, freeSize, volume)),
          actions: const [OkButton()],
        );
      },
      routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
    );
  }
}
