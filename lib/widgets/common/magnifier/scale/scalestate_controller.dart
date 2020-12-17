import 'dart:async';

import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:aves/widgets/common/magnifier/scale/state.dart';
import 'package:flutter/rendering.dart';

typedef ScaleStateListener = void Function(double prevScale, double nextScale);

class MagnifierScaleStateController {
  ScaleStateChange _scaleState;
  StreamController<ScaleStateChange> _outputScaleStateCtrl;
  ScaleStateChange prevScaleState;

  Stream<ScaleStateChange> get scaleStateChangeStream => _outputScaleStateCtrl.stream;

  ScaleStateChange get scaleState => _scaleState;

  bool get hasChanged => prevScaleState != scaleState;

  bool get isZooming => scaleState.state == ScaleState.zoomedIn || scaleState.state == ScaleState.zoomedOut;

  MagnifierScaleStateController() {
    _scaleState = ScaleStateChange(state: ScaleState.initial, source: ChangeSource.internal);
    prevScaleState = _scaleState;

    _outputScaleStateCtrl = StreamController<ScaleStateChange>.broadcast();
    _outputScaleStateCtrl.sink.add(_scaleState);
  }

  void dispose() {
    _outputScaleStateCtrl.close();
  }

  void setScaleState(ScaleState newValue, ChangeSource source, {Offset childFocalPoint}) {
    if (_scaleState.state == newValue) return;

    prevScaleState = _scaleState;
    _scaleState = ScaleStateChange(state: newValue, source: source, childFocalPoint: childFocalPoint);
    _outputScaleStateCtrl.sink.add(scaleState);
  }
}
