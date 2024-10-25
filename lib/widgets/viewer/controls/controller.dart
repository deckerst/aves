import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/viewer/controls/cast.dart';
import 'package:aves/widgets/viewer/controls/events.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leak_tracker/leak_tracker.dart';

class ViewerController with CastMixin {
  final ValueNotifier<AvesEntry?> entryNotifier = ValueNotifier(null);
  final ViewerTransition transition;
  final Duration? autopilotInterval;
  final bool autopilotAnimatedZoom;
  final bool repeat;

  late final ScaleLevel _initialScale;
  late final ValueNotifier<bool> _autopilotNotifier;
  Timer? _playTimer;
  final StreamController _streamController = StreamController.broadcast();
  final Map<TickerProvider, _AutopilotAnimators> _autopilotAnimators = {};
  ScaleLevel? _autopilotInitialScale;

  Stream<dynamic> get _events => _streamController.stream;

  Stream<ViewerShowNextEvent> get showNextCommands => _events.where((event) => event is ViewerShowNextEvent).cast<ViewerShowNextEvent>();

  Stream<ViewerOverlayToggleEvent> get overlayCommands => _events.where((event) => event is ViewerOverlayToggleEvent).cast<ViewerOverlayToggleEvent>();

  bool get autopilot => _autopilotNotifier.value;

  set autopilot(bool enabled) => _autopilotNotifier.value = enabled;

  ScaleLevel get initialScale => _autopilotInitialScale ?? _initialScale;

  static final _autopilotScaleTweens = [
    Tween<double>(begin: 1, end: 1.2),
    Tween<double>(begin: 1.2, end: 1),
  ];

  ViewerController({
    ScaleLevel initialScale = const ScaleLevel(ref: ScaleReference.contained),
    this.transition = ViewerTransition.parallax,
    this.repeat = false,
    bool autopilot = false,
    this.autopilotInterval,
    this.autopilotAnimatedZoom = false,
  }) {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$ViewerController',
        object: this,
      );
    }
    _initialScale = initialScale;
    entryNotifier.addListener(_onEntryChanged);
    _autopilotNotifier = ValueNotifier(autopilot);
    _autopilotNotifier.addListener(_onAutopilotChanged);
    _onAutopilotChanged();
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    entryNotifier.removeListener(_onEntryChanged);
    windowService.setHdrColorMode(false);
    _autopilotNotifier.dispose();
    _clearAutopilotAnimations();
    _stopPlayTimer();
    _streamController.close();
  }

  Future<void> _onEntryChanged() async {
    if (await windowService.supportsHdr()) {
      final enabled = entryNotifier.value?.isHdr ?? false;
      await windowService.setHdrColorMode(enabled);
    }
  }

  void _onAutopilotChanged() {
    _clearAutopilotAnimations();
    _stopPlayTimer();
    if (autopilot && autopilotInterval != null) {
      _playTimer = Timer.periodic(autopilotInterval!, (_) => _streamController.add(ViewerShowNextEvent()));
      _streamController.add(const ViewerOverlayToggleEvent(visible: false));
    }
  }

  void _stopPlayTimer() => _playTimer?.cancel();

  void _clearAutopilotAnimations() => _autopilotAnimators.keys.toSet().forEach((v) => stopAutopilotAnimation(vsync: v));

  void stopAutopilotAnimation({required TickerProvider vsync}) {
    final animationController = _autopilotAnimators.remove(vsync);
    return animationController?.dispose();
  }

  void startAutopilotAnimation({
    required TickerProvider vsync,
    required void Function({required ScaleLevel scaleLevel}) onUpdate,
  }) {
    stopAutopilotAnimation(vsync: vsync);
    if (!autopilot || !autopilotAnimatedZoom) return;

    final scaleLevelRef = _initialScale.ref;
    final scaleFactorTween = _autopilotScaleTweens[Random().nextInt(_autopilotScaleTweens.length)];
    _autopilotInitialScale = ScaleLevel(ref: scaleLevelRef, factor: scaleFactorTween.begin!);

    final animationController = AnimationController(
      duration: autopilotInterval,
      vsync: vsync,
    );
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    );
    animationController.addListener(() {
      return onUpdate.call(
        scaleLevel: ScaleLevel(
          ref: scaleLevelRef,
          factor: scaleFactorTween.evaluate(animation),
        ),
      );
    });
    _autopilotAnimators[vsync] = _AutopilotAnimators(
      controller: animationController,
      animation: animation,
    );
    Future.delayed(ADurations.viewerHorizontalPageAnimation).then((_) => _autopilotAnimators[vsync]?.controller.forward());
  }
}

class _AutopilotAnimators {
  final AnimationController controller;
  final CurvedAnimation animation;

  _AutopilotAnimators({
    required this.controller,
    required this.animation,
  });

  void dispose() {
    animation.dispose();
    controller.dispose();
  }
}
