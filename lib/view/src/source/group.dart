import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryGroupFactorView on EntryGroupFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EntryGroupFactor.album => l10n.collectionGroupAlbum,
      EntryGroupFactor.month => l10n.collectionGroupMonth,
      EntryGroupFactor.day => l10n.collectionGroupDay,
      EntryGroupFactor.none => l10n.collectionGroupNone,
    };
  }

  IconData get icon {
    return switch (this) {
      EntryGroupFactor.album => AIcons.album,
      EntryGroupFactor.month => AIcons.dateByMonth,
      EntryGroupFactor.day => AIcons.dateByDay,
      EntryGroupFactor.none => AIcons.clear,
    };
  }
}

extension ExtraAlbumChipGroupFactorView on AlbumChipGroupFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AlbumChipGroupFactor.importance => l10n.albumGroupTier,
      AlbumChipGroupFactor.mimeType => l10n.albumGroupType,
      AlbumChipGroupFactor.volume => l10n.albumGroupVolume,
      AlbumChipGroupFactor.none => l10n.albumGroupNone,
    };
  }

  IconData get icon {
    return switch (this) {
      AlbumChipGroupFactor.importance => AIcons.important,
      AlbumChipGroupFactor.mimeType => AIcons.mimeType,
      AlbumChipGroupFactor.volume => AIcons.storageCard,
      AlbumChipGroupFactor.none => AIcons.clear,
    };
  }
}
