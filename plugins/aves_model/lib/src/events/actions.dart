import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ActionEvent<T> extends Equatable {
  final T action;

  @override
  List<Object?> get props => [action];

  const ActionEvent(this.action);
}

@immutable
class ActionStartedEvent<T> extends ActionEvent<T> {
  const ActionStartedEvent(super.action);
}

@immutable
class ActionEndedEvent<T> extends ActionEvent<T> {
  const ActionEndedEvent(super.action);
}
