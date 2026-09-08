import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class DebugSettingsSection extends StatefulWidget {
  const new({super.key});

  @override
  State<DebugSettingsSection> createState() => _DebugSettingsSectionState();
}

class _DebugSettingsSectionState extends State<DebugSettingsSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<Settings>(
      builder: (context, settings, child) {
        String toMultiline(Iterable? l) => l != null && l.isNotEmpty ? '\n${l.join('\n')}' : '$l';
        return AvesExpansionTile(
          title: 'Settings',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () => settings.reset(includeInternalKeys: true),
                child: const Text('Reset (all store)'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () => settings.reset(includeInternalKeys: false),
                child: const Text('Reset (user preferences)'),
              ),
            ),
            SwitchListTile(
              value: settings.hasAcceptedTerms,
              onChanged: (v) => settings.hasAcceptedTerms = v,
              title: const Text('hasAcceptedTerms'),
            ),
            SwitchListTile(
              value: settings.canUseAnalysisService,
              onChanged: (v) => settings.canUseAnalysisService = v,
              title: const Text('canUseAnalysisService'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'catalogTimeZoneRawOffsetMillis': '${settings.catalogTimeZoneOffsetMillis}',
                  'collectionSelectionQuickActions': '${settings.collectionSelectionQuickActions}',
                  'viewerQuickActions': '${settings.viewerQuickActions}',
                  'pinnedFilters': toMultiline(settings.pinnedFilters),
                  'hiddenFilters': toMultiline(settings.hiddenFilters),
                  'deactivatedHiddenFilters': toMultiline(settings.deactivatedHiddenFilters),
                  'topEntryIds': '${settings.topEntryIds}',
                  'longPressTimeout': '${settings.longPressTimeout}',
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: HighlightTitle(title: 'Drawer'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'drawerTypeBookmarks': toMultiline(settings.drawerTypeBookmarks),
                  'drawerAlbumBookmarks': toMultiline(settings.drawerAlbumBookmarks),
                  'drawerPageBookmarks': toMultiline(settings.drawerPageBookmarks),
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: HighlightTitle(title: 'Groups'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'albumGroups': toMultiline(settings.albumGroups.entries),
                  'tagGroups': toMultiline(settings.tagGroups.entries),
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: HighlightTitle(title: 'History'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'recentSettingKeys': toMultiline(settings.recentSettingKeys),
                  'searchHistory': toMultiline(settings.searchHistory),
                  'recentDestinationAlbums': toMultiline(settings.recentDestinationAlbums),
                  'recentTags': toMultiline(settings.recentTags),
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: HighlightTitle(title: 'Locale'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'basic': '${settings.basicLocale}',
                  'resolved': '${settings.resolvedLocale}',
                  'aves': '${settings.avesLocale}',
                  'system': '${WidgetsBinding.instance.platformDispatcher.locales}',
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: HighlightTitle(title: 'Map'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'mapStyle': '${settings.mapStyle}',
                  'infoMapZoom': '${settings.infoMapZoom}',
                  'customMapStyles': toMultiline(settings.customMapStyles),
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: HighlightTitle(title: 'Tile Extent'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: InfoRowGroup(
                info: {
                  'collection': '${settings.getTileExtent(CollectionPage.routeName)}',
                  'albums': '${settings.getTileExtent(AlbumListPage.routeName)}',
                  'countries': '${settings.getTileExtent(CountryListPage.routeName)}',
                  'places': '${settings.getTileExtent(PlaceListPage.routeName)}',
                  'tags': '${settings.getTileExtent(TagListPage.routeName)}',
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
