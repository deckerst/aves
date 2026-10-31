import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/common/tiles/switch_list.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const DebugGeneralSection({super.key}) extends StatefulWidget {
  @override
  State<DebugGeneralSection> createState() => _DebugGeneralSectionState();
}

class _DebugGeneralSectionState extends State<DebugGeneralSection> with AutomaticKeepAliveClientMixin {
  static OverlayEntry? _insetsOverlayEntry;
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
      locale: KnownLocale.english,
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
          value: AvesMethodChannel.kDebug,
          onChanged: (v) => setState(() => AvesMethodChannel.kDebug = v),
          title: const Text('Trace Aves platform channels'),
        ),
        SwitchListTile(
          value: _insetsOverlayEntry != null,
          onChanged: (v) {
            _insetsOverlayEntry
              ?..remove()
              ..dispose();
            _insetsOverlayEntry = null;
            if (v) {
              _insetsOverlayEntry = OverlayEntry(
                builder: (context) => const _InsetsOverlayEntry(),
              );
              Overlay.of(context).insert(_insetsOverlayEntry!);
            }
            setState(() {});
          },
          title: const Text('Show insets overlay'),
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
          title: (_) => 'Show viewer tiles',
        ),
        ElevatedButton(
          onPressed: () => AnalysisService.startService(force: false),
          child: const Text('Start analysis service'),
        ),
        Selector<Settings, int>(
          selector: (context, s) => s.debugCatalogConcurrentTaskMax,
          builder: (context, concurrentTaskMax, child) {
            return Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Catalog max concurrent tasks ($concurrentTaskMax)'),
                ),
                Slider(
                  value: concurrentTaskMax.toDouble(),
                  onChanged: (v) => settings.debugCatalogConcurrentTaskMax = v.round(),
                  min: 1.0,
                  max: 8.0,
                  divisions: 7,
                  label: '$concurrentTaskMax',
                ),
              ],
            );
          },
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

class const _InsetsOverlayEntry() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return IgnorePointer(
      child: DefaultTextStyle(
        style: const TextStyle(),
        child: Align(
          alignment: .center,
          child: Container(
            color: Colors.indigo.shade900.withAlpha(0xCC),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                ValueListenableBuilder(
                  valueListenable: AvesApp.cutoutInsetsNotifier,
                  builder: (context, cutoutInsets, child) {
                    return Text('cutoutInsets=${_stringifyEdgeInsets(cutoutInsets)}');
                  },
                ),
                Text('displayCornerRadii=${_stringifyBorderRadius(mq.displayCornerRadii)}'),
                Text('systemGestureInsets=${_stringifyEdgeInsets(mq.systemGestureInsets)}'),
                Text('viewInsets=${_stringifyEdgeInsets(mq.viewInsets)}'),
                Text('viewPadding=${_stringifyEdgeInsets(mq.viewPadding)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // because `toString` is unusable in non-debug mode
  static String _stringifyBorderRadius(BorderRadius? radius) {
    if (radius == null) return 'null';
    final tl = radius.topLeft;
    final tr = radius.topRight;
    final bl = radius.bottomLeft;
    final br = radius.bottomRight;
    if (tl == tr && tr == bl && bl == br) {
      return 'BorderRadius(${_stringifyRadius(tl)})';
    }
    return 'BorderRadius('
        'topLeft=${_stringifyRadius(tl)}, '
        'topRight=${_stringifyRadius(tr)}, '
        'bottomLeft=${_stringifyRadius(bl)}, '
        'bottomRight=${_stringifyRadius(br)})';
  }

  // because `toString` is unusable in non-debug mode
  static String _stringifyRadius(Radius radius) {
    final x = radius.x;
    final y = radius.y;
    if (x == y) return x.toStringAsFixed(1);
    return 'Radius('
        '${x.toStringAsFixed(1)}, '
        '${y.toStringAsFixed(1)})';
  }

  // because `toString` is unusable in non-debug mode
  static String _stringifyEdgeInsets(EdgeInsets insets) {
    return 'EdgeInsets('
        '${insets.left.toStringAsFixed(1)}, '
        '${insets.top.toStringAsFixed(1)}, '
        '${insets.right.toStringAsFixed(1)}, '
        '${insets.bottom.toStringAsFixed(1)})';
  }
}

class const _TaskQueueOverlay() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DefaultTextStyle(
        style: const TextStyle(),
        child: Align(
          alignment: .bottomStart,
          child: SafeArea(
            child: Container(
              color: Colors.indigo.shade900.withAlpha(0xCC),
              padding: const EdgeInsets.all(8),
              child: StreamBuilder<QueueState>(
                stream: platformServicePolicy.queueStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const SizedBox();
                  final queuedEntries = <MapEntry<dynamic, int>>[];
                  final state = snapshot.data;
                  if (state != null) {
                    queuedEntries.add(MapEntry('run', state.runningCount));
                    queuedEntries.add(MapEntry('paused', state.pausedCount));
                    queuedEntries.addAll(state.queueByPriority.entries.map((kv) => MapEntry(kv.key.toString(), kv.value)));
                  }
                  queuedEntries.sort((a, b) => a.key.compareTo(b.key));
                  return Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .stretch,
                    children: [
                      Text(queuedEntries.map((kv) => '${kv.key}: ${kv.value}').join(', ')),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
