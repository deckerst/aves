import 'package:aves_magnifier/src/controller/state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class const ScaleStateChange({
  required final ScaleState state,
  required final ChangeSource source,
  final Offset? childFocalPoint,
}) extends Equatable {
  @override
  List<Object?> get props => [state, source, childFocalPoint];
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
    case .initial:
      return ScaleState.covering;
    case .covering:
      return ScaleState.originalSize;
    case .originalSize:
    case .zoomedIn:
    case .zoomedOut:
      return ScaleState.initial;
  }
}

typedef ScaleStateCycle = ScaleState Function(ScaleState actual);
