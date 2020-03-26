import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/widgets/album/search_delegate.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/stats.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class AllCollectionAppBar extends SliverAppBar {
  AllCollectionAppBar()
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
          builder: (context, collection, child) => PopupMenuButton<CollectionAction>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CollectionAction.sortByDate,
                child: MenuRow(text: 'Sort by date', checked: collection.sortFactor == SortFactor.date),
              ),
              PopupMenuItem(
                value: CollectionAction.sortBySize,
                child: MenuRow(text: 'Sort by size', checked: collection.sortFactor == SortFactor.size),
              ),
              PopupMenuItem(
                value: CollectionAction.sortByName,
                child: MenuRow(text: 'Sort by name', checked: collection.sortFactor == SortFactor.name),
              ),
              const PopupMenuDivider(),
              if (collection.sortFactor == SortFactor.date) ...[
                PopupMenuItem(
                  value: CollectionAction.groupByAlbum,
                  child: MenuRow(text: 'Group by album', checked: collection.groupFactor == GroupFactor.album),
                ),
                PopupMenuItem(
                  value: CollectionAction.groupByMonth,
                  child: MenuRow(text: 'Group by month', checked: collection.groupFactor == GroupFactor.month),
                ),
                PopupMenuItem(
                  value: CollectionAction.groupByDay,
                  child: MenuRow(text: 'Group by day', checked: collection.groupFactor == GroupFactor.day),
                ),
                const PopupMenuDivider(),
              ],
              PopupMenuItem(
                value: CollectionAction.stats,
                child: MenuRow(text: 'Stats', icon: OMIcons.pieChart),
              ),
            ],
            onSelected: (action) => _onActionSelected(context, collection, action),
          ),
        ),
      ),
    ];
  }

  static void _onActionSelected(BuildContext context, CollectionLens collection, CollectionAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(const Duration(milliseconds: 300));
    switch (action) {
      case CollectionAction.stats:
        unawaited(_goToStats(context, collection));
        break;
      case CollectionAction.groupByAlbum:
        settings.collectionGroupFactor = GroupFactor.album;
        collection.group(GroupFactor.album);
        break;
      case CollectionAction.groupByMonth:
        settings.collectionGroupFactor = GroupFactor.month;
        collection.group(GroupFactor.month);
        break;
      case CollectionAction.groupByDay:
        settings.collectionGroupFactor = GroupFactor.day;
        collection.group(GroupFactor.day);
        break;
      case CollectionAction.sortByDate:
        settings.collectionSortFactor = SortFactor.date;
        collection.sort(SortFactor.date);
        break;
      case CollectionAction.sortBySize:
        settings.collectionSortFactor = SortFactor.size;
        collection.sort(SortFactor.size);
        break;
      case CollectionAction.sortByName:
        settings.collectionSortFactor = SortFactor.name;
        collection.sort(SortFactor.name);
        break;
    }
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

enum CollectionAction { stats, groupByAlbum, groupByMonth, groupByDay, sortByDate, sortBySize, sortByName }
