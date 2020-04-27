import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/album/grid/header_generic.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AlbumSectionHeader extends StatelessWidget {
  final String folderPath, albumName;

  const AlbumSectionHeader({
    Key key,
    @required this.folderPath,
    @required this.albumName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var albumIcon = IconUtils.getAlbumIcon(context: context, album: folderPath);
    if (albumIcon != null) {
      albumIcon = Material(
        type: MaterialType.circle,
        elevation: 3,
        color: Colors.transparent,
        shadowColor: Colors.black,
        child: albumIcon,
      );
    }
    return TitleSectionHeader(
      sectionKey: folderPath,
      leading: albumIcon,
      title: albumName,
      trailing: androidFileUtils.isOnRemovableStorage(folderPath)
          ? const Icon(
              OMIcons.sdStorage,
              size: 16,
              color: Color(0xFF757575),
            )
          : null,
    );
  }
}
