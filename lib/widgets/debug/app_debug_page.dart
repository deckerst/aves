import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/debug/android_apps.dart';
import 'package:aves/widgets/debug/android_dirs.dart';
import 'package:aves/widgets/debug/android_env.dart';
import 'package:aves/widgets/debug/cache.dart';
import 'package:aves/widgets/debug/database.dart';
import 'package:aves/widgets/debug/firebase.dart';
import 'package:aves/widgets/debug/overlay.dart';
import 'package:aves/widgets/debug/settings.dart';
import 'package:aves/widgets/debug/storage.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppDebugPage extends StatefulWidget {
  static const routeName = '/debug';

  final CollectionSource source;

  const AppDebugPage({this.source});

  @override
  State<StatefulWidget> createState() => _AppDebugPageState();
}

class _AppDebugPageState extends State<AppDebugPage> {
  CollectionSource get source => widget.source;

  Set<AvesEntry> get visibleEntries => source.visibleEntries;

  static OverlayEntry _taskQueueOverlayEntry;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Debug'),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(8),
            children: [
              _buildGeneralTabView(),
              DebugAndroidAppSection(),
              DebugAndroidDirSection(),
              DebugAndroidEnvironmentSection(),
              DebugCacheSection(),
              DebugAppDatabaseSection(),
              DebugFirebaseSection(),
              DebugSettingsSection(),
              DebugStorageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTabView() {
    final catalogued = visibleEntries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final located = withGps.where((entry) => entry.isLocated);
    return AvesExpansionTile(
      title: 'General',
      children: [
        Padding(
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
                builder: (context) => DebugTaskQueueOverlay(),
              );
              Overlay.of(context).insert(_taskQueueOverlayEntry);
            } else {
              _taskQueueOverlayEntry = null;
            }
            setState(() {});
          },
          title: Text('Show tasks overlay'),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(
            {
              'All entries': '${source.allEntries.length}',
              'Visible entries': '${visibleEntries.length}',
              'Catalogued': '${catalogued.length}',
              'With GPS': '${withGps.length}',
              'With address': '${located.length}',
            },
          ),
        ),
      ],
    );
  }
}
