import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryGroupFactorView on EntrySectionFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EntrySectionFactor.album => l10n.collectionGroupAlbum,
      EntrySectionFactor.month => l10n.collectionGroupMonth,
      EntrySectionFactor.day => l10n.collectionGroupDay,
      EntrySectionFactor.none => l10n.sectionNone,
    };
  }

  IconData get icon {
    return switch (this) {
      EntrySectionFactor.album => AIcons.album,
      EntrySectionFactor.month => AIcons.dateByMonth,
      EntrySectionFactor.day => AIcons.dateByDay,
      EntrySectionFactor.none => AIcons.clear,
    };
  }
}

extension ExtraAlbumChipGroupFactorView on AlbumChipSectionFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AlbumChipSectionFactor.importance => l10n.albumGroupTier,
      AlbumChipSectionFactor.mimeType => l10n.albumGroupType,
      AlbumChipSectionFactor.volume => l10n.albumGroupVolume,
      AlbumChipSectionFactor.none => l10n.sectionNone,
    };
  }

  IconData get icon {
    return switch (this) {
      AlbumChipSectionFactor.importance => AIcons.important,
      AlbumChipSectionFactor.mimeType => AIcons.mimeType,
      AlbumChipSectionFactor.volume => AIcons.storageCard,
      AlbumChipSectionFactor.none => AIcons.clear,
    };
  }
}
