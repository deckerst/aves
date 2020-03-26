import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/all_collection_app_bar.dart';
import 'package:aves/widgets/album/collection_drawer.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/stats.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatelessWidget {
  final CollectionLens collection;
  final String title;

  const CollectionPage({
    Key key,
    @required this.collection,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: ChangeNotifierProvider<CollectionLens>.value(
        value: collection,
        child: Scaffold(
          body: ThumbnailCollection(
            appBar: collection.filters.isEmpty
                ? AllCollectionAppBar()
                : SliverAppBar(
                    title: Text(title),
                    actions: _buildActions(),
                    floating: true,
                  ),
          ),
          drawer: CollectionDrawer(
            source: collection.source,
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  static List<Widget> _buildActions() {
    return [
      Builder(
        builder: (context) => Consumer<CollectionLens>(
          builder: (context, collection, child) => PopupMenuButton<CollectionAction>(
            itemBuilder: (context) => [
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

  static void _onActionSelected(BuildContext context, CollectionLens collection, CollectionAction action) {
    switch (action) {
      case CollectionAction.stats:
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
