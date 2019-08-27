import 'package:aves/model/image_collection.dart';
import 'package:aves/widgets/album/search_delegate.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/menu_row.dart';
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
          PopupMenuButton<AlbumAction>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AlbumAction.groupByAlbum,
                child: MenuRow(text: 'Group by album', checked: collection.groupFactor == GroupFactor.album),
              ),
              PopupMenuItem(
                value: AlbumAction.groupByDate,
                child: MenuRow(text: 'Group by date', checked: collection.groupFactor == GroupFactor.date),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: AlbumAction.groupByAlbum,
                child: MenuRow(text: 'Debug', icon: Icons.whatshot),
              ),
            ],
            onSelected: (action) => onActionSelected(context, action),
          ),
        ],
        floating: true,
      ),
    );
  }

  onActionSelected(BuildContext context, AlbumAction action) {
    switch (action) {
      case AlbumAction.groupByAlbum:
        collection.group(GroupFactor.album);
        break;
      case AlbumAction.groupByDate:
        collection.group(GroupFactor.date);
        break;
      case AlbumAction.debug:
        goToDebug(context);
        break;
    }
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

enum AlbumAction { groupByDate, groupByAlbum, debug }
