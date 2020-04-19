import 'dart:ui';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class CollectionDrawer extends StatefulWidget {
  final CollectionSource source;

  const CollectionDrawer({@required this.source});

  @override
  _CollectionDrawerState createState() => _CollectionDrawerState();
}

class _CollectionDrawerState extends State<CollectionDrawer> {
  bool _albumsExpanded = false, _placesExpanded = false, _countriesExpanded = false, _tagsExpanded = false;

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
              Row(
                children: [
                  const AvesLogo(size: 64),
                  const SizedBox(width: 16),
                  const Text(
                    'Aves',
                    style: TextStyle(
                      fontSize: 44,
                      fontFamily: 'Concourse Caps',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final allMediaEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(OMIcons.photo),
      title: 'All media',
      filter: null,
    );
    final videoEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(AIcons.video),
      title: 'Videos',
      filter: MimeFilter(MimeTypes.ANY_VIDEO),
    );
    final animatedEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(AIcons.animated),
      title: 'Animated',
      filter: MimeFilter(MimeFilter.animated),
    );
    final favouriteEntry = _FilteredCollectionNavTile(
      source: source,
      leading: const Icon(AIcons.favourite),
      title: 'Favourites',
      filter: FavouriteFilter(),
    );
    final buildAlbumEntry = (String album) {
      final uniqueName = source.getUniqueAlbumName(album);
      return _FilteredCollectionNavTile(
        source: source,
        leading: IconUtils.getAlbumIcon(context: context, album: album),
        title: uniqueName,
        trailing: androidFileUtils.isOnSD(album)
            ? const Icon(
                OMIcons.sdStorage,
                size: 16,
                color: Colors.grey,
              )
            : null,
        dense: true,
        filter: AlbumFilter(album, uniqueName),
      );
    };
    final buildTagEntry = (String tag) => _FilteredCollectionNavTile(
          source: source,
          leading: Icon(
            AIcons.tag,
            color: stringToColor(tag),
          ),
          title: tag,
          dense: true,
          filter: TagFilter(tag),
        );
    final buildLocationEntry = (LocationLevel level, String location) {
      String title;
      String flag;
      if (level == LocationLevel.country) {
        final split = location.split(';');
        String countryCode;
        if (split.isNotEmpty) title = split[0];
        if (split.length > 1) countryCode = split[1];
        flag = LocationFilter.countryCodeToFlag(countryCode);
      } else {
        title = location;
      }
      return _FilteredCollectionNavTile(
        source: source,
        leading: flag != null
            ? Text(
                flag,
                style: TextStyle(fontSize: IconTheme.of(context).size),
              )
            : Icon(
                AIcons.location,
                color: stringToColor(title),
              ),
        title: title,
        dense: true,
        filter: LocationFilter(level, location),
      );
    };

    final regularAlbums = <String>[], appAlbums = <String>[], specialAlbums = <String>[];
    for (var album in source.sortedAlbums) {
      switch (androidFileUtils.getAlbumType(album)) {
        case AlbumType.Default:
          regularAlbums.add(album);
          break;
        case AlbumType.App:
          appAlbums.add(album);
          break;
        default:
          specialAlbums.add(album);
          break;
      }
    }
    final countries = source.sortedCountries;
    final places = source.sortedPlaces;
    final tags = source.sortedTags;

    final drawerItems = <Widget>[
      header,
      allMediaEntry,
      videoEntry,
      animatedEntry,
      favouriteEntry,
      if (specialAlbums.isNotEmpty) ...[
        const Divider(),
        ...specialAlbums.map(buildAlbumEntry),
      ],
      if (appAlbums.isNotEmpty || regularAlbums.isNotEmpty)
        SafeArea(
          top: false,
          bottom: false,
          child: ExpansionTile(
            leading: const Icon(OMIcons.photoAlbum),
            title: Row(
              children: [
                const Text('Albums'),
                const Spacer(),
                Text(
                  '${appAlbums.length + regularAlbums.length}',
                  style: TextStyle(
                    color: (_albumsExpanded ? Theme.of(context).accentColor : Colors.white).withOpacity(.6),
                  ),
                ),
              ],
            ),
            onExpansionChanged: (expanded) => setState(() => _albumsExpanded = expanded),
            children: [
              ...appAlbums.map(buildAlbumEntry),
              if (appAlbums.isNotEmpty && regularAlbums.isNotEmpty) const Divider(),
              ...regularAlbums.map(buildAlbumEntry),
            ],
          ),
        ),
      if (countries.isNotEmpty)
        SafeArea(
          top: false,
          bottom: false,
          child: ExpansionTile(
            leading: const Icon(AIcons.location),
            title: Row(
              children: [
                const Text('Countries'),
                const Spacer(),
                Text(
                  '${countries.length}',
                  style: TextStyle(
                    color: (_countriesExpanded ? Theme.of(context).accentColor : Colors.white).withOpacity(.6),
                  ),
                ),
              ],
            ),
            onExpansionChanged: (expanded) => setState(() => _countriesExpanded = expanded),
            children: countries.map((s) => buildLocationEntry(LocationLevel.country, s)).toList(),
          ),
        ),
      if (places.isNotEmpty)
        SafeArea(
          top: false,
          bottom: false,
          child: ExpansionTile(
            leading: const Icon(AIcons.location),
            title: Row(
              children: [
                const Text('Places'),
                const Spacer(),
                Text(
                  '${places.length}',
                  style: TextStyle(
                    color: (_placesExpanded ? Theme.of(context).accentColor : Colors.white).withOpacity(.6),
                  ),
                ),
              ],
            ),
            onExpansionChanged: (expanded) => setState(() => _placesExpanded = expanded),
            children: places.map((s) => buildLocationEntry(LocationLevel.place, s)).toList(),
          ),
        ),
      if (tags.isNotEmpty)
        SafeArea(
          top: false,
          bottom: false,
          child: ExpansionTile(
            leading: const Icon(AIcons.tag),
            title: Row(
              children: [
                const Text('Tags'),
                const Spacer(),
                Text(
                  '${tags.length}',
                  style: TextStyle(
                    color: (_tagsExpanded ? Theme.of(context).accentColor : Colors.white).withOpacity(.6),
                  ),
                ),
              ],
            ),
            onExpansionChanged: (expanded) => setState(() => _tagsExpanded = expanded),
            children: tags.map(buildTagEntry).toList(),
          ),
        ),
      if (kDebugMode) ...[
        const Divider(),
        SafeArea(
          top: false,
          bottom: false,
          child: ListTile(
            leading: const Icon(OMIcons.whatshot),
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
