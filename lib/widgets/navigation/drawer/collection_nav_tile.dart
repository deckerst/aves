import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionNavTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final bool dense;
  final CollectionFilter? filter;
  final bool Function() isSelected;

  const CollectionNavTile({
    Key? key,
    required this.leading,
    required this.title,
    this.trailing,
    bool? dense,
    required this.filter,
    required this.isSelected,
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
        trailing: trailing != null
            ? Builder(
                builder: (context) {
                  final trailingColor = IconTheme.of(context).color!.withOpacity(.6);
                  return IconTheme.merge(
                    data: IconThemeData(color: trailingColor),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: trailingColor),
                      child: trailing!,
                    ),
                  );
                },
              )
            : null,
        dense: dense,
        onTap: () => _goToCollection(context),
        selected: context.currentRouteName == CollectionPage.routeName && isSelected(),
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
          source: context.read<CollectionSource>(),
          filters: {filter},
        ),
      ),
      (route) => false,
    );
  }
}

class AlbumNavTile extends StatelessWidget {
  final String album;
  final bool Function() isSelected;

  const AlbumNavTile({
    Key? key,
    required this.album,
    required this.isSelected,
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
            )
          : null,
      filter: filter,
      isSelected: isSelected,
    );
  }
}
