import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/material.dart';

class CollectionSearchButton extends StatelessWidget {
  final CollectionSource source;
  final CollectionLens? parentCollection;

  const CollectionSearchButton({
    Key? key,
    required this.source,
    this.parentCollection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(AIcons.search),
      onPressed: () => _goToSearch(context),
      tooltip: MaterialLocalizations.of(context).searchFieldLabel,
    );
  }

  void _goToSearch(BuildContext context) {
    Navigator.push(
      context,
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          source: source,
          parentCollection: parentCollection,
        ),
      ),
    );
  }
}
