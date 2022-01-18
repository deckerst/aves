import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugSettingsSection extends StatelessWidget {
  const DebugSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            SwitchListTile(
              value: settings.videoShowRawTimedText,
              onChanged: (v) => settings.videoShowRawTimedText = v,
              title: const Text('videoShowRawTimedText'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: InfoRowGroup(
                info: {
                  'tileExtent - Collection': '${settings.getTileExtent(CollectionPage.routeName)}',
                  'tileExtent - Albums': '${settings.getTileExtent(AlbumListPage.routeName)}',
                  'tileExtent - Countries': '${settings.getTileExtent(CountryListPage.routeName)}',
                  'tileExtent - Tags': '${settings.getTileExtent(TagListPage.routeName)}',
                  'infoMapZoom': '${settings.infoMapZoom}',
                  'collectionSelectionQuickActions': '${settings.collectionSelectionQuickActions}',
                  'viewerQuickActions': '${settings.viewerQuickActions}',
                  'videoQuickActions': '${settings.videoQuickActions}',
                  'drawerTypeBookmarks': toMultiline(settings.drawerTypeBookmarks),
                  'drawerAlbumBookmarks': toMultiline(settings.drawerAlbumBookmarks),
                  'drawerPageBookmarks': toMultiline(settings.drawerPageBookmarks),
                  'pinnedFilters': toMultiline(settings.pinnedFilters),
                  'hiddenFilters': toMultiline(settings.hiddenFilters),
                  'searchHistory': toMultiline(settings.searchHistory),
                  'locale': '${settings.locale}',
                  'systemLocales': '${WidgetsBinding.instance!.window.locales}',
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
