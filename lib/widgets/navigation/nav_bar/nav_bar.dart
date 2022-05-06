import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/navigation/nav_bar/floating.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBottomNavBar extends StatelessWidget {
  // collection loaded in the `CollectionPage`, if any
  final CollectionLens? currentCollection;

  const AppBottomNavBar({
    Key? key,
    this.currentCollection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(8));

    final blurred = context.select<Settings, bool>((s) => s.enableOverlayBlurEffect);
    final showVideo = context.select<Settings, bool>((s) => !s.hiddenFilters.contains(MimeFilter.video));

    final items = [
      const AvesBottomNavItem(route: CollectionPage.routeName),
      if (showVideo) AvesBottomNavItem(route: CollectionPage.routeName, filter: MimeFilter.video),
      const AvesBottomNavItem(route: CollectionPage.routeName, filter: FavouriteFilter.instance),
      const AvesBottomNavItem(route: AlbumListPage.routeName),
    ];

    Widget child = Padding(
      padding: const EdgeInsets.all(8),
      child: BlurredRRect(
        enabled: blurred,
        borderRadius: borderRadius,
        child: BottomNavigationBar(
          items: items
              .map((item) => BottomNavigationBarItem(
                    icon: item.icon(context),
                    label: item.label(context),
                  ))
              .toList(),
          onTap: (index) => _goTo(context, items, index),
          currentIndex: _getCurrentIndex(context, items),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).canvasColor.withOpacity(.85),
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );

    return Hero(
      tag: 'nav-bar',
      flightShuttleBuilder: (flight, animation, direction, fromHero, toHero) {
        return MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          child: toHero.widget,
        );
      },
      child: FloatingNavBar(
        scrollController: PrimaryScrollController.of(context),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context, List<AvesBottomNavItem> items) {
    final currentRoute = context.currentRouteName;
    final currentItem = items.firstWhereOrNull((item) {
      if (currentRoute != item.route) return false;

      if (item.route != CollectionPage.routeName) return true;

      final currentFilters = currentCollection?.filters;
      if (currentFilters == null || currentFilters.length > 1) return false;
      return currentFilters.firstOrNull == item.filter;
    });
    final currentIndex = currentItem != null ? items.indexOf(currentItem) : 0;
    return currentIndex;
  }

  void _goTo(BuildContext context, List<AvesBottomNavItem> items, int index) {
    final item = items[index];
    final routeName = item.route;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (context) {
          switch (routeName) {
            case AlbumListPage.routeName:
              return const AlbumListPage();
            case CollectionPage.routeName:
            default:
              return CollectionPage(
                source: context.read<CollectionSource>(),
                filters: {item.filter},
              );
          }
        },
      ),
      (route) => false,
    );
  }
}
