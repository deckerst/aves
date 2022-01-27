import 'dart:ui';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/drawer/collection_nav_tile.dart';
import 'package:aves/widgets/drawer/page_nav_tile.dart';
import 'package:aves/widgets/drawer/tile.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  static List<String> getDefaultAlbums(BuildContext context) {
    final source = context.read<CollectionSource>();
    final specialAlbums = source.rawAlbums.where((album) {
      final type = androidFileUtils.getAlbumType(album);
      return [AlbumType.camera, AlbumType.screenshots].contains(type);
    }).toList()
      ..sort(source.compareAlbumsByName);
    return specialAlbums;
  }

  @override
  Widget build(BuildContext context) {
    final drawerItems = <Widget>[
      _buildHeader(context),
      ..._buildTypeLinks(),
      _buildAlbumLinks(context),
      ..._buildPageLinks(context),
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
      Navigator.pop(context);
      await Future.delayed(Durations.drawerTransitionAnimation);
      await Navigator.push(
          context,
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
                  const AvesLogo(size: 64),
                  Text(
                    context.l10n.appName,
                    style: const TextStyle(
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
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    // key is expected by test driver
                    key: const Key('drawer-about-button'),
                    onPressed: () => goTo(AboutPage.routeName, (_) => const AboutPage()),
                    icon: const Icon(AIcons.info),
                    label: Text(context.l10n.aboutPageTitle),
                  ),
                  OutlinedButton.icon(
                    // key is expected by test driver
                    key: const Key('drawer-settings-button'),
                    onPressed: () => goTo(SettingsPage.routeName, (_) => const SettingsPage()),
                    icon: const Icon(AIcons.settings),
                    label: Text(context.l10n.settingsPageTitle),
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
    return typeBookmarks
        .where((filter) => !hiddenFilters.contains(filter))
        .map((filter) => CollectionNavTile(
              // key is expected by test driver
              key: Key('drawer-type-${filter?.key}'),
              leading: DrawerFilterIcon(filter: filter),
              title: DrawerFilterTitle(filter: filter),
              filter: filter,
            ))
        .toList();
  }

  Widget _buildAlbumLinks(BuildContext context) {
    final source = context.read<CollectionSource>();
    return StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) {
          final albums = settings.drawerAlbumBookmarks ?? AppDrawer.getDefaultAlbums(context);
          if (albums.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const Divider(),
              ...albums.map((album) => AlbumNavTile(album: album)),
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
        WidgetBuilder? pageBuilder;
        Widget? trailing;
        switch (route) {
          case AlbumListPage.routeName:
            pageBuilder = (_) => const AlbumListPage();
            trailing = StreamBuilder(
              stream: source.eventBus.on<AlbumsChangedEvent>(),
              builder: (context, _) => Text('${source.rawAlbums.length}'),
            );
            break;
          case CountryListPage.routeName:
            pageBuilder = (_) => const CountryListPage();
            trailing = StreamBuilder(
              stream: source.eventBus.on<CountriesChangedEvent>(),
              builder: (context, _) => Text('${source.sortedCountries.length}'),
            );
            break;
          case TagListPage.routeName:
            pageBuilder = (_) => const TagListPage();
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
          pageBuilder: pageBuilder ?? (_) => const SizedBox(),
        );
      }),
    ];
  }

  Widget get debugTile => PageNavTile(
        // key is expected by test driver
        key: const Key('drawer-debug'),
        topLevel: false,
        routeName: AppDebugPage.routeName,
        pageBuilder: (_) => const AppDebugPage(),
      );
}
