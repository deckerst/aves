import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class const EquatableNotification() extends Notification with Equatable {
  @override
  List<Object?> get props => [];
}

@immutable
class const LockViewNotification({required final bool locked}) extends EquatableNotification {
  @override
  List<Object?> get props => [locked];
}

@immutable
class PopVisualNotification extends EquatableNotification;

@immutable
class ShowImageNotification extends EquatableNotification;

@immutable
class ShowInfoPageNotification extends EquatableNotification;

@immutable
class const ShowPreviousEntryNotification({required final bool animate}) extends EquatableNotification {
  @override
  List<Object?> get props => [animate];
}

@immutable
class const ShowNextEntryNotification({required final bool animate}) extends EquatableNotification {
  @override
  List<Object?> get props => [animate];
}

@immutable
class const ShowEntryNotification({
  required final bool animate,
  required final int index,
}) extends EquatableNotification {
  @override
  List<Object?> get props => [animate, index];
}

@immutable
class ShowPreviousVideoNotification extends EquatableNotification;

@immutable
class ShowNextVideoNotification extends EquatableNotification;

@immutable
class const ToggleOverlayNotification({final bool? visible}) extends EquatableNotification {
  @override
  List<Object?> get props => [visible];
}

@immutable
class TvShowLessInfoNotification extends EquatableNotification;

@immutable
class TvShowMoreInfoNotification extends EquatableNotification;

@immutable
class const VideoActionNotification({
  required final AvesVideoController controller,
  required final AvesEntry entry,
  required final EntryAction action,
}) extends EquatableNotification {
  @override
  List<Object?> get props => [controller, entry, action];
}

@immutable
class const CastNotification(final bool enabled) extends EquatableNotification {
  @override
  List<Object?> get props => [enabled];
}

@immutable
class const SelectFilterNotification(final CollectionFilter filter) extends EquatableNotification {
  @override
  List<Object?> get props => [filter];
}

@immutable
class const DecomposeFilterNotification(final CollectionFilter filter) extends EquatableNotification {
  @override
  List<Object?> get props => [filter];
}

@immutable
class const EntryDeletedNotification(final Set<AvesEntry> entries) extends EquatableNotification {
  @override
  List<Object?> get props => [entries];
}

@immutable
class const EntryMovedNotification(final MoveType moveType, final Set<AvesEntry> entries) extends EquatableNotification {
  @override
  List<Object?> get props => [moveType, entries];
}

@immutable
class const FullImageLoadedNotification(final AvesEntry entry, final ImageProvider image) extends EquatableNotification {
  @override
  List<Object?> get props => [entry, image];
}

@immutable
class PopupMenuOpenedNotification extends EquatableNotification;
