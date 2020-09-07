import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/collection/search/search_delegate.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final CollectionSource source;

  const SearchButton(this.source);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('search-button'),
      icon: Icon(AIcons.search),
      onPressed: () => _goToSearch(context),
    );
  }

  void _goToSearch(BuildContext context) {
    Navigator.push(
        context,
        SearchPageRoute(
          delegate: ImageSearchDelegate(
            source: source,
          ),
        ));
  }
}
