import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/filtered_collection_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllCollectionDrawer extends StatelessWidget {
  final ImageCollection collection;

  const AllCollectionDrawer({Key key, this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final albums = collection.albums.toList()..sort(compareAsciiUpperCaseNatural);
    final tags = collection.tags.toList()..sort(compareAsciiUpperCaseNatural);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: SvgPicture.asset(
                          'assets/aves_logo.svg',
                          width: 64,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      radius: 44,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Aves',
                      style: TextStyle(
                        fontSize: 44,
                        fontFamily: 'Concourse Caps',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [Icon(Icons.photo_library), SizedBox(width: 4), Text('${collection.imageCount}')]),
                    Row(children: [Icon(Icons.video_library), SizedBox(width: 4), Text('${collection.videoCount}')]),
                    Row(children: [Icon(Icons.photo_album), SizedBox(width: 4), Text('${collection.albumCount}')]),
                    Row(children: [Icon(Icons.label), SizedBox(width: 4), Text('${collection.tagCount}')]),
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
          ),
          _buildFilteredCollectionNavTile(
            context: context,
            leading: Icon(Icons.video_library),
            title: 'Videos',
            filter: (entry) => entry.isVideo,
          ),
          Divider(),
          ...albums.map((album) => _buildFilteredCollectionNavTile(
                context: context,
                leading: Icon(Icons.photo_album),
                title: collection.getUniqueAlbumName(album, albums),
                filter: (entry) => entry.directory == album,
              )),
          Divider(),
          ...tags.map((tag) => _buildFilteredCollectionNavTile(
                context: context,
                leading: Icon(Icons.label),
                title: tag,
                filter: (entry) => entry.xmpSubjects.contains(tag),
              )),
        ],
      ),
    );
  }

  _buildFilteredCollectionNavTile({BuildContext context, Widget leading, String title, bool Function(ImageEntry) filter}) {
    return ListTile(
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
    );
  }
}
