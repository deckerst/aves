import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class ShowImageNotification extends Notification {}

@immutable
class ShowInfoPageNotification extends Notification {}

@immutable
class TvShowLessInfoNotification extends Notification {}

@immutable
class TvShowMoreInfoNotification extends Notification {}

@immutable
class ToggleOverlayNotification extends Notification {
  final bool? visible;

  const ToggleOverlayNotification({this.visible});
}

@immutable
class JumpToPreviousEntryNotification extends Notification {}

@immutable
class JumpToNextEntryNotification extends Notification {}

@immutable
class JumpToEntryNotification extends Notification {
  final int index;

  const JumpToEntryNotification({required this.index});
}

@immutable
class VideoActionNotification extends Notification {
  final AvesVideoController controller;
  final EntryAction action;

  const VideoActionNotification({
    required this.controller,
    required this.action,
  });
}

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
