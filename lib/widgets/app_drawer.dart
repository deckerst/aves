import 'dart:ui';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:aves/widgets/filter_grid_page.dart';
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
        padding: const EdgeInsets.all(16),
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
                    const AvesLogo(size: 64),
                    const Text(
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

    final allMediaEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(AIcons.allMedia),
      title: 'All media',
      filter: null,
    );
    final videoEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(AIcons.video),
      title: 'Videos',
      filter: MimeFilter(MimeTypes.ANY_VIDEO),
    );
    final favouriteEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(AIcons.favourite),
      title: 'Favourites',
      filter: FavouriteFilter(),
    );
    final aboutEntry = SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: const Icon(AIcons.info),
        title: const Text('About'),
        onTap: () => _goToAbout(context),
      ),
    );

    final drawerItems = <Widget>[
      header,
      allMediaEntry,
      videoEntry,
      favouriteEntry,
      _buildSpecialAlbumSection(),
      const Divider(),
      _buildRegularAlbumSection(),
      _buildCountrySection(),
      _buildTagSection(),
      const Divider(),
      aboutEntry,
      if (kDebugMode) ...[
        const Divider(),
        SafeArea(
          top: false,
          bottom: false,
          child: ListTile(
            leading: const Icon(AIcons.debug),
            title: const Text('Debug'),
            onTap: () => _goToDebug(context),
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
          ? const Icon(
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
            return type != AlbumType.regular && type != AlbumType.app;
          });

          if (specialAlbums.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const Divider(),
              ...specialAlbums.map((album) => _buildAlbumEntry(album, dense: false)),
            ],
          );
        });
  }

  Widget _buildRegularAlbumSection() {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: const Icon(AIcons.album),
        title: const Text('Albums'),
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
        onTap: () => _goToAlbums(context),
      ),
    );
  }

  Widget _buildCountrySection() {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: const Icon(AIcons.location),
        title: const Text('Countries'),
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
        onTap: () => _goToCountries(context),
      ),
    );
  }

  Widget _buildTagSection() {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: const Icon(AIcons.tag),
        title: const Text('Tags'),
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
        onTap: () => _goToTags(context),
      ),
    );
  }

  void _goToAlbums(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterNavigationPage(
          source: source,
          title: 'Albums',
          filterEntries: source.getAlbumEntries(),
          filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
          emptyBuilder: () => const EmptyContent(
            icon: AIcons.album,
            text: 'No albums',
          ),
        ),
      ),
    );
  }

  void _goToCountries(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterNavigationPage(
          source: source,
          title: 'Countries',
          filterEntries: source.getCountryEntries(),
          filterBuilder: (s) => LocationFilter(LocationLevel.country, s),
          emptyBuilder: () => const EmptyContent(
            icon: AIcons.location,
            text: 'No countries',
          ),
        ),
      ),
    );
  }

  void _goToTags(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterNavigationPage(
          source: source,
          title: 'Tags',
          filterEntries: source.getTagEntries(),
          filterBuilder: (s) => TagFilter(s),
          emptyBuilder: () => const EmptyContent(
            icon: AIcons.tag,
            text: 'No tags',
          ),
        ),
      ),
    );
  }

  void _goToAbout(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(),
      ),
    );
  }

  void _goToDebug(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebugPage(
          source: source,
        ),
      ),
    );
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
