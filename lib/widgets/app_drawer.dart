import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/flutter_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/debug_page.dart';
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

    final allCollectionEntry = _FilteredCollectionNavTile(
      source: source,
      leading: Icon(AIcons.allCollection),
      title: 'All collection',
      filter: null,
    );
    final videoEntry = _FilteredCollectionNavTile(
      source: source,
      leading: Icon(AIcons.video),
      title: 'Videos',
      filter: MimeFilter(MimeTypes.anyVideo),
    );
    final favouriteEntry = _FilteredCollectionNavTile(
      source: source,
      leading: Icon(AIcons.favourite),
      title: 'Favourites',
      filter: FavouriteFilter(),
    );
    final settingsEntry = SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: Icon(AIcons.settings),
        title: Text('Preferences'),
        onTap: () => _goTo(SettingsPage.routeName, (_) => SettingsPage()),
      ),
    );
    final aboutEntry = SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: Icon(AIcons.info),
        title: Text('About'),
        onTap: () => _goTo(AboutPage.routeName, (_) => AboutPage()),
      ),
    );

    final drawerItems = <Widget>[
      header,
      allCollectionEntry,
      videoEntry,
      favouriteEntry,
      _buildSpecialAlbumSection(),
      Divider(),
      _buildAlbumListEntry(),
      _buildCountryListEntry(),
      _buildTagListEntry(),
      Divider(),
      settingsEntry,
      aboutEntry,
      if (kDebugMode) ...[
        Divider(),
        SafeArea(
          top: false,
          bottom: false,
          child: ListTile(
            leading: Icon(AIcons.debug),
            title: Text('Debug'),
            onTap: () => _goTo(DebugPage.routeName, (_) => DebugPage(source: source)),
          ),
        ),
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

  Widget _buildAlbumEntry(String album, {bool dense = true}) {
    final uniqueName = source.getUniqueAlbumName(album);
    return _FilteredCollectionNavTile(
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
      dense: dense,
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
              ...specialAlbums.map((album) => _buildAlbumEntry(album, dense: false)),
            ],
          );
        });
  }

  Widget _buildAlbumListEntry() {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        key: Key('albums-tile'),
        leading: Icon(AIcons.album),
        title: Text('Albums'),
        trailing: StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) {
              return Text(
                '${source.sortedAlbums.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(.6),
                ),
              );
            }),
        onTap: () => _goTo(AlbumListPage.routeName, (_) => AlbumListPage(source: source)),
      ),
    );
  }

  Widget _buildCountryListEntry() {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: Icon(AIcons.location),
        title: Text('Countries'),
        trailing: StreamBuilder(
            stream: source.eventBus.on<LocationsChangedEvent>(),
            builder: (context, snapshot) {
              return Text(
                '${source.sortedCountries.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(.6),
                ),
              );
            }),
        onTap: () => _goTo(CountryListPage.routeName, (_) => CountryListPage(source: source)),
      ),
    );
  }

  Widget _buildTagListEntry() {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: Icon(AIcons.tag),
        title: Text('Tags'),
        trailing: StreamBuilder(
            stream: source.eventBus.on<TagsChangedEvent>(),
            builder: (context, snapshot) {
              return Text(
                '${source.sortedTags.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(.6),
                ),
              );
            }),
        onTap: () => _goTo(TagListPage.routeName, (_) => TagListPage(source: source)),
      ),
    );
  }

  void _goTo(String routeName, WidgetBuilder builder) {
    Navigator.pop(context);
    if (routeName != context.currentRouteName) {
      Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: builder,
          ));
    }
  }
}

class _FilteredCollectionNavTile extends StatelessWidget {
  final CollectionSource source;
  final Widget leading;
  final String title;
  final Widget trailing;
  final bool dense;
  final CollectionFilter filter;

  const _FilteredCollectionNavTile({
    @required this.source,
    @required this.leading,
    @required this.title,
    this.trailing,
    bool dense,
    @required this.filter,
  }) : dense = dense ?? false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: leading,
        title: Text(title),
        trailing: trailing,
        dense: dense,
        onTap: () => _goToCollection(context),
      ),
    );
  }

  void _goToCollection(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(CollectionLens(
          source: source,
          filters: [filter],
          groupFactor: settings.collectionGroupFactor,
          sortFactor: settings.collectionSortFactor,
        )),
      ),
      (route) => false,
    );
  }
}
