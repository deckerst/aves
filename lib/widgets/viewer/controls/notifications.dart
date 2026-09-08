import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class EquatableNotification extends Notification with Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

@immutable
class LockViewNotification extends EquatableNotification {
  final bool locked;

  @override
  List<Object?> get props => [locked];

  const new({required this.locked});
}

@immutable
class PopVisualNotification extends EquatableNotification;

@immutable
class ShowImageNotification extends EquatableNotification;

@immutable
class ShowInfoPageNotification extends EquatableNotification;

@immutable
class ShowPreviousEntryNotification extends EquatableNotification {
  final bool animate;

  @override
  List<Object?> get props => [animate];

  const new({required this.animate});
}

@immutable
class ShowNextEntryNotification extends EquatableNotification {
  final bool animate;

  @override
  List<Object?> get props => [animate];

  const new({required this.animate});
}

@immutable
class ShowEntryNotification extends EquatableNotification {
  final bool animate;
  final int index;

  @override
  List<Object?> get props => [animate, index];

  const new({
    required this.animate,
    required this.index,
  });
}

@immutable
class ShowPreviousVideoNotification extends EquatableNotification;

@immutable
class ShowNextVideoNotification extends EquatableNotification;

@immutable
class ToggleOverlayNotification extends EquatableNotification {
  final bool? visible;

  @override
  List<Object?> get props => [visible];

  const new({this.visible});
}

@immutable
class TvShowLessInfoNotification extends EquatableNotification;

@immutable
class TvShowMoreInfoNotification extends EquatableNotification;

@immutable
class VideoActionNotification extends EquatableNotification {
  final AvesVideoController controller;
  final AvesEntry entry;
  final EntryAction action;

  @override
  List<Object?> get props => [controller, entry, action];

  const new({
    required this.controller,
    required this.entry,
    required this.action,
  });
}

@immutable
class CastNotification extends EquatableNotification {
  final bool enabled;

  @override
  List<Object?> get props => [enabled];

  const new(this.enabled);
}

@immutable
class SelectFilterNotification extends EquatableNotification {
  final CollectionFilter filter;

  @override
  List<Object?> get props => [filter];

  const new(this.filter);
}

@immutable
class DecomposeFilterNotification extends EquatableNotification {
  final CollectionFilter filter;

  @override
  List<Object?> get props => [filter];

  const new(this.filter);
}

@immutable
class EntryDeletedNotification extends EquatableNotification {
  final Set<AvesEntry> entries;

  @override
  List<Object?> get props => [entries];

  const new(this.entries);
}

@immutable
class EntryMovedNotification extends EquatableNotification {
  final MoveType moveType;
  final Set<AvesEntry> entries;

  @override
  List<Object?> get props => [moveType, entries];

  const new(this.moveType, this.entries);
}

@immutable
class FullImageLoadedNotification extends EquatableNotification {
  final AvesEntry entry;
  final ImageProvider image;

  @override
  List<Object?> get props => [entry, image];

  const new(this.entry, this.image);
}

@immutable
class PopupMenuOpenedNotification extends EquatableNotification;
