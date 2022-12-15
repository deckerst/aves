import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/navigation/drawer_tab_albums.dart';
import 'package:aves/widgets/settings/navigation/drawer_tab_fixed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class NavigationDrawerEditorPage extends StatefulWidget {
  static const routeName = '/settings/navigation_drawer';

  const NavigationDrawerEditorPage({super.key});

  @override
  State<NavigationDrawerEditorPage> createState() => _NavigationDrawerEditorPageState();
}

class _NavigationDrawerEditorPageState extends State<NavigationDrawerEditorPage> {
  final List<CollectionFilter?> _typeItems = [];
  final Set<CollectionFilter?> _visibleTypes = {};
  final List<String> _albumItems = [];
  final List<String> _pageItems = [];
  final Set<String> _visiblePages = {};

  static final Set<CollectionFilter?> _typeOptions = {
    null,
    RecentlyAddedFilter.instance,
    ...CollectionSearchDelegate.typeFilters,
  };
  static const Set<String> _pageOptions = {
    AlbumListPage.routeName,
    CountryListPage.routeName,
    TagListPage.routeName,
    SearchPage.routeName,
  };

  @override
  void initState() {
    super.initState();
    final userTypeLinks = settings.drawerTypeBookmarks;
    _visibleTypes.addAll(userTypeLinks);
    _typeItems.addAll(userTypeLinks);
    _typeItems.addAll(_typeOptions.where((v) => !userTypeLinks.contains(v)));

    _albumItems.addAll(settings.drawerAlbumBookmarks ?? AppDrawer.getDefaultAlbums(context));

    final userPageLinks = settings.drawerPageBookmarks;
    _visiblePages.addAll(userPageLinks);
    _pageItems.addAll(userPageLinks);
    _pageItems.addAll(_pageOptions.where((v) => !userPageLinks.contains(v)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(
        Tab(text: l10n.settingsNavigationDrawerTabTypes),
        DrawerFixedListTab<CollectionFilter?>(
          items: _typeItems,
          visibleItems: _visibleTypes,
          leading: (item) => DrawerFilterIcon(filter: item),
          title: (item) => DrawerFilterTitle(filter: item),
        ),
      ),
      Tuple2(
        Tab(text: l10n.settingsNavigationDrawerTabAlbums),
        DrawerAlbumTab(
          items: _albumItems,
        ),
      ),
      Tuple2(
        Tab(text: l10n.settingsNavigationDrawerTabPages),
        DrawerFixedListTab<String>(
          items: _pageItems,
          visibleItems: _visiblePages,
          leading: (item) => DrawerPageIcon(route: item),
          title: (item) => DrawerPageTitle(route: item),
        ),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsNavigationDrawerEditorPageTitle),
          bottom: TabBar(
            tabs: tabs.map((t) => t.item1).toList(),
          ),
        ),
        body: WillPopScope(
          onWillPop: () {
            settings.drawerTypeBookmarks = _typeItems.where(_visibleTypes.contains).toList();
            settings.drawerAlbumBookmarks = _albumItems;
            settings.drawerPageBookmarks = _pageItems.where(_visiblePages.contains).toList();
            return SynchronousFuture(true);
          },
          child: SafeArea(
            child: TabBarView(
              children: tabs.map((t) => t.item2).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
