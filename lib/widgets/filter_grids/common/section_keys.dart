import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

class ChipSectionKey extends SectionKey with Equatable {
  final String title;

  @override
  List<Object?> get props => [title];

  const new({
    this.title = '',
  });

  Widget? get leading => null;
}

class AlbumImportanceSectionKey extends ChipSectionKey {
  final AlbumImportance importance;

  new _private(BuildContext context, this.importance) : super(title: importance.getText(context));

  factory newAlbum(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.newAlbum);

  factory pinned(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.pinned);

  factory group(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.group);

  factory special(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.special);

  factory apps(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.apps);

  factory vault(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.vaults);

  factory dynamic(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.dynamic);

  factory regular(BuildContext context) => AlbumImportanceSectionKey._private(context, AlbumImportance.regular);

  @override
  Widget get leading => Icon(importance.getIcon());
}

class MimeTypeSectionKey extends ChipSectionKey {
  final AlbumMimeType mimeType;

  new _private(BuildContext context, this.mimeType) : super(title: mimeType.getText(context));

  factory images(BuildContext context) => MimeTypeSectionKey._private(context, AlbumMimeType.images);

  factory videos(BuildContext context) => MimeTypeSectionKey._private(context, AlbumMimeType.videos);

  factory mixed(BuildContext context) => MimeTypeSectionKey._private(context, AlbumMimeType.mixed);

  @override
  Widget get leading => Icon(mimeType.getIcon());
}

class StorageVolumeSectionKey extends ChipSectionKey {
  final StorageVolume? volume;

  new(BuildContext context, this.volume) : super(title: volume?.getDescription(context) ?? context.l10n.sectionUnknown);

  @override
  Widget? get leading => (volume?.isRemovable ?? false) ? const Icon(AIcons.storageCard) : null;
}
