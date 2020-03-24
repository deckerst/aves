import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/widgets/album/search_delegate.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/debug_page.dart';
import 'package:aves/widgets/stats.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:pedantic/pedantic.dart';
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

class _AllCollectionAppBar extends SliverAppBar {
  _AllCollectionAppBar()
      : super(
          title: const Text('All'),
          actions: _buildActions(),
          floating: true,
        );

  static List<Widget> _buildActions() {
    return [
      Builder(
        builder: (context) => Consumer<CollectionLens>(
          builder: (context, collection, child) => IconButton(
            icon: Icon(OMIcons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ImageSearchDelegate(collection),
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => Consumer<CollectionLens>(
          builder: (context, collection, child) => PopupMenuButton<AlbumAction>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AlbumAction.sortByDate,
                child: MenuRow(text: 'Sort by date', checked: collection.sortFactor == SortFactor.date),
              ),
              PopupMenuItem(
                value: AlbumAction.sortBySize,
                child: MenuRow(text: 'Sort by size', checked: collection.sortFactor == SortFactor.size),
              ),
              PopupMenuItem(
                value: AlbumAction.sortByName,
                child: MenuRow(text: 'Sort by name', checked: collection.sortFactor == SortFactor.name),
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
                value: AlbumAction.stats,
                child: MenuRow(text: 'Stats', icon: OMIcons.pieChart),
              ),
              PopupMenuItem(
                value: AlbumAction.debug,
                child: MenuRow(text: 'Debug', icon: OMIcons.whatshot),
              ),
            ],
            onSelected: (action) => _onActionSelected(context, collection, action),
          ),
        ),
      ),
    ];
  }

  static void _onActionSelected(BuildContext context, CollectionLens collection, AlbumAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(const Duration(milliseconds: 300));
    switch (action) {
      case AlbumAction.debug:
        unawaited(_goToDebug(context, collection));
        break;
      case AlbumAction.stats:
        unawaited(_goToStats(context, collection));
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
      case AlbumAction.sortByName:
        settings.collectionSortFactor = SortFactor.name;
        collection.sort(SortFactor.name);
        break;
    }
  }

  static Future _goToDebug(BuildContext context, CollectionLens collection) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebugPage(
          entries: collection.sortedEntries,
        ),
      ),
    );
  }

  static Future _goToStats(BuildContext context, CollectionLens collection) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsPage(
          collection: collection,
        ),
      ),
    );
  }
}

enum AlbumAction { debug, stats, groupByAlbum, groupByMonth, groupByDay, sortByDate, sortBySize, sortByName }
