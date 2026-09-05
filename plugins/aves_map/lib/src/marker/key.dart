import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class const MarkerKey<T>(
  final T entry,
  final int? count,
) extends LocalKey with Equatable {
  @override
  List<Object?> get props => [entry, count];
}
