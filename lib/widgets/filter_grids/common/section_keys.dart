import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChipSectionKey extends SectionKey {
  final String title;

  const ChipSectionKey({
    this.title = '',
  });

  Widget? get leading => null;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ChipSectionKey && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{title=$title}';
}

class AlbumImportanceSectionKey extends ChipSectionKey {
  final AlbumImportance importance;

  AlbumImportanceSectionKey._private(BuildContext context, this.importance) : super(title: importance.getText(context));

  factory AlbumImportanceSectionKey.pinned(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.pinned);

  factory AlbumImportanceSectionKey.special(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.special);

  factory AlbumImportanceSectionKey.apps(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.apps);

  factory AlbumImportanceSectionKey.regular(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.regular);

  @override
  Widget get leading => Icon(importance.getIcon());
}

enum AlbumImportance { pinned, special, apps, regular }

extension ExtraAlbumImportance on AlbumImportance {
  String getText(BuildContext context) {
    switch (this) {
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
      case AlbumImportance.pinned:
        return AIcons.pin;
      case AlbumImportance.special:
        return Icons.label_important_outline;
      case AlbumImportance.apps:
        return Icons.apps_outlined;
      case AlbumImportance.regular:
        return AIcons.album;
    }
  }
}

class StorageVolumeSectionKey extends ChipSectionKey {
  final StorageVolume? volume;

  StorageVolumeSectionKey(BuildContext context, this.volume) : super(title: volume?.getDescription(context) ?? context.l10n.sectionUnknown);

  @override
  Widget? get leading => (volume?.isRemovable ?? false) ? const Icon(AIcons.removableStorage) : null;
}
