import 'package:aves/model/entry/entry.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class EntryAddedEvent {
  final Set<AvesEntry>? entries;

  const new([this.entries]);
}

@immutable
class EntryRemovedEvent {
  final Set<AvesEntry> entries;

  const new(this.entries);
}

@immutable
class EntryMovedEvent {
  final MoveType type;
  final Set<AvesEntry> entries;

  const new(this.type, this.entries);
}

@immutable
class EntryRefreshedEvent {
  final Set<AvesEntry> entries;

  const new(this.entries);
}

@immutable
class FilterVisibilityChangedEvent {
  const new();
}

@immutable
class ProgressEvent {
  final int done, total;

  const new({required this.done, required this.total});
}
