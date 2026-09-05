import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const ActionEvent<T>(final T action) extends Equatable {
  @override
  List<Object?> get props => [action];
}

@immutable
class const ActionStartedEvent<T>(super.action) extends ActionEvent<T>;

@immutable
class const ActionEndedEvent<T>(super.action) extends ActionEvent<T>;
