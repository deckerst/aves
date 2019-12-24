import 'dart:ui';

import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/filtered_collection_page.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AllCollectionDrawer extends StatelessWidget {
  final ImageCollection collection;

  const AllCollectionDrawer({Key key, this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final albums = collection.sortedAlbums;
    final tags = collection.sortedTags;
    return Drawer(
      child: Selector<MediaQueryData, double>(
        selector: (c, mq) => mq.viewInsets.bottom,
        builder: (c, mqViewInsetsBottom, child) => ListView(
          padding: EdgeInsets.only(bottom: mqViewInsetsBottom),
          children: [
            DrawerHeader(
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
                          Icon(Icons.photo_library),
                          const SizedBox(width: 4),
                          Text('${collection.imageCount}')
                        ]),
                        Row(children: [
                          Icon(Icons.video_library),
                          const SizedBox(width: 4),
                          Text('${collection.videoCount}')
                        ]),
                        Row(children: [
                          Icon(Icons.photo_album),
                          const SizedBox(width: 4),
                          Text('${collection.albumCount}')
                        ]),
                        Row(children: [
                          Icon(Icons.label),
                          const SizedBox(width: 4),
                          Text('${collection.tagCount}')
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _FilteredCollectionNavTile(
              collection: collection,
              leading: Icon(Icons.video_library),
              title: 'Videos',
              filter: (entry) => entry.isVideo,
            ),
            const Divider(),
            ...albums.map((album) => _FilteredCollectionNavTile(
                  collection: collection,
                  leading: IconUtils.getAlbumIcon(context, album) ?? Icon(Icons.photo_album),
                  title: collection.getUniqueAlbumName(album, albums),
                  filter: (entry) => entry.directory == album,
                )),
            const Divider(),
            ...tags.map((tag) => _FilteredCollectionNavTile(
                  collection: collection,
                  leading: Icon(Icons.label),
                  title: tag,
                  filter: (entry) => entry.xmpSubjects.contains(tag),
                )),
          ],
        ),
      ),
    );
  }
}

class _FilteredCollectionNavTile extends StatelessWidget {
  final ImageCollection collection;
  final Widget leading;
  final String title;
  final bool Function(ImageEntry) filter;

  const _FilteredCollectionNavTile({
    @required this.collection,
    @required this.leading,
    @required this.title,
    @required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        leading: leading,
        title: Text(title),
        dense: true,
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
