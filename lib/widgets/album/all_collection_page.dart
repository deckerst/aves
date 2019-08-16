import 'package:aves/model/image_collection.dart';
import 'package:aves/widgets/album/search_delegate.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:flutter/material.dart';

class AllCollectionPage extends StatelessWidget {
  final ImageCollection collection;

  const AllCollectionPage({Key key, this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThumbnailCollection(
      collection: collection,
      appBar: SliverAppBar(
        title: Text('Aves - All'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ImageSearchDelegate(collection),
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
        builder: (context) => DebugPage(
          entries: collection.entries,
        ),
      ),
    );
  }
}
