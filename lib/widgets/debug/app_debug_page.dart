import 'dart:async';

import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/debug/android_apps.dart';
import 'package:aves/widgets/debug/android_codecs.dart';
import 'package:aves/widgets/debug/android_dirs.dart';
import 'package:aves/widgets/debug/app_debug_action.dart';
import 'package:aves/widgets/debug/cache.dart';
import 'package:aves/widgets/debug/database.dart';
import 'package:aves/widgets/debug/media_store_scan_dialog.dart';
import 'package:aves/widgets/debug/overlay.dart';
import 'package:aves/widgets/debug/report.dart';
import 'package:aves/widgets/debug/settings.dart';
import 'package:aves/widgets/debug/storage.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class AppDebugPage extends StatefulWidget {
  static const routeName = '/debug';

  const AppDebugPage({super.key});

  @override
  State<StatefulWidget> createState() => _AppDebugPageState();
}

class _AppDebugPageState extends State<AppDebugPage> {
  static OverlayEntry? _taskQueueOverlayEntry;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug'),
          actions: [
            MenuIconTheme(
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
                  await Future.delayed(Durations.popupMenuAnimation * timeDilation);
                  unawaited(_onActionSelected(action));
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildGeneralTabView(),
              const DebugAndroidAppSection(),
              const DebugAndroidCodecSection(),
              const DebugAndroidDirSection(),
              const DebugCacheSection(),
              const DebugAppDatabaseSection(),
              const DebugErrorReportingSection(),
              const DebugSettingsSection(),
              const DebugStorageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTabView() {
    final source = context.read<CollectionSource>();
    final visibleEntries = source.visibleEntries;
    final catalogued = visibleEntries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final withAddress = withGps.where((entry) => entry.hasAddress);
    final withFineAddress = withGps.where((entry) => entry.hasFineAddress);
    return AvesExpansionTile(
      title: 'General',
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Time dilation'),
        ),
        Slider(
          value: timeDilation,
          onChanged: (v) => setState(() => timeDilation = v),
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: '$timeDilation',
        ),
        SwitchListTile(
          value: _taskQueueOverlayEntry != null,
          onChanged: (v) {
            _taskQueueOverlayEntry?.remove();
            if (v) {
              _taskQueueOverlayEntry = OverlayEntry(
                builder: (context) => const DebugTaskQueueOverlay(),
              );
              Overlay.of(context)!.insert(_taskQueueOverlayEntry!);
            } else {
              _taskQueueOverlayEntry = null;
            }
            setState(() {});
          },
          title: const Text('Show tasks overlay'),
        ),
        ElevatedButton(
          onPressed: () => source.init(loadTopEntriesFirst: false),
          child: const Text('Source refresh (top off)'),
        ),
        ElevatedButton(
          onPressed: () => source.init(loadTopEntriesFirst: true),
          child: const Text('Source refresh (top on)'),
        ),
        ElevatedButton(
          onPressed: () => source.init(directory: '${androidFileUtils.dcimPath}/Camera'),
          child: const Text('Source refresh (camera)'),
        ),
        ElevatedButton(
          onPressed: () => source.init(directory: androidFileUtils.picturesPath),
          child: const Text('Source refresh (pictures)'),
        ),
        ElevatedButton(
          onPressed: () => AnalysisService.startService(force: false),
          child: const Text('Start analysis service'),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(
            info: {
              'All entries': '${source.allEntries.length}',
              'Visible entries': '${visibleEntries.length}',
              'Catalogued': '${catalogued.length}',
              'With GPS': '${withGps.length}',
              'With address': '${withAddress.length}',
              'With fine address': '${withFineAddress.length}',
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onActionSelected(AppDebugAction action) async {
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
        break;
      case AppDebugAction.prepScreenshotStats:
        settings.changeFilterVisibility(settings.hiddenFilters, true);
        settings.changeFilterVisibility({
          PathFilter('/storage/emulated/0/Pictures/Dev'),
        }, false);
        break;
      case AppDebugAction.mediaStoreScanDir:
        // scan files copied from test assets
        // we do it via the app instead of broadcasting via ADB
        // because `MEDIA_SCANNER_SCAN_FILE` intent got deprecated in API 29
        await showDialog<String>(
          context: context,
          builder: (context) => const MediaStoreScanDirDialog(),
        );
        break;
      case AppDebugAction.greenScreen:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Scaffold(
              backgroundColor: Colors.green,
              body: SizedBox(),
            ),
          ),
        );
        break;
    }
  }
}
