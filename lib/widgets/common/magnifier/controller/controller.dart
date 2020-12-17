import 'dart:async';
import 'dart:ui';

import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:flutter/widgets.dart';

class MagnifierController {
  MagnifierController({
    Offset initialPosition = Offset.zero,
  })  : _valueNotifier = ValueNotifier(
          MagnifierState(
            position: initialPosition,
            scale: null,
            source: ChangeSource.internal,
          ),
        ),
        super() {
    initial = value;
    prevValue = initial;

    _valueNotifier.addListener(_changeListener);
    _outputCtrl = StreamController<MagnifierState>.broadcast();
    _outputCtrl.sink.add(initial);
  }

  final ValueNotifier<MagnifierState> _valueNotifier;

  MagnifierState initial;

  StreamController<MagnifierState> _outputCtrl;

  /// The output for state/value updates. Usually a broadcast [Stream]
  Stream<MagnifierState> get outputStateStream => _outputCtrl.stream;

  /// The state value before the last change or the initial state if the state has not been changed.
  MagnifierState prevValue;

  /// Resets the state to the initial value;
  void reset() {
    _setValue(initial);
  }

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }

  /// Closes streams and removes eventual listeners.
  void dispose() {
    _outputCtrl.close();
    _valueNotifier.dispose();
  }

  void setPosition(Offset position, ChangeSource source) {
    if (value.position == position) return;

    prevValue = value;
    _setValue(MagnifierState(
      position: position,
      scale: scale,
      source: source,
    ));
  }

  /// The position of the image in the screen given its offset after pan gestures.
  Offset get position => value.position;

  void setScale(double scale, ChangeSource source) {
    if (value.scale == scale) return;

    prevValue = value;
    _setValue(MagnifierState(
      position: position,
      scale: scale,
      source: source,
    ));
  }

  /// The scale factor to transform the child (image or a customChild).
  double get scale => value.scale;

  /// Update multiple fields of the state with only one update streamed.
  void updateMultiple({
    Offset position,
    double scale,
    @required ChangeSource source,
  }) {
    prevValue = value;
    _setValue(MagnifierState(
      position: position ?? value.position,
      scale: scale ?? value.scale,
      source: source,
    ));
  }

  /// The actual state value
  MagnifierState get value => _valueNotifier.value;

  void _setValue(MagnifierState newValue) {
    if (_valueNotifier.value == newValue) return;
    _valueNotifier.value = newValue;
  }
}
