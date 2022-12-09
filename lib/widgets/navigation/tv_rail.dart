import 'dart:math';
import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/drawer/page_nav_tile.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TvRail extends StatefulWidget {
  // collection loaded in the `CollectionPage`, if any
  final CollectionLens? currentCollection;

  const TvRail({
    super.key,
    this.currentCollection,
  });

  @override
  State<TvRail> createState() => _TvRailState();
}

class _TvRailState extends State<TvRail> {
  final _scrollController = ScrollController();

  CollectionLens? get currentCollection => widget.currentCollection;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        const AvesLogo(size: 48),
        const SizedBox(width: 16),
        Text(
          context.l10n.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.0,
            fontFeatures: [FontFeature.enable('smcp')],
          ),
        ),
      ],
    );

    final navEntries = <_NavEntry>[
      ..._buildTypeLinks(),
      ..._buildAlbumLinks(context),
      ..._buildPageLinks(context),
      ...[
        SettingsPage.routeName,
        AboutPage.routeName,
      ].map(_routeNavEntry),
      if (!kReleaseMode) _routeNavEntry(AppDebugPage.routeName),
    ];

    final rail = NavigationRail(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extended: true,
      destinations: navEntries
          .map((v) => NavigationRailDestination(
                icon: v.icon,
                label: v.label,
              ))
          .toList(),
      selectedIndex: max(0, navEntries.indexWhere(((v) => v.isSelected))),
      onDestinationSelected: (index) => navEntries[index].onSelection(),
    );

    return Column(
      children: [
        const SizedBox(height: 8),
        header,
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(child: rail),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<_NavEntry> _buildTypeLinks() {
    final hiddenFilters = settings.hiddenFilters;
    final typeBookmarks = settings.drawerTypeBookmarks;
    final currentFilters = currentCollection?.filters;
    return typeBookmarks.where((filter) => !hiddenFilters.contains(filter)).map((filter) {
      bool isSelected() {
        if (currentFilters == null || currentFilters.length > 1) return false;
        return currentFilters.firstOrNull == filter;
      }

      return _NavEntry(
        icon: DrawerFilterIcon(filter: filter),
        label: DrawerFilterTitle(filter: filter),
        isSelected: isSelected(),
        onSelection: () => _goToCollection(context, filter),
      );
    }).toList();
  }

  List<_NavEntry> _buildAlbumLinks(BuildContext context) {
    final source = context.read<CollectionSource>();
    final currentFilters = currentCollection?.filters;
    final albums = settings.drawerAlbumBookmarks ?? AppDrawer.getDefaultAlbums(context);
    return albums.map((album) {
      final filter = AlbumFilter(album, source.getAlbumDisplayName(context, album));
      bool isSelected() {
        if (currentFilters == null || currentFilters.length > 1) return false;
        final currentFilter = currentFilters.firstOrNull;
        return currentFilter is AlbumFilter && currentFilter.album == album;
      }

      return _NavEntry(
        icon: DrawerFilterIcon(filter: filter),
        label: DrawerFilterTitle(filter: filter),
        isSelected: isSelected(),
        onSelection: () => _goToCollection(context, filter),
      );
    }).toList();
  }

  List<_NavEntry> _buildPageLinks(BuildContext context) {
    final pageBookmarks = settings.drawerPageBookmarks;
    return pageBookmarks.map(_routeNavEntry).toList();
  }

  _NavEntry _routeNavEntry(String route) => _NavEntry(
        icon: DrawerPageIcon(route: route),
        label: DrawerPageTitle(route: route),
        isSelected: context.currentRouteName == route,
        onSelection: () => _goTo(route),
      );

  Future<void> _goTo(String routeName) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: PageNavTile.pageBuilder(routeName),
        ));
  }

  void _goToCollection(BuildContext context, CollectionFilter? filter) {
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

@immutable
class _NavEntry {
  final Widget icon;
  final Widget label;
  final bool isSelected;
  final VoidCallback onSelection;

  const _NavEntry({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onSelection,
  });
}
