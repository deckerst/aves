import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryGroupFactorView on EntryGroupFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case EntryGroupFactor.album:
        return l10n.collectionGroupAlbum;
      case EntryGroupFactor.month:
        return l10n.collectionGroupMonth;
      case EntryGroupFactor.day:
        return l10n.collectionGroupDay;
      case EntryGroupFactor.none:
        return l10n.collectionGroupNone;
    }
  }

  IconData get icon {
    switch (this) {
      case EntryGroupFactor.album:
        return AIcons.album;
      case EntryGroupFactor.month:
        return AIcons.dateByMonth;
      case EntryGroupFactor.day:
        return AIcons.dateByDay;
      case EntryGroupFactor.none:
        return AIcons.clear;
    }
  }
}

extension ExtraAlbumChipGroupFactorView on AlbumChipGroupFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case AlbumChipGroupFactor.importance:
        return l10n.albumGroupTier;
      case AlbumChipGroupFactor.mimeType:
        return l10n.albumGroupType;
      case AlbumChipGroupFactor.volume:
        return l10n.albumGroupVolume;
      case AlbumChipGroupFactor.none:
        return l10n.albumGroupNone;
    }
  }

  IconData get icon {
    switch (this) {
      case AlbumChipGroupFactor.importance:
        return AIcons.important;
      case AlbumChipGroupFactor.mimeType:
        return AIcons.mimeType;
      case AlbumChipGroupFactor.volume:
        return AIcons.removableStorage;
      case AlbumChipGroupFactor.none:
        return AIcons.clear;
    }
  }
}
