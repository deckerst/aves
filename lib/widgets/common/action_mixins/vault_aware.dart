import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

mixin VaultAwareMixin on FeedbackMixin {
  Future<bool> unlockAlbum(BuildContext context, String dirPath) async {
    final success = await vaults.tryUnlock(dirPath, context);
    if (!success) {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
    return success;
  }

  Future<bool> unlockFilter(BuildContext context, CollectionFilter filter) {
    return filter is AlbumFilter ? unlockAlbum(context, filter.album) : Future.value(true);
  }

  Future<bool> unlockFilters(BuildContext context, Set<AlbumFilter> filters) async {
    var unlocked = true;
    await Future.forEach(filters, (filter) async {
      if (unlocked) {
        unlocked = await unlockFilter(context, filter);
      }
    });
    return unlocked;
  }

  void lockFilters(Set<AlbumFilter> filters) => vaults.lock(filters.map((v) => v.album).toSet());
}
