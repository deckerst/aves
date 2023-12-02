import 'dart:async';

import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/debug/android_apps.dart';
import 'package:aves/widgets/debug/android_codecs.dart';
import 'package:aves/widgets/debug/android_dirs.dart';
import 'package:aves/widgets/debug/app_debug_action.dart';
import 'package:aves/widgets/debug/cache.dart';
import 'package:aves/widgets/debug/colors.dart';
import 'package:aves/widgets/debug/database.dart';
import 'package:aves/widgets/debug/general.dart';
import 'package:aves/widgets/debug/media_store_scan_dialog.dart';
import 'package:aves/widgets/debug/report.dart';
import 'package:aves/widgets/debug/settings.dart';
import 'package:aves/widgets/debug/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class AppDebugPage extends StatelessWidget {
  static const routeName = '/debug';

  const AppDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AvesScaffold(
        appBar: AppBar(
          title: const Text('Debug'),
          actions: [
            FontSizeIconTheme(
              child: PopupMenuButton<AppDebugAction>(
                // key is expected by test driver
                key: const Key('appbar-menu-button'),
                itemBuilder: (context) => AppDebugAction.values
                    .map((v) => PopupMenuItem(
                          // key is expected by test driver
                          key: Key('menu-${v.name}'),
                          value: v,
                          child: MenuRow(text: v.name),
                        ))
                    .toList(),
                onSelected: (action) async {
                  // wait for the popup menu to hide before proceeding with the action
                  await Future.delayed(ADurations.popupMenuAnimation * timeDilation);
                  unawaited(_onActionSelected(context, action));
                },
              ),
            ),
          ],
        ),
        body: AvesPopScope(
          handlers: const [TvNavigationPopHandler.pop],
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: const [
                DebugGeneralSection(),
                DebugAndroidAppSection(),
                DebugAndroidCodecSection(),
                DebugAndroidDirSection(),
                DebugCacheSection(),
                DebugColorSection(),
                DebugAppDatabaseSection(),
                DebugErrorReportingSection(),
                DebugSettingsSection(),
                DebugStorageSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onActionSelected(BuildContext context, AppDebugAction action) async {
    switch (action) {
      case AppDebugAction.prepScreenshotThumbnails:
        // get source beforehand, as widget may be unmounted during action handling
        final source = context.read<CollectionSource>();
        settings.changeFilterVisibility(settings.hiddenFilters, true);
        settings.changeFilterVisibility({
          TagFilter('aves-thumbnail', reversed: true),
        }, false);
        await favourites.clear();
        await favourites.add(source.visibleEntries);
      case AppDebugAction.prepScreenshotStats:
        settings.changeFilterVisibility(settings.hiddenFilters, true);
        settings.changeFilterVisibility({
          PathFilter('/storage/emulated/0/Pictures/Dev'),
        }, false);
      case AppDebugAction.prepScreenshotCountries:
        settings.changeFilterVisibility({
          LocationFilter(LocationLevel.country, 'Belgium;BE'),
        }, false);
      case AppDebugAction.mediaStoreScanDir:
        // scan files copied from test assets
        // we do it via the app instead of broadcasting via ADB
        // because `MEDIA_SCANNER_SCAN_FILE` intent got deprecated in API 29
        await showDialog<String>(
          context: context,
          builder: (context) => const MediaStoreScanDirDialog(),
        );
      case AppDebugAction.greenScreen:
        await Navigator.maybeOf(context)?.push(
          MaterialPageRoute(
            builder: (context) => const Scaffold(
              backgroundColor: Colors.green,
              body: SizedBox(),
            ),
          ),
        );
    }
  }
}
