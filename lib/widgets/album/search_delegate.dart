import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:flutter/material.dart';

class ImageSearchDelegate extends SearchDelegate<ImageEntry> {
  final List<ImageEntry> entries;

  ImageSearchDelegate(this.entries);

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
    final matches = entries.where((entry) => entry.search(lowerQuery)).toList();
    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No match',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ThumbnailCollection(entries: matches);
  }
}
