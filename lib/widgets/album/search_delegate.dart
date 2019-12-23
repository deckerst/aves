import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/media_query_data_provider.dart';
import 'package:flutter/material.dart';

class ImageSearchDelegate extends SearchDelegate<ImageEntry> {
  final ImageCollection collection;

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
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SizedBox.shrink();
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      showSuggestions(context);
      return SizedBox.shrink();
    }
    final lowerQuery = query.toLowerCase();
    final matches = collection.sortedEntries.where((entry) => entry.search(lowerQuery)).toList();
    if (matches.isEmpty) {
      return _EmptyContent();
    }
    return MediaQueryDataProvider(
      child: ThumbnailCollection(
        collection: ImageCollection(
          entries: matches,
          groupFactor: collection.groupFactor,
          sortFactor: collection.sortFactor,
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF607D8B);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.photo,
            size: 64,
            color: color,
          ),
          SizedBox(height: 16),
          Text(
            'No match',
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
