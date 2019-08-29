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
                          width: 50,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      radius: 32,
                    ),
                    SizedBox(width: 16),
                    Text('Aves',
                        style: TextStyle(
                          fontSize: 42,
                        )),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${collection.imageCount}'),
                          Text('${collection.videoCount}'),
                          Text('${collection.albumCount}'),
                          Text('${collection.tagCount}'),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('images'),
                        Text('videos'),
                        Text('albums'),
                        Text('tags'),
                      ],
                    ),
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
                leading: Icon(Icons.photo_library),
                title: album,
                filter: (entry) => entry.bucketDisplayName == album,
              )),
          Divider(),
          ...tags.map((tag) => _buildFilteredCollectionNavTile(
                context: context,
                leading: Icon(Icons.label_outline),
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
