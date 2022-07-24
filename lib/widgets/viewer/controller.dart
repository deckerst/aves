import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:flutter/widgets.dart';

class ViewerController {
  final ValueNotifier<AvesEntry?> entryNotifier = ValueNotifier(null);
  final ScaleLevel initialScale;
  final ViewerTransition transition;
  final Duration? autopilotInterval;
  final bool repeat;

  late final ValueNotifier<bool> _autopilotNotifier;
  Timer? _playTimer;
  final StreamController _streamController = StreamController.broadcast();

  Stream<dynamic> get _events => _streamController.stream;

  Stream<ViewerShowNextEvent> get showNextCommands => _events.where((event) => event is ViewerShowNextEvent).cast<ViewerShowNextEvent>();

  Stream<ViewerOverlayToggleEvent> get overlayCommands => _events.where((event) => event is ViewerOverlayToggleEvent).cast<ViewerOverlayToggleEvent>();

  bool get autopilot => _autopilotNotifier.value;

  set autopilot(bool enabled) => _autopilotNotifier.value = enabled;

  ViewerController({
    this.initialScale = const ScaleLevel(ref: ScaleReference.contained),
    this.transition = ViewerTransition.parallax,
    this.repeat = false,
    bool autopilot = false,
    this.autopilotInterval,
  }) {
    _autopilotNotifier = ValueNotifier(autopilot);
    _autopilotNotifier.addListener(_onAutopilotChange);
    _onAutopilotChange();
  }

  void dispose() {
    _autopilotNotifier.removeListener(_onAutopilotChange);
    _stopPlayTimer();
    _streamController.close();
  }

  void _stopPlayTimer() {
    _playTimer?.cancel();
  }

  void _onAutopilotChange() {
    _stopPlayTimer();
    if (autopilot && autopilotInterval != null) {
      _playTimer = Timer.periodic(autopilotInterval!, (_) => _streamController.add(ViewerShowNextEvent()));
      _streamController.add(const ViewerOverlayToggleEvent(visible: false));
    }
  }
}

@immutable
class ViewerShowNextEvent {}

@immutable
class ViewerOverlayToggleEvent {
  final bool? visible;

  const ViewerOverlayToggleEvent({required this.visible});
}

class PageTransitionEffects {
  static TransitionBuilder fade(
    PageController pageController,
    int index, {
    required bool zoomIn,
  }) =>
      (context, child) {
        double opacity = 0;
        double dx = 0;
        double scale = 1;
        if (pageController.hasClients && pageController.position.haveDimensions) {
          final position = (pageController.page! - index).clamp(-1.0, 1.0);
          final width = pageController.position.viewportDimension;
          opacity = (1 - position.abs()).clamp(0, 1);
          dx = position * width;
          if (zoomIn) {
            scale = 1 + position;
          }
        }
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      };

  static TransitionBuilder slide(
    PageController pageController,
    int index, {
    required bool parallax,
  }) =>
      (context, child) {
        double dx = 0;
        if (pageController.hasClients && pageController.position.haveDimensions) {
          final position = (pageController.page! - index).clamp(-1.0, 1.0);
          final width = pageController.position.viewportDimension;
          if (parallax) {
            dx = position * width / 2;
          }
        }
        return ClipRect(
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          ),
        );
      };
}
