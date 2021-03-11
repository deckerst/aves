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
  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) {
        String toMultiline(Iterable l) => l.isNotEmpty ? '\n${l.join('\n')}' : '$l';
        return AvesExpansionTile(
          title: 'Settings',
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () => settings.reset(),
                child: Text('Reset'),
              ),
            ),
            SwitchListTile(
              value: settings.hasAcceptedTerms,
              onChanged: (v) => settings.hasAcceptedTerms = v,
              title: Text('hasAcceptedTerms'),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: InfoRowGroup({
                'tileExtent - Collection': '${settings.getTileExtent(CollectionPage.routeName)}',
                'tileExtent - Albums': '${settings.getTileExtent(AlbumListPage.routeName)}',
                'tileExtent - Countries': '${settings.getTileExtent(CountryListPage.routeName)}',
                'tileExtent - Tags': '${settings.getTileExtent(TagListPage.routeName)}',
                'infoMapZoom': '${settings.infoMapZoom}',
                'pinnedFilters': toMultiline(settings.pinnedFilters),
                'hiddenFilters': toMultiline(settings.hiddenFilters),
                'searchHistory': toMultiline(settings.searchHistory),
                'lastVersionCheckDate': '${settings.lastVersionCheckDate}',
                'locale': '${settings.locale}',
                'systemLocale': '${WidgetsBinding.instance.window.locale}',
              }),
            ),
          ],
        );
      },
    );
  }
}
