import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:flutter/foundation.dart';

@immutable
class EntryAddedEvent {
  final Set<AvesEntry>? entries;

  const EntryAddedEvent([this.entries]);
}

@immutable
class EntryRemovedEvent {
  final Set<AvesEntry> entries;

  const EntryRemovedEvent(this.entries);
}

@immutable
class EntryMovedEvent {
  final MoveType type;
  final Set<AvesEntry> entries;

  const EntryMovedEvent(this.type, this.entries);
}

@immutable
class EntryRefreshedEvent {
  final Set<AvesEntry> entries;

  const EntryRefreshedEvent(this.entries);
}

@immutable
class FilterVisibilityChangedEvent {
  final Set<CollectionFilter> filters;
  final bool visible;

  const FilterVisibilityChangedEvent(this.filters, this.visible);
}

@immutable
class ProgressEvent {
  final int done, total;

  const ProgressEvent({required this.done, required this.total});
}
