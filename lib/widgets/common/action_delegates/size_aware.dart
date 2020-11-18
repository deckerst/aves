import 'dart:async';
import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/aves_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

mixin SizeAwareMixin {
  Future<bool> checkFreeSpaceForMove(BuildContext context, List<ImageEntry> selection, String destinationAlbum, bool copy) async {
    final destinationVolume = androidFileUtils.getStorageVolume(destinationAlbum);
    final free = await AndroidFileService.getFreeSpace(destinationVolume);
    int needed;
    int sumSize(sum, entry) => sum + entry.sizeBytes;
    if (copy) {
      needed = selection.fold(0, sumSize);
    } else {
      // when moving, we only need space for the entries that are not already on the destination volume
      final byVolume = groupBy<ImageEntry, StorageVolume>(selection, (entry) => androidFileUtils.getStorageVolume(entry.path));
      final otherVolumes = byVolume.keys.where((volume) => volume != destinationVolume);
      final fromOtherVolumes = otherVolumes.fold<int>(0, (sum, volume) => sum + byVolume[volume].fold(0, sumSize));
      // and we need at least as much space as the largest entry because individual entries are copied then deleted
      final largestSingle = selection.fold<int>(0, (largest, entry) => max(largest, entry.sizeBytes));
      needed = max(fromOtherVolumes, largestSingle);
    }

    final hasEnoughSpace = needed < free;
    if (!hasEnoughSpace) {
      await showDialog(
        context: context,
        builder: (context) {
          return AvesDialog(
            title: 'Not Enough Space',
            content: Text('This operation needs ${formatFilesize(needed)} of free space on “${destinationVolume.description}” to complete, but there is only ${formatFilesize(free)} left.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'.toUpperCase()),
              ),
            ],
          );
        },
      );
    }
    return hasEnoughSpace;
  }
}
