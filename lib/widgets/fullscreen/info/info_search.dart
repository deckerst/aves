import 'package:aves/model/image_entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/fullscreen/info/metadata/metadata_dir_tile.dart';
import 'package:aves/widgets/fullscreen/info/metadata/metadata_section.dart';
import 'package:flutter/material.dart';

class InfoSearchDelegate extends SearchDelegate {
  final ImageEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;

  Map<String, MetadataDirectory> get metadata => metadataNotifier.value;

  static const suggestions = {
    'Date & time': 'date or time or when',
    'Description': 'abtract or description or comment',
    'Dimensions': 'width or height or dimension or framesize',
    'Resolution': 'resolution',
    'Rights': 'rights or copyright or artist or creator or by-line or credit',
  };

  InfoSearchDelegate({
    @required this.entry,
    @required this.metadataNotifier,
  }) : super(
          searchFieldLabel: 'Search metadata',
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => Navigator.pop(context),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(AIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) => ListView(
        children: suggestions.entries
            .map((kv) => ListTile(
                  title: Text(kv.key),
                  onTap: () {
                    query = kv.value;
                    showResults(context);
                  },
                ))
            .toList(),
      );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      showSuggestions(context);
      return SizedBox();
    }

    final effectiveQueries = query.toUpperCase().split(' OR ').map((query) => query.trim());
    bool testKey(String key) => effectiveQueries.any(key.toUpperCase().contains);
    final filteredMetadata = Map.fromEntries(metadata.entries.map((kv) {
      final filteredDir = kv.value.filterKeys(testKey);
      return MapEntry(kv.key, filteredDir);
    }));

    final tiles = filteredMetadata.entries
        .where((kv) => kv.value.tags.isNotEmpty)
        .map((kv) => MetadataDirTile(
              entry: entry,
              title: kv.key,
              dir: kv.value,
              initiallyExpanded: true,
              showPrefixChildren: false,
            ))
        .toList();
    return tiles.isEmpty
        ? EmptyContent(
            icon: AIcons.info,
            text: 'No matching keys',
          )
        : ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) => tiles[index],
            itemCount: tiles.length,
          );
  }
}
