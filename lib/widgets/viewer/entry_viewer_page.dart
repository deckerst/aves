import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:flutter/material.dart';

class MultiEntryViewerPage extends AnimatedWidget {
  static const routeName = '/viewer';

  final CollectionLens collection;
  final ImageEntry initialEntry;

  const MultiEntryViewerPage({
    Key key,
    this.collection,
    this.initialEntry,
  }) : super(key: key, listenable: collection);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: EntryViewerStack(
          collection: collection,
          initialEntry: initialEntry,
        ),
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class SingleEntryViewerPage extends StatelessWidget {
  static const routeName = '/viewer';

  final ImageEntry entry;

  const SingleEntryViewerPage({
    Key key,
    this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: EntryViewerStack(
          initialEntry: entry,
        ),
        backgroundColor: Navigator.canPop(context) ? Colors.transparent : Colors.black,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
