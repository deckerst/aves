import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
                builder: (context) => const _TaskQueueOverlay(),
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

class _TaskQueueOverlay extends StatelessWidget {
  const _TaskQueueOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DefaultTextStyle(
        style: const TextStyle(),
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: SafeArea(
            child: Container(
              color: Colors.indigo.shade900.withAlpha(0xCC),
              padding: const EdgeInsets.all(8),
              child: StreamBuilder<QueueState>(
                  stream: servicePolicy.queueStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const SizedBox();
                    final queuedEntries = <MapEntry<dynamic, int>>[];
                    if (snapshot.hasData) {
                      final state = snapshot.data!;
                      queuedEntries.add(MapEntry('run', state.runningCount));
                      queuedEntries.add(MapEntry('paused', state.pausedCount));
                      queuedEntries.addAll(state.queueByPriority.entries.map((kv) => MapEntry(kv.key.toString(), kv.value)));
                    }
                    queuedEntries.sort((a, b) => a.key.compareTo(b.key));
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(queuedEntries.map((kv) => '${kv.key}: ${kv.value}').join(', ')),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
