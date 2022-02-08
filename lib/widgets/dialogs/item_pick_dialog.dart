import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemPickDialog extends StatefulWidget {
  static const routeName = '/item_pick';

  final CollectionLens collection;

  const ItemPickDialog({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  _ItemPickDialogState createState() => _ItemPickDialogState();
}

class _ItemPickDialogState extends State<ItemPickDialog> {
  CollectionLens get collection => widget.collection;

  @override
  void dispose() {
    collection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveFilter = collection.filters.firstWhereOrNull((v) => v is QueryFilter && v.live) as QueryFilter?;
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: ValueNotifier(AppMode.pickMediaInternal),
      child: MediaQueryDataProvider(
        child: Scaffold(
          body: SelectionProvider<AvesEntry>(
            child: QueryProvider(
              initialQuery: liveFilter?.query,
              child: GestureAreaProtectorStack(
                child: SafeArea(
                  bottom: false,
                  child: ChangeNotifierProvider<CollectionLens>.value(
                    value: collection,
                    child: const CollectionGrid(
                      settingsRouteKey: CollectionPage.routeName,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
