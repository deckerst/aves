import 'dart:ui';

import 'package:aves/model/availability.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/about/news_badge.dart';
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
    final drawerItems = <Widget>[
      _buildHeader(context),
      allCollectionTile,
      videoTile,
      favouriteTile,
      _buildSpecialAlbumSection(),
      Divider(),
      albumListTile,
      countryListTile,
      tagListTile,
      Divider(),
      settingsTile,
      aboutTile,
      if (kDebugMode) ...[
        Divider(),
        debugTile,
      ],
    ];

    return Drawer(
      child: Selector<MediaQueryData, double>(
        selector: (c, mq) => mq.effectiveBottomPadding,
        builder: (c, mqPaddingBottom, child) {
          final iconTheme = IconTheme.of(context);
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: mqPaddingBottom),
            child: Theme(
              data: Theme.of(context).copyWith(
                // color used by `ExpansionTile` for leading icon
                unselectedWidgetColor: Colors.white,
              ),
              child: IconTheme(
                data: iconTheme.copyWith(size: iconTheme.size * MediaQuery.textScaleFactorOf(context)),
                child: Column(
                  children: drawerItems,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
                    'Aves',
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
        title: 'All collection',
        filter: null,
      );

  Widget get videoTile => CollectionNavTile(
        leading: Icon(AIcons.video),
        title: 'Videos',
        filter: MimeFilter(MimeTypes.anyVideo),
      );

  Widget get favouriteTile => CollectionNavTile(
        leading: Icon(AIcons.favourite),
        title: 'Favourites',
        filter: FavouriteFilter(),
      );

  Widget get albumListTile => NavTile(
        icon: AIcons.album,
        title: 'Albums',
        trailing: StreamBuilder(
          stream: source.eventBus.on<AlbumsChangedEvent>(),
          builder: (context, _) => Text('${source.rawAlbums.length}'),
        ),
        routeName: AlbumListPage.routeName,
        pageBuilder: (_) => AlbumListPage(),
      );

  Widget get countryListTile => NavTile(
        icon: AIcons.location,
        title: 'Countries',
        trailing: StreamBuilder(
          stream: source.eventBus.on<CountriesChangedEvent>(),
          builder: (context, _) => Text('${source.sortedCountries.length}'),
        ),
        routeName: CountryListPage.routeName,
        pageBuilder: (_) => CountryListPage(),
      );

  Widget get tagListTile => NavTile(
        icon: AIcons.tag,
        title: 'Tags',
        trailing: StreamBuilder(
          stream: source.eventBus.on<TagsChangedEvent>(),
          builder: (context, _) => Text('${source.sortedTags.length}'),
        ),
        routeName: TagListPage.routeName,
        pageBuilder: (_) => TagListPage(),
      );

  Widget get settingsTile => NavTile(
        icon: AIcons.settings,
        title: 'Settings',
        topLevel: false,
        routeName: SettingsPage.routeName,
        pageBuilder: (_) => SettingsPage(),
      );

  Widget get aboutTile => FutureBuilder<bool>(
        future: _newVersionLoader,
        builder: (context, snapshot) {
          final newVersion = snapshot.data == true;
          return NavTile(
            icon: AIcons.info,
            title: 'About',
            trailing: newVersion ? AboutNewsBadge() : null,
            topLevel: false,
            routeName: AboutPage.routeName,
            pageBuilder: (_) => AboutPage(),
          );
        },
      );

  Widget get debugTile => NavTile(
        icon: AIcons.debug,
        title: 'Debug',
        topLevel: false,
        routeName: AppDebugPage.routeName,
        pageBuilder: (_) => AppDebugPage(),
      );
}
