import 'dart:ui';

import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/drawer/album_tile.dart';
import 'package:aves/widgets/drawer/collection_tile.dart';
import 'package:aves/widgets/drawer/tile.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Future<bool> _newVersionLoader;

  CollectionSource get source => context.read<CollectionSource>();

  @override
  void initState() {
    super.initState();
    _newVersionLoader = availability.isNewVersionAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final hiddenFilters = settings.hiddenFilters;
    final showVideos = !hiddenFilters.contains(MimeFilter.video);
    final showFavourites = !hiddenFilters.contains(FavouriteFilter.instance);
    final drawerItems = <Widget>[
      _buildHeader(context),
      allCollectionTile,
      if (showVideos) videoTile,
      if (showFavourites) favouriteTile,
      _buildSpecialAlbumSection(),
      Divider(),
      albumListTile,
      countryListTile,
      tagListTile,
      if (kDebugMode) ...[
        Divider(),
        debugTile,
      ],
    ];

    return Drawer(
      child: ListTileTheme.merge(
        selectedColor: Theme.of(context).accentColor,
        child: Selector<MediaQueryData, double>(
          selector: (c, mq) => mq.effectiveBottomPadding,
          builder: (c, mqPaddingBottom, child) {
            final iconTheme = IconTheme.of(context);
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: mqPaddingBottom),
              child: IconTheme(
                data: iconTheme.copyWith(
                  size: iconTheme.size * MediaQuery.textScaleFactorOf(context),
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
      padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
      color: Theme.of(context).accentColor,
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
                  AvesLogo(size: 64),
                  Text(
                    context.l10n.appName,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                      fontFeatures: [FontFeature.enable('smcp')],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
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
                    onPressed: () => goTo(AboutPage.routeName, (_) => AboutPage()),
                    icon: Icon(AIcons.info),
                    label: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.aboutPageTitle),
                        FutureBuilder<bool>(
                          future: _newVersionLoader,
                          builder: (context, snapshot) {
                            final newVersion = snapshot.data == true;
                            final badgeSize = 8.0 * MediaQuery.textScaleFactorOf(context);
                            return AnimatedOpacity(
                              duration: Durations.newsBadgeAnimation,
                              opacity: newVersion ? 1 : 0,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(start: 2),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white70),
                                    borderRadius: BorderRadius.circular(badgeSize),
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: badgeSize,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => goTo(SettingsPage.routeName, (_) => SettingsPage()),
                    icon: Icon(AIcons.settings),
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

  Widget _buildSpecialAlbumSection() {
    return StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) {
          final specialAlbums = source.rawAlbums.where((album) {
            final type = androidFileUtils.getAlbumType(album);
            return [AlbumType.camera, AlbumType.screenshots].contains(type);
          }).toList()
            ..sort(source.compareAlbumsByName);

          if (specialAlbums.isEmpty) return SizedBox.shrink();
          return Column(
            children: [
              Divider(),
              ...specialAlbums.map((album) => AlbumTile(album)),
            ],
          );
        });
  }

  // tiles

  Widget get allCollectionTile => CollectionNavTile(
        leading: Icon(AIcons.allCollection),
        title: context.l10n.drawerCollectionAll,
        filter: null,
      );

  Widget get videoTile => CollectionNavTile(
        leading: Icon(AIcons.video),
        title: context.l10n.drawerCollectionVideos,
        filter: MimeFilter.video,
      );

  Widget get favouriteTile => CollectionNavTile(
        leading: Icon(AIcons.favourite),
        title: context.l10n.drawerCollectionFavourites,
        filter: FavouriteFilter.instance,
      );

  Widget get albumListTile => NavTile(
        icon: AIcons.album,
        title: context.l10n.albumPageTitle,
        trailing: StreamBuilder(
          stream: source.eventBus.on<AlbumsChangedEvent>(),
          builder: (context, _) => Text('${source.rawAlbums.length}'),
        ),
        routeName: AlbumListPage.routeName,
        pageBuilder: (_) => AlbumListPage(),
      );

  Widget get countryListTile => NavTile(
        icon: AIcons.location,
        title: context.l10n.countryPageTitle,
        trailing: StreamBuilder(
          stream: source.eventBus.on<CountriesChangedEvent>(),
          builder: (context, _) => Text('${source.sortedCountries.length}'),
        ),
        routeName: CountryListPage.routeName,
        pageBuilder: (_) => CountryListPage(),
      );

  Widget get tagListTile => NavTile(
        icon: AIcons.tag,
        title: context.l10n.tagPageTitle,
        trailing: StreamBuilder(
          stream: source.eventBus.on<TagsChangedEvent>(),
          builder: (context, _) => Text('${source.sortedTags.length}'),
        ),
        routeName: TagListPage.routeName,
        pageBuilder: (_) => TagListPage(),
      );

  Widget get debugTile => NavTile(
        icon: AIcons.debug,
        title: 'Debug',
        topLevel: false,
        routeName: AppDebugPage.routeName,
        pageBuilder: (_) => AppDebugPage(),
      );
}
