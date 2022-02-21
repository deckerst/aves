import 'package:flutter/foundation.dart';

class AnalysisController {
  final bool canStartService, force;
  final List<int>? entryIds;
  final ValueNotifier<bool> stopSignal;

  AnalysisController({
    this.canStartService = true,
    this.entryIds,
    this.force = false,
    ValueNotifier<bool>? stopSignal,
  }) : stopSignal = stopSignal ?? ValueNotifier(false);

  bool get isStopping => stopSignal.value;
}
