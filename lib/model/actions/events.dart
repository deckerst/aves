import 'package:flutter/foundation.dart';

@immutable
class ActionEvent<T> {
  final T action;

  const ActionEvent(this.action);
}

@immutable
class ActionStartedEvent<T> extends ActionEvent<T> {
  const ActionStartedEvent(T action) : super(action);
}

@immutable
class ActionEndedEvent<T> extends ActionEvent<T> {
  const ActionEndedEvent(T action) : super(action);
}
