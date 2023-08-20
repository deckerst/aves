import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

enum AlbumImportance { newAlbum, pinned, special, apps, vaults, regular }

extension ExtraAlbumImportance on AlbumImportance {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AlbumImportance.newAlbum => l10n.albumTierNew,
      AlbumImportance.pinned => l10n.albumTierPinned,
      AlbumImportance.special => l10n.albumTierSpecial,
      AlbumImportance.apps => l10n.albumTierApps,
      AlbumImportance.vaults => l10n.albumTierVaults,
      AlbumImportance.regular => l10n.albumTierRegular,
    };
  }

  IconData getIcon() {
    return switch (this) {
      AlbumImportance.newAlbum => AIcons.newTier,
      AlbumImportance.pinned => AIcons.pin,
      AlbumImportance.special => AIcons.important,
      AlbumImportance.apps => AIcons.app,
      AlbumImportance.vaults => AIcons.locked,
      AlbumImportance.regular => AIcons.album,
    };
  }
}

enum AlbumMimeType { images, videos, mixed }

extension ExtraAlbumMimeType on AlbumMimeType {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AlbumMimeType.images => l10n.drawerCollectionImages,
      AlbumMimeType.videos => l10n.drawerCollectionVideos,
      AlbumMimeType.mixed => l10n.albumMimeTypeMixed,
    };
  }

  IconData getIcon() {
    return switch (this) {
      AlbumMimeType.images => AIcons.image,
      AlbumMimeType.videos => AIcons.video,
      AlbumMimeType.mixed => AIcons.mimeType,
    };
  }
}
