import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

enum AlbumImportance { newAlbum, pinned, special, apps, regular }

extension ExtraAlbumImportance on AlbumImportance {
  String getText(BuildContext context) {
    switch (this) {
      case AlbumImportance.newAlbum:
        return context.l10n.albumTierNew;
      case AlbumImportance.pinned:
        return context.l10n.albumTierPinned;
      case AlbumImportance.special:
        return context.l10n.albumTierSpecial;
      case AlbumImportance.apps:
        return context.l10n.albumTierApps;
      case AlbumImportance.regular:
        return context.l10n.albumTierRegular;
    }
  }

  IconData getIcon() {
    switch (this) {
      case AlbumImportance.newAlbum:
        return AIcons.newTier;
      case AlbumImportance.pinned:
        return AIcons.pin;
      case AlbumImportance.special:
        return AIcons.important;
      case AlbumImportance.apps:
        return AIcons.app;
      case AlbumImportance.regular:
        return AIcons.album;
    }
  }
}

enum AlbumMimeType { images, videos, mixed }

extension ExtraAlbumMimeType on AlbumMimeType {
  String getText(BuildContext context) {
    switch (this) {
      case AlbumMimeType.images:
        return context.l10n.drawerCollectionImages;
      case AlbumMimeType.videos:
        return context.l10n.drawerCollectionVideos;
      case AlbumMimeType.mixed:
        return context.l10n.albumMimeTypeMixed;
    }
  }

  IconData getIcon() {
    switch (this) {
      case AlbumMimeType.images:
        return AIcons.image;
      case AlbumMimeType.videos:
        return AIcons.video;
      case AlbumMimeType.mixed:
        return AIcons.mimeType;
    }
  }
}
