import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class MarkerKey<T> extends LocalKey with Equatable {
  final T entry;
  final int? count;

  @override
  List<Object?> get props => [entry, count];

  const new(this.entry, this.count);
}
