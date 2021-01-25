import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:flutter/material.dart';

class EntryViewerPage extends StatelessWidget {
  static const routeName = '/viewer';

  final CollectionLens collection;
  final AvesEntry initialEntry;

  const EntryViewerPage({
    Key key,
    this.collection,
    this.initialEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: collection != null
            ? AnimatedBuilder(
                animation: collection,
                builder: (context, child) => EntryViewerStack(
                  collection: collection,
                  initialEntry: initialEntry,
                ),
              )
            : EntryViewerStack(
                initialEntry: initialEntry,
              ),
        backgroundColor: Navigator.canPop(context) ? Colors.transparent : Colors.black,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
