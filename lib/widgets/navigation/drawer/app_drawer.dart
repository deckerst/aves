import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/navigation/drawer/collection_nav_tile.dart';
import 'package:aves/widgets/navigation/drawer/page_nav_tile.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  // collection loaded in the `CollectionPage`, if any
  final CollectionLens? currentCollection;

  const AppDrawer({
    super.key,
    this.currentCollection,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();

  static List<String> getDefaultAlbums(BuildContext context) {
    final source = context.read<CollectionSource>();
    final specialAlbums = source.rawAlbums.where((album) {
      final type = androidFileUtils.getAlbumType(album);
      return [AlbumType.camera, AlbumType.screenshots].contains(type);
    }).toList()
      ..sort(source.compareAlbumsByName);
    return specialAlbums;
  }
}

class _AppDrawerState extends State<AppDrawer> {
  // using the default controller conflicts
  // with bottom nav bar primary scroll monitoring
  final ScrollController _scrollController = ScrollController();

  CollectionLens? get currentCollection => widget.currentCollection;

  @override
  Widget build(BuildContext context) {
    final drawerItems = <Widget>[
      _buildHeader(context),
      ..._buildTypeLinks(),
      _buildAlbumLinks(context),
      ..._buildPageLinks(context),
      if (settings.enableBin) ...[
        const Divider(),
        binTile(context),
      ],
      if (!kReleaseMode) ...[
        const Divider(),
        debugTile,
      ],
    ];

    return Drawer(
      child: ListTileTheme.merge(
        selectedColor: Theme.of(context).colorScheme.secondary,
        child: Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.effectiveBottomPadding,
          builder: (context, mqPaddingBottom, child) {
            final iconTheme = IconTheme.of(context);
            return SingleChildScrollView(
              controller: _scrollController,
              // key is expected by test driver
              key: const Key('drawer-scrollview'),
              padding: EdgeInsets.only(bottom: mqPaddingBottom),
              child: IconTheme(
                data: iconTheme.copyWith(
                  size: iconTheme.size! * MediaQuery.textScaleFactorOf(context),
                ),
                child: Column(
                  children: drawerItems,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Future<void> goTo(String routeName, WidgetBuilder pageBuilder) async {
      Navigator.maybeOf(context)?.pop();
      await Future.delayed(Durations.drawerTransitionAnimation);
      await Navigator.maybeOf(context)?.push(
          MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: pageBuilder,
          ));
    }

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const AvesLogo(size: 56),
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
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButtonTheme(
              data: OutlinedButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  overlayColor: MaterialStateProperty.all<Color>(Colors.white24),
                  side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 1, color: Colors.white.withOpacity(0.12))),
                ),
              ),
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    // key is expected by test driver
                    key: const Key('drawer-about-button'),
                    onPressed: () => goTo(AboutPage.routeName, (_) => const AboutPage()),
                    icon: const Icon(AIcons.info),
                    label: Text(context.l10n.drawerAboutButton),
                  ),
                  OutlinedButton.icon(
                    // key is expected by test driver
                    key: const Key('drawer-settings-button'),
                    onPressed: () => goTo(SettingsPage.routeName, (_) => const SettingsPage()),
                    icon: const Icon(AIcons.settings),
                    label: Text(context.l10n.drawerSettingsButton),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeLinks() {
    final hiddenFilters = settings.hiddenFilters;
    final typeBookmarks = settings.drawerTypeBookmarks;
    final currentFilters = currentCollection?.filters;
    return typeBookmarks
        .where((filter) => !hiddenFilters.contains(filter))
        .map((filter) => CollectionNavTile(
              // key is expected by test driver
              key: Key('drawer-type-${filter?.key}'),
              leading: DrawerFilterIcon(filter: filter),
              title: DrawerFilterTitle(filter: filter),
              filter: filter,
              isSelected: () {
                if (currentFilters == null || currentFilters.length > 1) return false;
                return currentFilters.firstOrNull == filter;
              },
            ))
        .toList();
  }

  Widget _buildAlbumLinks(BuildContext context) {
    final source = context.read<CollectionSource>();
    final currentFilters = currentCollection?.filters;
    return StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) {
          final albums = settings.drawerAlbumBookmarks ?? AppDrawer.getDefaultAlbums(context);
          if (albums.isEmpty) return const SizedBox();
          return Column(
            children: [
              const Divider(),
              ...albums.map((album) => AlbumNavTile(
                    album: album,
                    isSelected: () {
                      if (currentFilters == null || currentFilters.length > 1) return false;
                      final currentFilter = currentFilters.firstOrNull;
                      return currentFilter is AlbumFilter && currentFilter.album == album;
                    },
                  )),
            ],
          );
        });
  }

  List<Widget> _buildPageLinks(BuildContext context) {
    final pageBookmarks = settings.drawerPageBookmarks;
    if (pageBookmarks.isEmpty) return [];

    final source = context.read<CollectionSource>();
    return [
      const Divider(),
      ...pageBookmarks.map((route) {
        Widget? trailing;
        switch (route) {
          case AlbumListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<AlbumsChangedEvent>(),
              builder: (context, _) => Text('${source.rawAlbums.length}'),
            );
            break;
          case CountryListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<CountriesChangedEvent>(),
              builder: (context, _) => Text('${source.sortedCountries.length}'),
            );
            break;
          case TagListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<TagsChangedEvent>(),
              builder: (context, _) => Text('${source.sortedTags.length}'),
            );
            break;
        }

        return PageNavTile(
          // key is expected by test driver
          key: Key('drawer-page-$route'),
          trailing: trailing,
          routeName: route,
        );
      }),
    ];
  }

  Widget binTile(BuildContext context) {
    final source = context.read<CollectionSource>();
    final trashSize = source.trashedEntries.fold<int>(0, (sum, entry) => sum + (entry.sizeBytes ?? 0));

    const filter = TrashFilter.instance;
    return CollectionNavTile(
      leading: const DrawerFilterIcon(filter: filter),
      title: const DrawerFilterTitle(filter: filter),
      trailing: Text(formatFileSize(context.l10n.localeName, trashSize, round: 0)),
      filter: filter,
      isSelected: () => currentCollection?.filters.contains(filter) ?? false,
    );
  }

  Widget get debugTile => const PageNavTile(
        // key is expected by test driver
        key: Key('drawer-debug'),
        topLevel: false,
        routeName: AppDebugPage.routeName,
      );
}
