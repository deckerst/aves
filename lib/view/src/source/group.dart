import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntryGroupFactorView on EntrySectionFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .album => l10n.collectionGroupAlbum,
      .month => l10n.collectionGroupMonth,
      .day => l10n.collectionGroupDay,
      .none => l10n.sectionNone,
    };
  }

  IconData get icon {
    return switch (this) {
      .album => AIcons.album,
      .month => AIcons.dateByMonth,
      .day => AIcons.dateByDay,
      .none => AIcons.clear,
    };
  }
}

extension ExtraAlbumChipGroupFactorView on AlbumChipSectionFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .importance => l10n.albumGroupTier,
      .mimeType => l10n.albumGroupType,
      .volume => l10n.albumGroupVolume,
      .none => l10n.sectionNone,
    };
  }

  IconData get icon {
    return switch (this) {
      .importance => AIcons.important,
      .mimeType => AIcons.mimeType,
      .volume => AIcons.storageCard,
      .none => AIcons.clear,
    };
  }
}
