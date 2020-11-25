import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
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
              'collectionTileExtent': '${settings.collectionTileExtent}',
              'infoMapZoom': '${settings.infoMapZoom}',
              'pinnedFilters': toMultiline(settings.pinnedFilters),
              'searchHistory': toMultiline(settings.searchHistory),
            }),
          ),
        ],
      );
    });
  }
}
