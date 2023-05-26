import 'package:aves_magnifier/src/controller/state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class ScaleStateChange extends Equatable {
  final ScaleState state;
  final ChangeSource source;
  final Offset? childFocalPoint;

  @override
  List<Object?> get props => [state, source, childFocalPoint];

  const ScaleStateChange({
    required this.state,
    required this.source,
    this.childFocalPoint,
  });
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
    case ScaleState.zoomedIn:
    case ScaleState.zoomedOut:
      return ScaleState.initial;
  }
}

typedef ScaleStateCycle = ScaleState Function(ScaleState actual);
