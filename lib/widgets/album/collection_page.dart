import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/collection_app_bar.dart';
import 'package:aves/widgets/album/collection_drawer.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatelessWidget {
  final CollectionLens collection;

  const CollectionPage(this.collection);

  @override
  Widget build(BuildContext context) {
    debugPrint('$runtimeType build');
    return MediaQueryDataProvider(
      child: ChangeNotifierProvider<CollectionLens>.value(
        value: collection,
        child: Scaffold(
          body: CollectionPageBody(),
          drawer: CollectionDrawer(
            source: collection.source,
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }
}

class CollectionPageBody extends StatelessWidget {
  final ValueNotifier<PageState> _stateNotifier = ValueNotifier(PageState.browse);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_stateNotifier.value == PageState.search) {
          _stateNotifier.value = PageState.browse;
          return SynchronousFuture(false);
        }
        return SynchronousFuture(true);
      },
      child: ThumbnailCollection(
        appBar: CollectionAppBar(
          stateNotifier: _stateNotifier,
        ),
      ),
    );
  }
}

enum PageState { browse, search }
