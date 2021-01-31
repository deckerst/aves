import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackUpNotification extends Notification {}

class FilterNotification extends Notification {
  final CollectionFilter filter;

  const FilterNotification(this.filter);
}

class EntryDeletedNotification extends Notification {
  final AvesEntry entry;

  const EntryDeletedNotification(this.entry);
}

class OpenTempEntryNotification extends Notification {
  final AvesEntry entry;

  const OpenTempEntryNotification({
    @required this.entry,
  });

  @override
  String toString() => '$runtimeType#${shortHash(this)}{entry=$entry}';
}
