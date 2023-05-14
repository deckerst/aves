import 'package:flutter/foundation.dart';

class AnalysisController {
  final bool canStartService, force;
  final int progressTotal, progressOffset;
  final List<int>? entryIds;
  final ValueNotifier<bool> stopSignal;

  AnalysisController({
    this.canStartService = true,
    this.entryIds,
    this.force = false,
    this.progressTotal = 0,
    this.progressOffset = 0,
    ValueNotifier<bool>? stopSignal,
  }) : stopSignal = stopSignal ?? ValueNotifier(false);

  bool get isStopping => stopSignal.value;
}
