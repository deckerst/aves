import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/viewer/info/embedded/embedded_data_opener.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class InfoSearchDelegate extends AvesSearchDelegate {
  final AvesEntry entry;
  final ValueNotifier<Map<String, MetadataDirectory>> metadataNotifier;
  final bool isSelecting;

  Map<String, MetadataDirectory> get metadata => metadataNotifier.value;

  static const pageRouteName = '/info/search';

  InfoSearchDelegate({
    required super.searchFieldLabel,
    required super.searchFieldStyle,
    required this.entry,
    required this.metadataNotifier,
    required this.isSelecting,
  }) : super(
          routeName: pageRouteName,
        );

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => Navigator.maybeOf(context)?.pop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(AIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: context.l10n.clearTooltip,
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final l10n = context.l10n;
    final suggestions = {
      l10n.viewerInfoSearchSuggestionDate: 'date or time or when -timer -uptime -exposure -timeline -verbatim',
      l10n.viewerInfoSearchSuggestionDescription: 'description or title or comment or textual or abstract or object name -line',
      l10n.viewerInfoSearchSuggestionDimensions: 'width or height or dimension or framesize or imagelength',
      l10n.viewerInfoSearchSuggestionResolution: 'resolution',
      l10n.viewerInfoSearchSuggestionRights: 'rights or copyright or attribution or license or artist or creator or by-line or credit -tool',
    };
    return ListView(
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
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      showSuggestions(context);
      return const SizedBox();
    }

    final queryParts = query.toUpperCase().split(' ')..removeWhere((s) => s.isEmpty);
    final queryExcludeIncludeGroups = groupBy<String, bool>(queryParts, (s) => s.startsWith('-'));
    final queryExcludeAll = (queryExcludeIncludeGroups[true] ?? []).map((s) => s.substring(1));
    final queryIncludeAny = (queryExcludeIncludeGroups[false] ?? []).join(' ').split(' OR ');

    bool testKey(String key) {
      key = key.toUpperCase();
      return queryIncludeAny.any(key.contains) && queryExcludeAll.every((q) => !key.contains(q));
    }

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
              showThumbnails: false,
            ))
        .toList();
    return MediaQueryDataProvider(
      child: SafeArea(
        child: tiles.isEmpty
            ? EmptyContent(
                icon: AIcons.info,
                text: context.l10n.viewerInfoSearchEmpty,
              )
            : EmbeddedDataOpener(
                enabled: !isSelecting,
                entry: entry,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) => tiles[index],
                  itemCount: tiles.length,
                ),
              ),
      ),
    );
  }
}
