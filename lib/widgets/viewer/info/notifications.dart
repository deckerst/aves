import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:flutter/widgets.dart';

class ShowImageNotification extends Notification {}

class ShowInfoNotification extends Notification {}

class FilterSelectedNotification extends Notification {
  final CollectionFilter filter;

  const FilterSelectedNotification(this.filter);
}

class EntryDeletedNotification extends Notification {
  final AvesEntry entry;

  const EntryDeletedNotification(this.entry);
}
