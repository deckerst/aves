import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/collection_drawer.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatelessWidget {
  final CollectionLens collection;

  final ValueNotifier<PageState> _stateNotifier = ValueNotifier(PageState.browse);

  CollectionPage(this.collection);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: ChangeNotifierProvider<CollectionLens>.value(
        value: collection,
        child: Scaffold(
          body: WillPopScope(
            onWillPop: () {
              if (_stateNotifier.value == PageState.search) {
                _stateNotifier.value = PageState.browse;
                return SynchronousFuture(false);
              }
              return SynchronousFuture(true);
            },
            child: ThumbnailCollection(
              stateNotifier: _stateNotifier,
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
}

enum PageState { browse, search }
