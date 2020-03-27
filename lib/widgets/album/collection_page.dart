import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/collection_app_bar.dart';
import 'package:aves/widgets/album/collection_drawer.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatelessWidget {
  final CollectionLens collection;

  const CollectionPage(this.collection);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: ChangeNotifierProvider<CollectionLens>.value(
        value: collection,
        child: Scaffold(
          body: ThumbnailCollection(
            appBar: AllCollectionAppBar(),
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
