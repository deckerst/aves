import 'package:aves/widgets/common/magnifier/core/scale_gesture_recognizer.dart';
import 'package:aves/widgets/common/magnifier/pan/gesture_detector_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../pan/corner_hit_detector.dart';

class MagnifierGestureDetector extends StatefulWidget {
  const MagnifierGestureDetector({
    Key key,
    this.hitDetector,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onTapDown,
    this.onTapUp,
    this.onDoubleTap,
    this.behavior,
    this.child,
  }) : super(key: key);

  final CornerHitDetector hitDetector;
  final void Function(ScaleStartDetails details, bool doubleTap) onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;

  final GestureTapDownCallback onTapDown;
  final GestureTapUpCallback onTapUp;
  final GestureTapDownCallback onDoubleTap;

  final HitTestBehavior behavior;
  final Widget child;

  @override
  _MagnifierGestureDetectorState createState() => _MagnifierGestureDetectorState();
}

class _MagnifierGestureDetectorState extends State<MagnifierGestureDetector> {
  final ValueNotifier<TapDownDetails> doubleTapDetails = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final scope = MagnifierGestureDetectorScope.of(context);

    final axis = scope?.axis;
    final touchSlopFactor = scope?.touchSlopFactor;

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

    gestures[MagnifierGestureRecognizer] = GestureRecognizerFactoryWithHandlers<MagnifierGestureRecognizer>(
      () => MagnifierGestureRecognizer(
        hitDetector: widget.hitDetector,
        debugOwner: this,
        validateAxis: axis,
        touchSlopFactor: touchSlopFactor,
        doubleTapDetails: doubleTapDetails,
      ),
      (instance) {
        instance.onStart = (details) => widget.onScaleStart(details, doubleTapDetails.value != null);
        instance.onUpdate = widget.onScaleUpdate;
        instance.onEnd = widget.onScaleEnd;
      },
    );

    gestures[DoubleTapGestureRecognizer] = GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
      () => DoubleTapGestureRecognizer(debugOwner: this),
      (instance) {
        instance.onDoubleTapCancel = () => doubleTapDetails.value = null;
        instance.onDoubleTapDown = (details) => doubleTapDetails.value = details;
        instance.onDoubleTap = () {
          widget.onDoubleTap(doubleTapDetails.value);
          doubleTapDetails.value = null;
        };
      },
    );

    return RawGestureDetector(
      gestures: gestures,
      behavior: widget.behavior ?? HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
