import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChipSectionKey extends SectionKey {
  final String title;

  const ChipSectionKey({
    this.title = '',
  });

  Widget get leading => null;

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

  AlbumImportanceSectionKey._private(this.importance) : super(title: importance.getText());

  static AlbumImportanceSectionKey pinned = AlbumImportanceSectionKey._private(AlbumImportance.pinned);
  static AlbumImportanceSectionKey special = AlbumImportanceSectionKey._private(AlbumImportance.special);
  static AlbumImportanceSectionKey apps = AlbumImportanceSectionKey._private(AlbumImportance.apps);
  static AlbumImportanceSectionKey regular = AlbumImportanceSectionKey._private(AlbumImportance.regular);

  @override
  Widget get leading => Icon(importance.getIcon());
}

enum AlbumImportance { pinned, special, apps, regular }

extension ExtraAlbumImportance on AlbumImportance {
  String getText() {
    switch (this) {
      case AlbumImportance.pinned:
        return 'Pinned';
      case AlbumImportance.special:
        return 'Common';
      case AlbumImportance.apps:
        return 'Apps';
      case AlbumImportance.regular:
        return 'Others';
    }
    return null;
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
    return null;
  }
}

class StorageVolumeSectionKey extends ChipSectionKey {
  final StorageVolume volume;

  StorageVolumeSectionKey(this.volume) : super(title: volume.description);

  @override
  Widget get leading => volume.isRemovable ? Icon(AIcons.removableStorage) : null;
}
