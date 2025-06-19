import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugSettingsSection extends StatefulWidget {
  const DebugSettingsSection({super.key});

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
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: InfoRowGroup(
                info: {
                  'catalogTimeZoneRawOffsetMillis': '${settings.catalogTimeZoneOffsetMillis}',
                  'tileExtent - Collection': '${settings.getTileExtent(CollectionPage.routeName)}',
                  'tileExtent - Albums': '${settings.getTileExtent(AlbumListPage.routeName)}',
                  'tileExtent - Countries': '${settings.getTileExtent(CountryListPage.routeName)}',
                  'tileExtent - Places': '${settings.getTileExtent(PlaceListPage.routeName)}',
                  'tileExtent - Tags': '${settings.getTileExtent(TagListPage.routeName)}',
                  'mapStyle': '${settings.mapStyle}',
                  'infoMapZoom': '${settings.infoMapZoom}',
                  'customMapStyles': toMultiline(settings.customMapStyles),
                  'collectionSelectionQuickActions': '${settings.collectionSelectionQuickActions}',
                  'viewerQuickActions': '${settings.viewerQuickActions}',
                  'drawerTypeBookmarks': toMultiline(settings.drawerTypeBookmarks),
                  'drawerAlbumBookmarks': toMultiline(settings.drawerAlbumBookmarks),
                  'drawerPageBookmarks': toMultiline(settings.drawerPageBookmarks),
                  'pinnedFilters': toMultiline(settings.pinnedFilters),
                  'hiddenFilters': toMultiline(settings.hiddenFilters),
                  'deactivatedHiddenFilters': toMultiline(settings.deactivatedHiddenFilters),
                  'searchHistory': toMultiline(settings.searchHistory),
                  'recentDestinationAlbums': toMultiline(settings.recentDestinationAlbums),
                  'recentTags': toMultiline(settings.recentTags),
                  'locale': '${settings.locale}',
                  'systemLocales': '${WidgetsBinding.instance.platformDispatcher.locales}',
                  'topEntryIds': '${settings.topEntryIds}',
                  'longPressTimeout': '${settings.longPressTimeout}',
                  'albumGroups': toMultiline(settings.albumGroups.entries),
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
