import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/drawer/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionNavTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final bool dense;
  final CollectionFilter? filter;

  const CollectionNavTile({
    Key? key,
    required this.leading,
    required this.title,
    this.trailing,
    bool? dense,
    required this.filter,
  })  : dense = dense ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: leading,
        title: title,
        trailing: trailing,
        dense: dense,
        onTap: () => _goToCollection(context),
      ),
    );
  }

  void _goToCollection(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          collection: CollectionLens(
            source: context.read<CollectionSource>(),
            filters: [filter],
          ),
        ),
      ),
      (route) => false,
    );
  }
}

class AlbumNavTile extends StatelessWidget {
  final String album;

  const AlbumNavTile({
    Key? key,
    required this.album,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    var filter = AlbumFilter(album, source.getAlbumDisplayName(context, album));
    return CollectionNavTile(
      leading: DrawerFilterIcon(filter: filter),
      title: DrawerFilterTitle(filter: filter),
      trailing: androidFileUtils.isOnRemovableStorage(album)
          ? const Icon(
              AIcons.removableStorage,
              size: 16,
              color: Colors.grey,
            )
          : null,
      filter: filter,
    );
  }
}
