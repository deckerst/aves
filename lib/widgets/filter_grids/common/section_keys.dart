import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChipSectionKey extends SectionKey with EquatableMixin {
  final String title;

  @override
  List<Object?> get props => [title];

  const ChipSectionKey({
    this.title = '',
  });

  Widget? get leading => null;
}

class AlbumImportanceSectionKey extends ChipSectionKey {
  final AlbumImportance importance;

  AlbumImportanceSectionKey._private(BuildContext context, this.importance) : super(title: importance.getText(context));

  factory AlbumImportanceSectionKey.newAlbum(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.newAlbum);

  factory AlbumImportanceSectionKey.pinned(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.pinned);

  factory AlbumImportanceSectionKey.special(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.special);

  factory AlbumImportanceSectionKey.apps(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.apps);

  factory AlbumImportanceSectionKey.regular(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.regular);

  @override
  Widget get leading => Icon(importance.getIcon());
}

class MimeTypeSectionKey extends ChipSectionKey {
  final AlbumMimeType mimeType;

  MimeTypeSectionKey._private(BuildContext context, this.mimeType) : super(title: mimeType.getText(context));

  factory MimeTypeSectionKey.images(BuildContext context) => MimeTypeSectionKey._private(context, AlbumMimeType.images);

  factory MimeTypeSectionKey.videos(BuildContext context) => MimeTypeSectionKey._private(context, AlbumMimeType.videos);

  factory MimeTypeSectionKey.mixed(BuildContext context) => MimeTypeSectionKey._private(context, AlbumMimeType.mixed);

  @override
  Widget get leading => Icon(mimeType.getIcon());
}

class StorageVolumeSectionKey extends ChipSectionKey {
  final StorageVolume? volume;

  StorageVolumeSectionKey(BuildContext context, this.volume) : super(title: volume?.getDescription(context) ?? context.l10n.sectionUnknown);

  @override
  Widget? get leading => (volume?.isRemovable ?? false) ? const Icon(AIcons.removableStorage) : null;
}
