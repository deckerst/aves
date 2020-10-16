import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/app_debug_page.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:aves/widgets/common/icons.dart';
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
  final CollectionSource source;

  const AppDrawer({@required this.source});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  CollectionSource get source => widget.source;

  @override
  Widget build(BuildContext context) {
    final header = Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        color: Theme.of(context).accentColor,
        child: SafeArea(
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
                        fontFamily: 'Concourse Caps',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final drawerItems = <Widget>[
      header,
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
        selector: (c, mq) => mq.viewInsets.bottom,
        builder: (c, mqViewInsetsBottom, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: mqViewInsetsBottom),
            child: Theme(
              data: Theme.of(context).copyWith(
                // color used by `ExpansionTile` for leading icon
                unselectedWidgetColor: Colors.white,
              ),
              child: Column(
                children: drawerItems,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumTile(String album) {
    final uniqueName = source.getUniqueAlbumName(album);
    return CollectionNavTile(
      source: source,
      leading: IconUtils.getAlbumIcon(context: context, album: album),
      title: uniqueName,
      trailing: androidFileUtils.isOnRemovableStorage(album)
          ? Icon(
              AIcons.removableStorage,
              size: 16,
              color: Colors.grey,
            )
          : null,
      filter: AlbumFilter(album, uniqueName),
    );
  }

  Widget _buildSpecialAlbumSection() {
    return StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) {
          final specialAlbums = source.sortedAlbums.where((album) {
            final type = androidFileUtils.getAlbumType(album);
            return [AlbumType.camera, AlbumType.screenshots].contains(type);
          });

          if (specialAlbums.isEmpty) return SizedBox.shrink();
          return Column(
            children: [
              Divider(),
              ...specialAlbums.map(_buildAlbumTile),
            ],
          );
        });
  }

  // tiles

  Widget get allCollectionTile => CollectionNavTile(
        source: source,
        leading: Icon(AIcons.allCollection),
        title: 'All collection',
        filter: null,
      );

  Widget get videoTile => CollectionNavTile(
        source: source,
        leading: Icon(AIcons.video),
        title: 'Videos',
        filter: MimeFilter(MimeTypes.anyVideo),
      );

  Widget get favouriteTile => CollectionNavTile(
        source: source,
        leading: Icon(AIcons.favourite),
        title: 'Favourites',
        filter: FavouriteFilter(),
      );

  Widget get albumListTile => NavTile(
        icon: AIcons.album,
        title: 'Albums',
        trailing: StreamBuilder(
          stream: source.eventBus.on<AlbumsChangedEvent>(),
          builder: (context, _) => Text('${source.sortedAlbums.length}'),
        ),
        routeName: AlbumListPage.routeName,
        pageBuilder: (_) => AlbumListPage(source: source),
      );

  Widget get countryListTile => NavTile(
        icon: AIcons.location,
        title: 'Countries',
        trailing: StreamBuilder(
          stream: source.eventBus.on<LocationsChangedEvent>(),
          builder: (context, _) => Text('${source.sortedCountries.length}'),
        ),
        routeName: CountryListPage.routeName,
        pageBuilder: (_) => CountryListPage(source: source),
      );

  Widget get tagListTile => NavTile(
        icon: AIcons.tag,
        title: 'Tags',
        trailing: StreamBuilder(
          stream: source.eventBus.on<TagsChangedEvent>(),
          builder: (context, _) => Text('${source.sortedTags.length}'),
        ),
        routeName: TagListPage.routeName,
        pageBuilder: (_) => TagListPage(source: source),
      );

  Widget get settingsTile => NavTile(
        icon: AIcons.settings,
        title: 'Settings',
        topLevel: false,
        routeName: SettingsPage.routeName,
        pageBuilder: (_) => SettingsPage(),
      );

  Widget get aboutTile => NavTile(
        icon: AIcons.info,
        title: 'About',
        topLevel: false,
        routeName: AboutPage.routeName,
        pageBuilder: (_) => AboutPage(),
      );

  Widget get debugTile => NavTile(
        icon: AIcons.debug,
        title: 'Debug',
        topLevel: false,
        routeName: AppDebugPage.routeName,
        pageBuilder: (_) => AppDebugPage(source: source),
      );
}
