import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final CollectionSource source;
  final CollectionLens parentCollection;

  const SearchButton(this.source, {this.parentCollection});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('search-button'),
      icon: Icon(AIcons.search),
      onPressed: () => _goToSearch(context),
      tooltip: 'Search',
    );
  }

  void _goToSearch(BuildContext context) {
    Navigator.push(
        context,
        SearchPageRoute(
          delegate: ImageSearchDelegate(
            source: source,
            parentCollection: parentCollection,
          ),
        ));
  }
}
