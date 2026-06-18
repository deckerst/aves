import 'dart:async';
import 'dart:io';

import 'package:aves/ref/locales.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/device_service.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leak_tracker/leak_tracker.dart';

class DebugLeakingSection extends StatefulWidget {
  const DebugLeakingSection({super.key});

  @override
  State<DebugLeakingSection> createState() => _DebugLeakingSectionState();

  static Future<void> printLeakReportsOfType(LeakType type) => LeakTracking.collectLeaks().then((leaks) {
    final reports = leaks.byType[type] ?? [];
    printLeakReport(type, reports);
  });

  static void printLeakReport(LeakType type, List<LeakReport> reports) {
    debugPrint('* leak type=$type, ${reports.length} reports');
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
  }
}

class _DebugLeakingSectionState extends State<DebugLeakingSection> with AutomaticKeepAliveClientMixin {
  static OverlayEntry? _collectorOverlayEntry;

  static const _leakIgnoreConfig = IgnoredLeaks(
    experimentalNotGCed: IgnoredLeaksSet(),
    notDisposed: IgnoredLeaksSet(),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Leaking',
      children: [
        SwitchListTile(
          value: _collectorOverlayEntry != null,
          onChanged: (v) {
            _collectorOverlayEntry
              ?..remove()
              ..dispose();
            _collectorOverlayEntry = null;
            if (v) {
              _collectorOverlayEntry = OverlayEntry(
                builder: (context) => const _CollectorOverlay(),
              );
              Overlay.of(context).insert(_collectorOverlayEntry!);
            }
            setState(() {});
          },
          title: const Text('Show leak report overlay'),
        ),
        Wrap(
          spacing: 4,
          crossAxisAlignment: .center,
          children: [
            ...LeakType.values.map((v) {
              return ElevatedButton(
                onPressed: () => DebugLeakingSection.printLeakReportsOfType(v),
                child: Text(v.name),
              );
            }),
            ElevatedButton(
              onPressed: () => LeakTracking.collectLeaks().then((leaks) {
                LeakTracking.phase = const PhaseSettings(
                  ignoredLeaks: _leakIgnoreConfig,
                  leakDiagnosticConfig: LeakDiagnosticConfig(
                    collectRetainingPathForNotGCed: true,
                    collectStackTraceOnStart: true,
                    collectStackTraceOnDisposal: true,
                  ),
                );
              }),
              child: const Text('Track w/ stacks'),
            ),
            ElevatedButton(
              onPressed: () => LeakTracking.collectLeaks().then((leaks) {
                LeakTracking.phase = const PhaseSettings(
                  ignoredLeaks: _leakIgnoreConfig,
                  leakDiagnosticConfig: LeakDiagnosticConfig(
                    collectRetainingPathForNotGCed: true,
                    collectStackTraceOnStart: false,
                    collectStackTraceOnDisposal: false,
                  ),
                );
              }),
              child: const Text('Track w/o stacks'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CollectorOverlay extends StatefulWidget {
  const _CollectorOverlay();

  @override
  State<_CollectorOverlay> createState() => _CollectorOverlayState();
}

class _CollectorOverlayState extends State<_CollectorOverlay> {
  late StreamSubscription _subscription;
  final ValueNotifier<String> _ramNotifier = ValueNotifier('');
  final ValueNotifier<String> _heapNotifier = ValueNotifier('');
  final ValueNotifier<String> _rssNotifier = ValueNotifier('');
  final ValueNotifier<String> _imageCacheNotifier = ValueNotifier('');

  AlignmentGeometry _alignment = AlignmentDirectional.bottomStart;

  @override
  void initState() {
    super.initState();
    _subscription = Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      final results = await Future.wait([
        deviceService.getRamSizes(<MemorySizeType>{.available, .total, .advertised}),
        deviceService.getHeapSizes(<MemorySizeType>{.used, .total, .max}),
      ]);
      final [ram, heap] = results;

      final ramAvailable = formatFileSize(kAsciiLocale, ram[MemorySizeType.available] ?? 0);
      final ramTotal = formatFileSize(kAsciiLocale, ram[MemorySizeType.total] ?? 0);
      final ramAdvertised = formatFileSize(kAsciiLocale, ram[MemorySizeType.advertised] ?? 0);
      _ramNotifier.value = 'RAM: $ramAvailable / $ramTotal / $ramAdvertised';

      final heapUsed = formatFileSize(kAsciiLocale, heap[MemorySizeType.used] ?? 0);
      final heapTotal = formatFileSize(kAsciiLocale, heap[MemorySizeType.total] ?? 0);
      final heapMax = formatFileSize(kAsciiLocale, heap[MemorySizeType.max] ?? 0);
      _heapNotifier.value = 'Heap: $heapUsed / $heapTotal / $heapMax';

      final rssCurrent = formatFileSize(kAsciiLocale, ProcessInfo.currentRss);
      final rssMax = formatFileSize(kAsciiLocale, ProcessInfo.maxRss);
      _rssNotifier.value = 'RSS: $rssCurrent / $rssMax';

      final imageCacheCurrent = formatFileSize(kAsciiLocale, imageCache.currentSizeBytes);
      final imageCacheMax = formatFileSize(kAsciiLocale, imageCache.maximumSizeBytes);
      _imageCacheNotifier.value = 'imageCache: $imageCacheCurrent / $imageCacheMax';
    });
  }

  @override
  void dispose() {
    _ramNotifier.dispose();
    _heapNotifier.dispose();
    _rssNotifier.dispose();
    _imageCacheNotifier.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(),
      child: Align(
        alignment: _alignment,
        child: SafeArea(
          child: Container(
            color: Colors.indigo.shade900.withAlpha(0xCC),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Wrap(
                  crossAxisAlignment: .center,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _alignment = _alignment == AlignmentDirectional.bottomStart ? AlignmentDirectional.topStart : AlignmentDirectional.bottomStart),
                      icon: Icon(_alignment == AlignmentDirectional.bottomStart ? Icons.vertical_align_top_outlined : Icons.vertical_align_bottom_outlined),
                    ),
                    ...LeakType.values.map((v) {
                      return OutlinedButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.all(6)),
                          minimumSize: WidgetStateProperty.all(Size.zero),
                        ),
                        onPressed: () => DebugLeakingSection.printLeakReportsOfType(v),
                        child: Text(v.name),
                      );
                    }),
                  ],
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _heapNotifier,
                  builder: (context, v, child) => Text(v),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _rssNotifier,
                  builder: (context, v, child) => Text(v),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _ramNotifier,
                  builder: (context, v, child) => Text(v),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _imageCacheNotifier,
                  builder: (context, v, child) => Text(v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
