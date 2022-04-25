import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class MarkerKey<T> extends LocalKey with EquatableMixin {
  final T entry;
  final int? count;

  @override
  List<Object?> get props => [entry, count];

  const MarkerKey(this.entry, this.count);
}
