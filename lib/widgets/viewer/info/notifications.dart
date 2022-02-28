import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:flutter/widgets.dart';

@immutable
class ShowImageNotification extends Notification {}

@immutable
class ShowInfoNotification extends Notification {}

@immutable
class FilterSelectedNotification extends Notification {
  final CollectionFilter filter;

  const FilterSelectedNotification(this.filter);
}

// deleted or moved to another album
@immutable
class EntryRemovedNotification extends Notification {
  final AvesEntry entry;

  const EntryRemovedNotification(this.entry);
}
