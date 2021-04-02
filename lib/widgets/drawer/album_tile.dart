import 'package:aves/model/filters/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves/widgets/drawer/collection_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumTile extends StatelessWidget {
  final String album;

  const AlbumTile(this.album);

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    final displayName = source.getAlbumDisplayName(context, album);
    return CollectionNavTile(
      leading: IconUtils.getAlbumIcon(
        context: context,
        album: album,
      ),
      title: displayName,
      trailing: androidFileUtils.isOnRemovableStorage(album)
          ? Icon(
              AIcons.removableStorage,
              size: 16,
              color: Colors.grey,
            )
          : null,
      filter: AlbumFilter(album, displayName),
    );
  }
}
