import 'dart:ui';

import 'package:aves/widgets/common/magnifier/controller/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class ScaleStateChange {
  const ScaleStateChange({
    @required this.state,
    @required this.source,
    this.childFocalPoint,
  });

  final ScaleState state;
  final ChangeSource source;
  final Offset childFocalPoint;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScaleStateChange && runtimeType == other.runtimeType && state == other.state && childFocalPoint == other.childFocalPoint;

  @override
  int get hashCode => hashValues(state, source, childFocalPoint);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{scaleState: $state, source: $source, childFocalPoint: $childFocalPoint}';
}

enum ScaleState {
  initial,
  covering,
  originalSize,
  zoomedIn,
  zoomedOut,
}

ScaleState defaultScaleStateCycle(ScaleState actual) {
  switch (actual) {
    case ScaleState.initial:
      return ScaleState.covering;
    case ScaleState.covering:
      return ScaleState.originalSize;
    case ScaleState.originalSize:
      return ScaleState.initial;
    case ScaleState.zoomedIn:
    case ScaleState.zoomedOut:
      return ScaleState.initial;
    default:
      return ScaleState.initial;
  }
}

typedef ScaleStateCycle = ScaleState Function(ScaleState actual);
