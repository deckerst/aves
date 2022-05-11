import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class ShowImageNotification extends Notification {}

@immutable
class ShowInfoNotification extends Notification {}

@immutable
class FilterSelectedNotification extends Notification with EquatableMixin {
  final CollectionFilter filter;

  @override
  List<Object?> get props => [filter];

  const FilterSelectedNotification(this.filter);
}

@immutable
class EntryDeletedNotification extends Notification with EquatableMixin {
  final Set<AvesEntry> entries;

  @override
  List<Object?> get props => [entries];

  const EntryDeletedNotification(this.entries);
}

@immutable
class EntryMovedNotification extends Notification with EquatableMixin {
  final MoveType moveType;
  final Set<AvesEntry> entries;

  @override
  List<Object?> get props => [moveType, entries];

  const EntryMovedNotification(this.moveType, this.entries);
}
