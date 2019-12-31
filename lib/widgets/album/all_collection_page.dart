import 'package:aves/model/image_collection.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/widgets/album/search_delegate.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class AllCollectionPage extends StatelessWidget {
  const AllCollectionPage();

  @override
  Widget build(BuildContext context) {
    debugPrint('$runtimeType build');
    return ThumbnailCollection(
      appBar: _AllCollectionAppBar(),
    );
  }
}

class _AllCollectionAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collection = Provider.of<ImageCollection>(context);
    return SliverAppBar(
      title: const Text('All'),
      actions: [
        IconButton(
          icon: Icon(OMIcons.search),
          onPressed: () => showSearch(
            context: context,
            delegate: ImageSearchDelegate(collection),
          ),
        ),
        PopupMenuButton<AlbumAction>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: AlbumAction.sortByDate,
              child: MenuRow(text: 'Sort by date', checked: collection.sortFactor == SortFactor.date),
            ),
            PopupMenuItem(
              value: AlbumAction.sortBySize,
              child: MenuRow(text: 'Sort by size', checked: collection.sortFactor == SortFactor.size),
            ),
            const PopupMenuDivider(),
            if (collection.sortFactor == SortFactor.date) ...[
              PopupMenuItem(
                value: AlbumAction.groupByAlbum,
                child: MenuRow(text: 'Group by album', checked: collection.groupFactor == GroupFactor.album),
              ),
              PopupMenuItem(
                value: AlbumAction.groupByMonth,
                child: MenuRow(text: 'Group by month', checked: collection.groupFactor == GroupFactor.month),
              ),
              PopupMenuItem(
                value: AlbumAction.groupByDay,
                child: MenuRow(text: 'Group by day', checked: collection.groupFactor == GroupFactor.day),
              ),
              const PopupMenuDivider(),
            ],
            PopupMenuItem(
              value: AlbumAction.debug,
              child: MenuRow(text: 'Debug', icon: OMIcons.whatshot),
            ),
          ],
          onSelected: (action) => _onActionSelected(context, collection, action),
        ),
      ],
      floating: true,
    );
  }

  void _onActionSelected(BuildContext context, ImageCollection collection, AlbumAction action) {
    switch (action) {
      case AlbumAction.debug:
        _goToDebug(context, collection);
        break;
      case AlbumAction.groupByAlbum:
        settings.collectionGroupFactor = GroupFactor.album;
        collection.group(GroupFactor.album);
        break;
      case AlbumAction.groupByMonth:
        settings.collectionGroupFactor = GroupFactor.month;
        collection.group(GroupFactor.month);
        break;
      case AlbumAction.groupByDay:
        settings.collectionGroupFactor = GroupFactor.day;
        collection.group(GroupFactor.day);
        break;
      case AlbumAction.sortByDate:
        settings.collectionSortFactor = SortFactor.date;
        collection.sort(SortFactor.date);
        break;
      case AlbumAction.sortBySize:
        settings.collectionSortFactor = SortFactor.size;
        collection.sort(SortFactor.size);
        break;
    }
  }

  Future _goToDebug(BuildContext context, ImageCollection collection) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebugPage(
          entries: collection.sortedEntries,
        ),
      ),
    );
  }
}

enum AlbumAction { debug, groupByAlbum, groupByMonth, groupByDay, sortByDate, sortBySize }
