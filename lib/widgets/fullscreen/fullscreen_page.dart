import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/fullscreen/fullscreen_body.dart';
import 'package:flutter/material.dart';

class MultiFullscreenPage extends AnimatedWidget {
  static const routeName = '/fullscreen';

  final CollectionLens collection;
  final ImageEntry initialEntry;

  const MultiFullscreenPage({
    Key key,
    this.collection,
    this.initialEntry,
  }) : super(key: key, listenable: collection);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: FullscreenBody(
          collection: collection,
          initialEntry: initialEntry,
        ),
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class SingleFullscreenPage extends StatelessWidget {
  static const routeName = '/fullscreen';

  final ImageEntry entry;

  const SingleFullscreenPage({
    Key key,
    this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: FullscreenBody(
          initialEntry: entry,
        ),
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
