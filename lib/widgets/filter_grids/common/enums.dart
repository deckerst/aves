import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:material_ui/material_ui.dart';

enum ChipType { regular, group }

enum AlbumChipType { stored, dynamic, group }

enum ChipImportance { newAlbum, pinned, group, special, apps, vaults, dynamic, regular }

extension ExtraChipImportanceView on ChipImportance {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .newAlbum => l10n.albumTierNew,
      .pinned => l10n.albumTierPinned,
      .group => l10n.albumTierGroups,
      .special => l10n.albumTierSpecial,
      .apps => l10n.albumTierApps,
      .vaults => l10n.albumTierVaults,
      .dynamic => l10n.albumTierDynamic,
      .regular => l10n.albumTierRegular,
    };
  }

  IconData getIcon() {
    return switch (this) {
      .newAlbum => AIcons.newTier,
      .pinned => AIcons.pin,
      .group => AIcons.group,
      .special => AIcons.important,
      .apps => AIcons.app,
      .vaults => AIcons.locked,
      .dynamic => AIcons.dynamicAlbum,
      // depends on chip page
      .regular => AIcons.album,
    };
  }
}

enum AlbumMimeType { images, videos, mixed }

extension ExtraAlbumMimeTypeView on AlbumMimeType {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .images => l10n.drawerCollectionImages,
      .videos => l10n.drawerCollectionVideos,
      .mixed => l10n.albumMimeTypeMixed,
    };
  }

  IconData getIcon() {
    return switch (this) {
      .images => AIcons.image,
      .videos => AIcons.video,
      .mixed => AIcons.mimeType,
    };
  }
}
