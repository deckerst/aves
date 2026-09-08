import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:material_ui/material_ui.dart';

typedef _SectionPredicate = List<SettingsTile> Function(BuildContext context, SettingsSection section);

class SettingsSearchDelegate extends AvesSearchDelegate {
  final List<SettingsSection> sections;

  static const pageRouteName = '/settings/search';

  new({
    required super.searchFieldLabel,
    required super.searchFieldStyle,
    required this.sections,
  }) : super(
         routeName: pageRouteName,
       );

  @override
  Widget buildSuggestions(BuildContext context) {
    final upQuery = query.toUpperCase().trim();
    final sectionTileMapLoader = Future.wait(
      sections.map((section) async {
        final tiles = await section.tiles(context);
        return MapEntry(section, tiles);
      }),
    );

    return MediaQueryDataProvider(
      child: SafeArea(
        child: FutureBuilder<List<MapEntry<SettingsSection, List<SettingsTile>>>>(
          future: sectionTileMapLoader,
          builder: (context, snapshot) {
            final sectionTileMapEntries = snapshot.data;
            if (sectionTileMapEntries == null) return const SizedBox();

            final sectionTileMap = Map.fromEntries(sectionTileMapEntries);

            _SectionPredicate testSection;
            if (upQuery.isEmpty) {
              // select tiles for recently changed settings
              final allRecentSettingKeys = settings.recentSettingKeys;
              final keyTakeCount = _findOptimalRecentSettingKeyTakeCount(
                allRecentSettingKeys: allRecentSettingKeys,
                sectionTileMap: sectionTileMap,
                targetTileCount: 3,
              );
              final mostRecentSettingKeys = allRecentSettingKeys.take(keyTakeCount).toList();
              testSection = (context, section) {
                final allTiles = sectionTileMap[section] ?? [];
                return allTiles.where((v) => v.settingKeys.any(mostRecentSettingKeys.contains)).toList();
              };
            } else {
              // select tiles by title text
              bool testTitle(String key) => key.toUpperCase().contains(upQuery);
              testSection = (context, section) {
                final allTiles = sectionTileMap[section] ?? [];
                return testTitle(section.title(context)) ? allTiles : allTiles.where((v) => testTitle(v.title(context))).toList();
              };
            }

            final children = sections.expand((section) {
              List<SettingsTile> filteredTiles = testSection(context, section);
              if (filteredTiles.isEmpty) return <Widget>[];

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
            }).toList();

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

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  int _findOptimalRecentSettingKeyTakeCount({
    required List<String> allRecentSettingKeys,
    required Map<SettingsSection, List<SettingsTile>> sectionTileMap,
    required int targetTileCount,
  }) {
    var found = false;
    final allCount = allRecentSettingKeys.length;
    var takeCount = targetTileCount;
    while (takeCount < allCount && !found) {
      final mostRecentSettingKeys = allRecentSettingKeys.take(takeCount).toList();
      final tileCount = sectionTileMap.keys.expand((section) {
        final allTiles = sectionTileMap[section] ?? [];
        return allTiles.where((v) => v.settingKeys.any(mostRecentSettingKeys.contains)).toList();
      }).length;
      found = tileCount >= targetTileCount;
      if (!found) {
        takeCount++;
      }
    }
    return takeCount;
  }
}
