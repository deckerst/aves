import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

class AnalysisController {
  final bool canStartService, force;
  final int progressTotal, progressOffset;
  final List<int>? entryIds;

  final ValueNotifier<bool> _stopSignal = ValueNotifier(false);

  AnalysisController({
    this.canStartService = true,
    this.entryIds,
    this.force = false,
    this.progressTotal = 0,
    this.progressOffset = 0,
  }) {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$AnalysisController',
        object: this,
      );
    }
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    _stopSignal.dispose();
  }

  bool get isStopping => _stopSignal.value;

  void enableStopSignal() => _stopSignal.value = true;
}
