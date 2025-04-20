import 'package:aves/model/filters/covered/album_base.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionNavTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final Set<CollectionFilter?>? filters;
  final bool Function() isSelected;

  const CollectionNavTile({
    super.key,
    required this.leading,
    required this.title,
    this.trailing,
    required this.filters,
    required this.isSelected,
  });

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
                  final trailingColor = IconTheme.of(context).color!.withValues(alpha: .6);
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
        onTap: () => _goToCollection(context),
        selected: context.currentRouteName == CollectionPage.routeName && isSelected(),
      ),
    );
  }

  void _goToCollection(BuildContext context) {
    Navigator.maybeOf(context)?.pop();
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: context.read<CollectionSource>(),
          filters: filters,
        ),
      ),
      (route) => false,
    );
  }
}

class AlbumNavTile extends StatelessWidget {
  final AlbumBaseFilter filter;
  final bool Function() isSelected;

  const AlbumNavTile({
    super.key,
    required this.filter,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CollectionNavTile(
      leading: DrawerFilterIcon(filter: filter),
      title: DrawerFilterTitle(filter: filter),
      trailing: filter.storageVolume?.isRemovable ?? false
          ? const Icon(
              AIcons.storageCard,
              size: 16,
            )
          : null,
      filters: {filter},
      isSelected: isSelected,
    );
  }
}
