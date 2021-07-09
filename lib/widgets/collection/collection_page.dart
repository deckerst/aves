import 'package:aves/model/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatefulWidget {
  static const routeName = '/collection';

  final CollectionLens collection;

  const CollectionPage({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  CollectionLens get collection => widget.collection;

  @override
  void dispose() {
    collection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SelectionProvider<AvesEntry>(
          child: Builder(
            builder: (context) => WillPopScope(
              onWillPop: () {
                final selection = context.read<Selection<AvesEntry>>();
                if (selection.isSelecting) {
                  selection.browse();
                  return SynchronousFuture(false);
                }
                return SynchronousFuture(true);
              },
              child: DoubleBackPopScope(
                child: GestureAreaProtectorStack(
                  child: SafeArea(
                    bottom: false,
                    child: ChangeNotifierProvider<CollectionLens>.value(
                      value: collection,
                      child: const CollectionGrid(
                        key: Key('collection-grid'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        drawer: const AppDrawer(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
