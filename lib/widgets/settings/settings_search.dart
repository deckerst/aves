import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SettingsSearchDelegate extends SearchDelegate {
  final List<SettingsSection> sections;

  SettingsSearchDelegate({
    required String searchFieldLabel,
    required this.sections,
  }) : super(
          searchFieldLabel: searchFieldLabel,
        );

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
  Widget buildSuggestions(BuildContext context) => const SizedBox();

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      showSuggestions(context);
      return const SizedBox();
    }

    final upQuery = query.toUpperCase().trim();

    bool testKey(String key) => key.toUpperCase().contains(upQuery);

    final loader = Future.wait(sections.map((section) async {
      final allTiles = await section.tiles(context);
      final filteredTiles = testKey(section.title(context)) ? allTiles : allTiles.where((v) => testKey(v.title(context))).toList();
      if (filteredTiles.isEmpty) return null;

      return (context) {
        return <Widget>[
          Padding(
            // match header layout in Settings page
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                section.icon(context),
                const SizedBox(width: 8),
                Expanded(
                  child: HighlightTitle(
                    title: section.title(context),
                    showHighlight: false,
                  ),
                ),
              ],
            ),
          ),
          ...filteredTiles.map((v) => v.build(context)),
        ];
      };
    }));

    return MediaQueryDataProvider(
      child: SafeArea(
        child: FutureBuilder<List<List<Widget> Function(BuildContext)?>>(
          future: loader,
          builder: (context, snapshot) {
            final loaders = snapshot.data;
            if (loaders == null) return const SizedBox();

            final children = loaders.whereNotNull().expand((builder) => builder(context)).toList();
            return children.isEmpty
                ? EmptyContent(
                    icon: AIcons.settings,
                    text: context.l10n.settingsSearchEmpty,
                  )
                : ListView(
                    padding: const EdgeInsets.all(8),
                    children: children,
                  );
          },
        ),
      ),
    );
  }
}
