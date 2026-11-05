import 'package:aves/model/entry/entry.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class const EntryAddedEvent([final Set<AvesEntry>? entries]);

@immutable
class const EntryRemovedEvent(final Set<AvesEntry> entries);

@immutable
class const EntryMovedEvent(final MoveType type, final Set<AvesEntry> entries);

@immutable
class const EntryRefreshedEvent(final Set<AvesEntry> entries);

@immutable
class const EntryDisposedEvent(final Set<AvesEntry> entries);

@immutable
class const FilterVisibilityChangedEvent();

@immutable
class const ProgressEvent({required final int done, required final int total});
