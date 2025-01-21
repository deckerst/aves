import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/debug/overlay.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:provider/provider.dart';

class DebugGeneralSection extends StatefulWidget {
  const DebugGeneralSection({super.key});

  @override
  State<DebugGeneralSection> createState() => _DebugGeneralSectionState();
}

class _DebugGeneralSectionState extends State<DebugGeneralSection> with AutomaticKeepAliveClientMixin {
  static OverlayEntry? _taskQueueOverlayEntry;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            _taskQueueOverlayEntry
              ?..remove()
              ..dispose();
            _taskQueueOverlayEntry = null;
            if (v) {
              _taskQueueOverlayEntry = OverlayEntry(
                builder: (context) => const DebugTaskQueueOverlay(),
              );
              Overlay.of(context).insert(_taskQueueOverlayEntry!);
            }
            setState(() {});
          },
          title: const Text('Show tasks overlay'),
        ),
        SettingsSwitchListTile(
          selector: (context, s) => s.debugShowViewerTiles,
          onChanged: (v) => settings.debugShowViewerTiles = v,
          title: 'Show viewer tiles',
        ),
        ElevatedButton(
          onPressed: () => LeakTracking.collectLeaks().then((leaks) {
            const config = LeakDiagnosticConfig(
              collectRetainingPathForNotGCed: true,
              collectStackTraceOnStart: true,
              collectStackTraceOnDisposal: true,
            );
            LeakTracking.phase = const PhaseSettings(
              leakDiagnosticConfig: config,
            );
            debugPrint('Setup leak tracking phase with config=$config');
          }),
          child: const Text('Setup leak tracking phase'),
        ),
        ElevatedButton(
          onPressed: () => LeakTracking.collectLeaks().then((leaks) {
            leaks.byType.forEach((type, reports) {
              // ignore `notGCed` and `gcedLate` for now
              if (type != LeakType.notDisposed) return;

              debugPrint('* leak type=$type');
              groupBy(reports, (report) => report.type).forEach((reportType, typedReports) {
                debugPrint('  * report type=$reportType');
                groupBy(typedReports, (report) => report.trackedClass).forEach((trackedClass, classedReports) {
                  debugPrint('    trackedClass=$trackedClass reports=${classedReports.length}');
                  classedReports.forEach((report) {
                    final phase = report.phase;
                    final retainingPath = report.retainingPath;
                    final detailedPath = report.detailedPath;
                    final context = report.context;
                    if (phase != null || retainingPath != null || detailedPath != null || context != null) {
                      debugPrint('      phase=$phase retainingPath=$retainingPath detailedPath=$detailedPath context=$context');
                    }
                  });
                });
              });
            });
          }),
          child: const Text('Collect leaks'),
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

  @override
  bool get wantKeepAlive => true;
}
