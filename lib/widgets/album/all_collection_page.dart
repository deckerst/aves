import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/search_delegate.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:flutter/material.dart';

class AllCollectionPage extends StatelessWidget {
  final List<ImageEntry> entries;

  const AllCollectionPage({Key key, this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThumbnailCollection(
      entries: entries,
      appBar: SliverAppBar(
        title: Text('Aves - All'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ImageSearchDelegate(entries),
            ),
          ),
          IconButton(icon: Icon(Icons.whatshot), onPressed: () => goToDebug(context)),
        ],
        floating: true,
      ),
    );
  }

  Future goToDebug(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebugPage(),
      ),
    );
  }
}
