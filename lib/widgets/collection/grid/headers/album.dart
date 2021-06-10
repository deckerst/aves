import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/material.dart';

class AlbumSectionHeader extends StatelessWidget {
  final String? directory, albumName;

  const AlbumSectionHeader({
    Key? key,
    required this.directory,
    required this.albumName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? albumIcon;
    if (directory != null) {
      albumIcon = IconUtils.getAlbumIcon(context: context, albumPath: directory!);
      if (albumIcon != null) {
        albumIcon = RepaintBoundary(
          child: Material(
            type: MaterialType.circle,
            elevation: 3,
            color: Colors.transparent,
            shadowColor: Colors.black,
            child: albumIcon,
          ),
        );
      }
    }
    return SectionHeader(
      sectionKey: EntryAlbumSectionKey(directory),
      leading: albumIcon,
      title: albumName ?? context.l10n.sectionUnknown,
      trailing: directory != null && androidFileUtils.isOnRemovableStorage(directory!)
          ? const Icon(
              AIcons.removableStorage,
              size: 16,
              color: Color(0xFF757575),
            )
          : null,
    );
  }

  static double getPreferredHeight(BuildContext context, double maxWidth, CollectionSource source, EntryAlbumSectionKey sectionKey) {
    final directory = sectionKey.directory ?? context.l10n.sectionUnknown;
    return SectionHeader.getPreferredHeight(
      context: context,
      maxWidth: maxWidth,
      title: source.getAlbumDisplayName(context, directory),
      hasLeading: androidFileUtils.getAlbumType(directory) != AlbumType.regular,
      hasTrailing: androidFileUtils.isOnRemovableStorage(directory),
    );
  }
}
