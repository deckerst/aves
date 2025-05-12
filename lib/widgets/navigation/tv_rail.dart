import 'dart:math';

import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/drawer/page_nav_tile.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TvRailController {
  int? focusedIndex;
  double offset = 0;
}

class TvRail extends StatefulWidget {
  // collection loaded in the `CollectionPage`, if any
  final CollectionLens? currentCollection;
  final TvRailController controller;

  static const double minExtendedWidth = 256;

  const TvRail({
    super.key,
    required this.controller,
    this.currentCollection,
  });

  @override
  State<TvRail> createState() => _TvRailState();
}

class _TvRailState extends State<TvRail> {
  late final ScrollController _scrollController;
  final ValueNotifier<bool> _extendedNotifier = ValueNotifier(true);
  final FocusNode _focusNode = FocusNode();

  TvRailController get controller => widget.controller;

  CollectionLens? get currentCollection => widget.currentCollection;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: controller.offset);
    _scrollController.addListener(_onScrollChanged);

    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFocus());
  }

  @override
  void didUpdateWidget(covariant TvRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _extendedNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _registerWidget(TvRail widget) {
    widget.currentCollection?.filterChangeNotifier.addListener(_onCollectionFilterChanged);
  }

  void _unregisterWidget(TvRail widget) {
    widget.currentCollection?.filterChangeNotifier.removeListener(_onCollectionFilterChanged);
  }

  @override
  Widget build(BuildContext context) {
    final navEntries = _getNavEntries(context);
    return DirectionalSafeArea(
      end: false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _extendedNotifier,
        builder: (context, extended, child) {
          const logo = AvesLogo(size: 48);
          final header = extended
              ? Row(
                  children: [
                    logo,
                    const SizedBox(width: 16),
                    Text(
                      context.l10n.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        letterSpacing: canHaveLetterSpacing(context.locale) ? 1 : 0,
                        fontFeatures: const [FontFeature.enable('smcp')],
                      ),
                    ),
                  ],
                )
              : logo;

          final railTheme = Theme.of(context).navigationRailTheme;
          const double labelFontSize = 16;
          final rail = Focus(
            focusNode: _focusNode,
            skipTraversal: true,
            child: NavigationRail(
              extended: extended,
              destinations: navEntries
                  .map((v) => NavigationRailDestination(
                        icon: v.icon,
                        label: v.label,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ))
                  .toList(),
              selectedIndex: max(0, navEntries.indexWhere(((v) => v.isSelected))),
              onDestinationSelected: (index) {
                controller.focusedIndex = index;
                navEntries[index].onSelection();
              },
              unselectedLabelTextStyle: railTheme.unselectedLabelTextStyle?.copyWith(fontSize: labelFontSize),
              selectedLabelTextStyle: railTheme.selectedLabelTextStyle?.copyWith(fontSize: labelFontSize),
              minExtendedWidth: TvRail.minExtendedWidth,
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              header,
              const SizedBox(height: 4),
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
        },
      ),
    );
  }

  void _initFocus() {
    var index = controller.focusedIndex ?? -1;
    controller.focusedIndex = null;

    if (index == -1) {
      final navEntries = _getNavEntries(context);
      index = navEntries.indexWhere((v) => v.isHome);
    }

    final nodes = _focusNode.children.toList();
    if (0 <= index && index < nodes.length) {
      nodes[index].requestFocus();
    }
  }

  List<_NavEntry> _getNavEntries(BuildContext context) {
    final navEntries = <_NavEntry>[
      ..._buildTypeLinks(),
      ..._buildAlbumLinks(context),
      ..._buildPageLinks(context),
      ...[
        SettingsPage.routeName,
        AboutPage.routeName,
        if (!kReleaseMode) AppDebugPage.routeName,
      ].map(_routeNavEntry),
    ];
    return navEntries;
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
        isHome: settings.homePage == HomePageSetting.collection && filter == null,
        isSelected: isSelected(),
        onSelection: () => _goToCollection(context, filter),
      );
    }).toList();
  }

  List<_NavEntry> _buildAlbumLinks(BuildContext context) {
    final currentFilters = currentCollection?.filters;
    final albums = AppDrawer.effectiveAlbumBookmarks(context);
    return albums.map((filter) {
      bool isSelected() {
        if (currentFilters == null || currentFilters.length > 1) return false;
        final currentFilter = currentFilters.firstOrNull;
        if (currentFilter is StoredAlbumFilter && filter is StoredAlbumFilter) {
          return currentFilter.album == filter.album;
        } else if (currentFilter is DynamicAlbumFilter && filter is DynamicAlbumFilter) {
          return currentFilter.name == filter.name;
        }
        return false;
      }

      return _NavEntry(
        icon: DrawerFilterIcon(filter: filter),
        label: DrawerFilterTitle(filter: filter),
        isHome: false,
        isSelected: isSelected(),
        onSelection: () => _goToCollection(context, filter),
      );
    }).toList();
  }

  List<_NavEntry> _buildPageLinks(BuildContext context) {
    final pageBookmarks = settings.drawerPageBookmarks;
    return pageBookmarks.map(_routeNavEntry).toList();
  }

  _NavEntry _routeNavEntry(String routeName) {
    final homePage = settings.homePage;
    return _NavEntry(
      icon: DrawerPageIcon(route: routeName),
      label: DrawerPageTitle(route: routeName),
      isHome: homePage != HomePageSetting.collection && routeName == homePage.routeName,
      isSelected: context.currentRouteName == routeName,
      onSelection: () => _goTo(routeName),
    );
  }

  void _goTo(String routeName) {
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      PageNavTile.defaultRouteBuilder(context, routeName, true),
      (route) => false,
    );
  }

  void _goToCollection(BuildContext context, CollectionFilter? filter) {
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
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

  void _onScrollChanged() => controller.offset = _scrollController.offset;

  void _onCollectionFilterChanged() => setState(() {});
}

@immutable
class _NavEntry {
  final Widget icon, label;
  final bool isHome, isSelected;
  final VoidCallback onSelection;

  const _NavEntry({
    required this.icon,
    required this.label,
    required this.isHome,
    required this.isSelected,
    required this.onSelection,
  });
}
