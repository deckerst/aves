import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class ImageSearchDelegate extends SearchDelegate<ImageEntry> {
  final CollectionLens collection;

  ImageSearchDelegate(this.collection);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: Icon(OMIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      showSuggestions(context);
      return const SizedBox.shrink();
    }
    return MediaQueryDataProvider(
      child: ChangeNotifierProvider<CollectionLens>.value(
        value: CollectionLens(
          source: collection.source,
          filters: [QueryFilter(query.toLowerCase())],
          groupFactor: collection.groupFactor,
          sortFactor: collection.sortFactor,
        ),
        child: ThumbnailCollection(
          emptyBuilder: (context) => _EmptyContent(),
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF607D8B);
    return Align(
      alignment: const FractionalOffset(.5, .4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            OMIcons.photo,
            size: 64,
            color: color,
          ),
          SizedBox(height: 16),
          Text(
            'No match',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontFamily: 'Concourse',
            ),
          ),
        ],
      ),
    );
  }
}
