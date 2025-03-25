import 'dart:io';

import 'package:aves/ref/locales.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leak_tracker/leak_tracker.dart';

class DebugLeakingSection extends StatefulWidget {
  const DebugLeakingSection({super.key});

  @override
  State<DebugLeakingSection> createState() => _DebugLeakingSectionState();
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
          child: const Text('Track leaks with stacks'),
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
          child: const Text('Track leaks without stacks'),
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
  AlignmentGeometry _alignment = AlignmentDirectional.bottomStart;

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _alignment = _alignment == AlignmentDirectional.bottomStart ? AlignmentDirectional.topStart : AlignmentDirectional.bottomStart),
                      icon: Icon(_alignment == AlignmentDirectional.bottomStart ? Icons.vertical_align_top_outlined : Icons.vertical_align_bottom_outlined),
                    ),
                    ...LeakType.values.map((type) {
                      return OutlinedButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.all(6)),
                          minimumSize: WidgetStateProperty.all(Size.zero),
                        ),
                        onPressed: () => LeakTracking.collectLeaks().then((leaks) {
                          final reports = leaks.byType[type] ?? [];
                          _printLeaks(type, reports);
                        }),
                        child: Text(type.name),
                      );
                    }),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final currentRss = formatFileSize(asciiLocale, ProcessInfo.currentRss);
                        final maxRss = formatFileSize(asciiLocale, ProcessInfo.maxRss);
                        return Text('RSS: $currentRss / $maxRss');
                      },
                    ),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final currentImageCache = formatFileSize(asciiLocale, imageCache.currentSizeBytes);
                        final maxImageCache = formatFileSize(asciiLocale, imageCache.maximumSizeBytes);
                        return Text('imageCache: $currentImageCache / $maxImageCache');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _printLeaks(LeakType type, List<LeakReport> reports) {
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
