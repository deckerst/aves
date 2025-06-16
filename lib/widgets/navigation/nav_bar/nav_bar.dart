import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/notifications.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/navigation/nav_bar/floating.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBottomNavBar extends StatefulWidget {
  final Stream<DraggableScrollbarEvent> events;

  // collection loaded in the `CollectionPage`, if any
  final CollectionLens? currentCollection;

  static double get height => kBottomNavigationBarHeight + AvesFloatingBar.margin.vertical;

  const AppBottomNavBar({
    super.key,
    required this.events,
    this.currentCollection,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  String? _lastRoute;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(AppBottomNavBar widget) {
    widget.currentCollection?.filterChangeNotifier.addListener(_onCollectionFilterChanged);
  }

  void _unregisterWidget(AppBottomNavBar widget) {
    widget.currentCollection?.filterChangeNotifier.removeListener(_onCollectionFilterChanged);
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = context.select<Settings, bool>((v) => !v.hiddenFilters.contains(MimeFilter.video));

    final items = [
      const AvesBottomNavItem(route: CollectionPage.routeName),
      if (showVideo) AvesBottomNavItem(route: CollectionPage.routeName, filter: MimeFilter.video),
      const AvesBottomNavItem(route: CollectionPage.routeName, filter: FavouriteFilter.instance),
      const AvesBottomNavItem(route: AlbumListPage.routeName),
    ];

    Widget child = FloatingNavBar(
      scrollController: PrimaryScrollController.of(context),
      events: widget.events,
      childHeight: AppBottomNavBar.height + context.select<MediaQueryData, double>((mq) => mq.effectiveBottomPadding),
      child: SafeArea(
        child: AvesFloatingBar(
          builder: (context, backgroundColor, child) => BottomNavigationBar(
            items: items
                .map((item) => BottomNavigationBarItem(
                      icon: item.icon(context),
                      label: item.label(context),
                      tooltip: item.label(context),
                    ))
                .toList(),
            onTap: (index) => _goTo(context, items, index),
            currentIndex: _getCurrentIndex(context, items),
            type: BottomNavigationBarType.fixed,
            backgroundColor: backgroundColor,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );

    final animate = context.select<Settings, bool>((v) => v.animate);
    if (animate) {
      child = Hero(
        tag: 'nav-bar',
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: toHeroContext.widget,
          );
        },
        child: child,
      );
    }

    return child;
  }

  void _onCollectionFilterChanged() => setState(() {});

  int _getCurrentIndex(BuildContext context, List<AvesBottomNavItem> items) {
    // current route may be null during navigation
    final currentRoute = context.currentRouteName ?? _lastRoute;
    _lastRoute = currentRoute;

    final currentItem = items.firstWhereOrNull((item) {
      if (currentRoute != item.route) return false;

      if (item.route != CollectionPage.routeName) return true;

      final currentFilters = widget.currentCollection?.filters;
      if (currentFilters == null || currentFilters.length > 1) return false;
      return currentFilters.firstOrNull == item.filter;
    });
    final currentIndex = currentItem != null ? items.indexOf(currentItem) : 0;
    return currentIndex;
  }

  void _goTo(BuildContext context, List<AvesBottomNavItem> items, int index) {
    final item = items[index];
    final routeName = item.route;
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (context) {
          switch (routeName) {
            case AlbumListPage.routeName:
              return const AlbumListPage(initialGroup: null);
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

class NavBarPaddingSliver extends StatelessWidget {
  const NavBarPaddingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
    final enableBottomNavigationBar = context.select<Settings, bool>((v) => v.enableBottomNavigationBar);
    final showBottomNavigationBar = canNavigate && enableBottomNavigationBar;
    return SliverToBoxAdapter(
      child: SizedBox(height: showBottomNavigationBar ? AppBottomNavBar.height : 0),
    );
  }
}
