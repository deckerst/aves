import 'package:flutter/foundation.dart';

class AnalysisController {
  final bool canStartService, force;
  final ValueNotifier<bool> stopSignal;

  AnalysisController({
    this.canStartService = true,
    this.force = false,
    ValueNotifier<bool>? stopSignal,
  }) : stopSignal = stopSignal ?? ValueNotifier(false);

  bool get isStopping => stopSignal.value;
}
