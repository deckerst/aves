import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_magnifier/src/pan/edge_hit_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class MagnifierGestureDetector extends StatefulWidget {
  final EdgeHitDetector hitDetector;

  final void Function(ScaleStartDetails details, bool doubleTap)? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;

  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onDoubleTap;

  final MagnifierDoubleTapPredicate? allowDoubleTap;
  final HitTestBehavior? behavior;
  final Widget? child;

  const MagnifierGestureDetector({
    super.key,
    required this.hitDetector,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onTapDown,
    this.onTapUp,
    this.onDoubleTap,
    this.allowDoubleTap,
    this.behavior,
    this.child,
  });

  @override
  State<MagnifierGestureDetector> createState() => _MagnifierGestureDetectorState();
}

class _MagnifierGestureDetectorState extends State<MagnifierGestureDetector> {
  final ValueNotifier<TapDownDetails?> doubleTapDetails = ValueNotifier(null);

  @override
  void dispose() {
    doubleTapDetails.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestureSettings = MediaQuery.gestureSettingsOf(context);
    final gestures = <Type, GestureRecognizerFactory>{};

    if (widget.onTapDown != null || widget.onTapUp != null) {
      gestures[TapGestureRecognizer] = GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(debugOwner: this),
        (instance) {
          instance
            ..onTapDown = widget.onTapDown
            ..onTapUp = widget.onTapUp;
        },
      );
    }

    final scope = MagnifierGestureDetectorScope.maybeOf(context);
    if (scope != null) {
      gestures[MagnifierGestureRecognizer] = GestureRecognizerFactoryWithHandlers<MagnifierGestureRecognizer>(
        () => MagnifierGestureRecognizer(
          debugOwner: this,
          scope: scope,
          doubleTapDetails: doubleTapDetails,
        ),
        (instance) {
          instance
            ..hitDetector = widget.hitDetector
            ..onStart = widget.onScaleStart != null ? (details) => widget.onScaleStart!(details, doubleTapDetails.value != null) : null
            ..onUpdate = widget.onScaleUpdate
            ..onEnd = widget.onScaleEnd
            ..gestureSettings = gestureSettings;
        },
      );
    }

    gestures[MagnifierDoubleTapGestureRecognizer] = GestureRecognizerFactoryWithHandlers<MagnifierDoubleTapGestureRecognizer>(
      () => MagnifierDoubleTapGestureRecognizer(
        debugOwner: this,
        allowDoubleTap: widget.allowDoubleTap ?? (_) => true,
      ),
      (instance) {
        final onDoubleTap = widget.onDoubleTap;
        instance
          ..onDoubleTapCancel = _onDoubleTapCancel
          ..onDoubleTapDown = _onDoubleTapDown
          ..onDoubleTap = onDoubleTap != null
              ? () {
                  final details = doubleTapDetails.value;
                  if (details != null) {
                    onDoubleTap(details);
                    doubleTapDetails.value = null;
                  }
                }
              : null;
      },
    );

    return RawGestureDetector(
      gestures: gestures,
      behavior: widget.behavior ?? HitTestBehavior.translucent,
      child: widget.child,
    );
  }

  void _onDoubleTapCancel() => doubleTapDetails.value = null;

  void _onDoubleTapDown(TapDownDetails details) {
    if (widget.allowDoubleTap?.call(details.localPosition) ?? true) {
      doubleTapDetails.value = details;
    }
  }
}

class MagnifierDoubleTapGestureRecognizer extends DoubleTapGestureRecognizer {
  final MagnifierDoubleTapPredicate allowDoubleTap;

  MagnifierDoubleTapGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    required this.allowDoubleTap,
  });

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!allowDoubleTap(event.localPosition)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }
}
