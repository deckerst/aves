import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:flutter/material.dart';

typedef _SectionPredicate = Future<List<SettingsTile>> Function(BuildContext context, SettingsSection section);

class SettingsSearchDelegate extends AvesSearchDelegate {
  final List<SettingsSection> sections;

  static const pageRouteName = '/settings/search';

  SettingsSearchDelegate({
    required super.searchFieldLabel,
    required super.searchFieldStyle,
    required this.sections,
  }) : super(
         routeName: pageRouteName,
       );

  @override
  Widget buildSuggestions(BuildContext context) {
    final upQuery = query.toUpperCase().trim();
    _SectionPredicate testSection;
    if (query.trim().isEmpty) {
      final recentSettingKeys = settings.recentSettingKeys;
      testSection = (context, section) async {
        final allTiles = await section.tiles(context);
        final filteredTiles = allTiles.where((v) => v.settingKeys.any(recentSettingKeys.contains)).toList();
        return filteredTiles;
      };
    } else {
      bool testTitle(String key) => key.toUpperCase().contains(upQuery);
      testSection = (context, section) async {
        final allTiles = await section.tiles(context);
        final filteredTiles = testTitle(section.title(context)) ? allTiles : allTiles.where((v) => testTitle(v.title(context))).toList();
        return filteredTiles;
      };
    }

    final loader = Future.wait(
      sections.map((section) async {
        List<SettingsTile> filteredTiles = await testSection(context, section);
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
      }),
    );

    return MediaQueryDataProvider(
      child: SafeArea(
        child: FutureBuilder<List<List<Widget> Function(BuildContext)?>>(
          future: loader,
          builder: (context, snapshot) {
            final loaders = snapshot.data;
            if (loaders == null) return const SizedBox();

            final children = loaders.nonNulls.expand((builder) => builder(context)).toList();
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
}
