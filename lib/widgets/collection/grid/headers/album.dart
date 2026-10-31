import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:material_ui/material_ui.dart';

class const AlbumSectionHeader({
  super.key,
  required final String? directory,
  required final String? albumName,
  required final bool selectable,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget? albumIcon;
    final _directory = directory;
    if (_directory != null) {
      albumIcon = IconUtils.getAlbumIcon(context: context, albumPath: _directory);
      if (albumIcon != null) {
        albumIcon = RepaintBoundary(
          child: albumIcon,
        );
      }
    }
    return SectionHeader<AvesEntry>(
      sectionKey: EntryAlbumSectionKey(_directory),
      leading: albumIcon,
      title: albumName ?? context.l10n.sectionUnknown,
      trailing: _directory != null && androidFileUtils.isOnRemovableStorage(_directory)
          ? const Icon(
              AIcons.storageCard,
              size: 16,
              color: Color(0xFF757575),
            )
          : null,
      selectable: selectable,
    );
  }
}
