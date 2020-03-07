import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
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
              floating: true,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
