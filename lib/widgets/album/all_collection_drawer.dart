import 'dart:ui';

import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/album/filtered_collection_page.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class AllCollectionDrawer extends StatefulWidget {
  const AllCollectionDrawer();

  @override
  _AllCollectionDrawerState createState() => _AllCollectionDrawerState();
}

class _AllCollectionDrawerState extends State<AllCollectionDrawer> {
  bool _regularAlbumsExpanded = false, _tagsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<CollectionLens>(context);
    final source = collection.source;

    final header = DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 44,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: SvgPicture.asset(
                      'assets/aves_logo.svg',
                      width: 64,
                    ),
                  ),
                ),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(OMIcons.photoLibrary),
                  const SizedBox(width: 4),
                  Text('${collection.imageCount}'),
                ]),
                Row(children: [
                  const Icon(OMIcons.videoLibrary),
                  const SizedBox(width: 4),
                  Text('${collection.videoCount}'),
                ]),
                Row(children: [
                  const Icon(OMIcons.photoAlbum),
                  const SizedBox(width: 4),
                  Text('${source.albumCount}'),
                ]),
              ],
            ),
          ],
        ),
      ),
    );

    final videoEntry = _FilteredCollectionNavTile(
      collection: collection,
      leading: const Icon(OMIcons.videoLibrary),
      title: 'Videos',
      filter: VideoFilter(),
    );
    final buildAlbumEntry = (album) => _FilteredCollectionNavTile(
          collection: collection,
          leading: IconUtils.getAlbumIcon(context, album),
          title: CollectionSource.getUniqueAlbumName(album, source.sortedAlbums),
          dense: true,
          filter: AlbumFilter(album),
        );
    final buildTagEntry = (tag) => _FilteredCollectionNavTile(
          collection: collection,
          leading: Icon(
            OMIcons.label,
            color: stringToColor(tag),
          ),
          title: tag,
          dense: true,
          filter: TagFilter(tag),
        );

    final regularAlbums = [], appAlbums = [], specialAlbums = [];
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

    final tags = source.sortedTags;

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
                children: [
                  header,
                  videoEntry,
                  if (specialAlbums.isNotEmpty) ...[
                    const Divider(),
                    ...specialAlbums.map(buildAlbumEntry),
                  ],
                  if (appAlbums.isNotEmpty) ...[
                    const Divider(),
                    ...appAlbums.map(buildAlbumEntry),
                  ],
                  if (regularAlbums.isNotEmpty)
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
                              '${regularAlbums.length}',
                              style: TextStyle(
                                color: (_regularAlbumsExpanded ? Theme.of(context).accentColor : Colors.white).withOpacity(.6),
                              ),
                            ),
                          ],
                        ),
                        onExpansionChanged: (expanded) => setState(() => _regularAlbumsExpanded = expanded),
                        children: regularAlbums.map(buildAlbumEntry).toList(),
                      ),
                    ),
                  if (tags.isNotEmpty)
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: ExpansionTile(
                        leading: const Icon(OMIcons.label),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilteredCollectionNavTile extends StatelessWidget {
  final CollectionLens collection;
  final Widget leading;
  final String title;
  final bool dense;
  final CollectionFilter filter;

  const _FilteredCollectionNavTile({
    @required this.collection,
    @required this.leading,
    @required this.title,
    bool dense,
    @required this.filter,
  }) : this.dense = dense ?? false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: leading,
        title: Text(title),
        dense: dense,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilteredCollectionPage(
                collection: collection,
                filter: filter,
                title: title,
              ),
            ),
          );
        },
      ),
    );
  }
}
