import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/all_collection_page.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/stats.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class FilteredCollectionPage extends StatelessWidget {
  final CollectionLens collection;
  final CollectionFilter filter;
  final String title;

  FilteredCollectionPage({Key key, CollectionLens collection, this.filter, this.title})
      : this.collection = CollectionLens.from(collection, filter),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: ChangeNotifierProvider<CollectionLens>.value(
          value: collection,
          child: ThumbnailCollection(
            appBar: SliverAppBar(
              title: Text(title),
              actions: _buildActions(),
              floating: true,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  static List<Widget> _buildActions() {
    return [
      Builder(
        builder: (context) => Consumer<CollectionLens>(
          builder: (context, collection, child) => PopupMenuButton<AlbumAction>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AlbumAction.stats,
                child: MenuRow(text: 'Stats', icon: OMIcons.pieChart),
              ),
            ],
            onSelected: (action) => _onActionSelected(context, collection, action),
          ),
        ),
      ),
    ];
  }

  static void _onActionSelected(BuildContext context, CollectionLens collection, AlbumAction action) {
    switch (action) {
      case AlbumAction.stats:
        _goToStats(context, collection);
        break;
      default:
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
