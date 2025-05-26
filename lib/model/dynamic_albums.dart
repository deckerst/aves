import 'dart:async';

import 'package:aves/model/filters/container/container.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/group_base.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

final DynamicAlbums dynamicAlbums = DynamicAlbums._private();

class DynamicAlbums with ChangeNotifier {
  final Set<StreamSubscription> _subscriptions = {};
  final _lock = Lock();
  Set<DynamicAlbumFilter> _rows = {};

  final EventBus eventBus = EventBus();

  DynamicAlbums._private() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
    _subscriptions.add(albumGrouping.eventBus.on<GroupUriChangedEvent>().listen((e) => _onGroupUriChanged(e.oldGroupUri, e.newGroupUri)));
  }

  Future<void> init() async {
    _rows = (await localMediaDb.loadAllDynamicAlbums()).map((v) => DynamicAlbumFilter(v.name, v.filter)).toSet();
  }

  int get count => _rows.length;

  Set<DynamicAlbumFilter> get all => Set.unmodifiable(_rows);

  Future<void> _doAdd(Set<DynamicAlbumFilter>? filters) async {
    if (filters == null || filters.isEmpty) return;
    await localMediaDb.addDynamicAlbums(filters.map((v) => DynamicAlbumRow(name: v.name, filter: v.filter)).toSet());
    _rows.addAll(filters);
  }

  Future<void> _doRemove(Set<String>? names) async {
    if (names == null || names.isEmpty) return;
    await localMediaDb.removeDynamicAlbums(names);
    _rows.removeWhere((v) => names.contains(v.name));
  }

  Future<void> add(DynamicAlbumFilter filter) async {
    await _lock.synchronized(() async {
      await _doAdd({filter});
      notifyListeners();
    });
  }

  Future<void> remove(Set<DynamicAlbumFilter> filters) async {
    await _lock.synchronized(() async {
      await _doRemove(filters.map((filter) => filter.name).toSet());
      notifyListeners();
    });
  }

  Future<void> rename(DynamicAlbumFilter oldFilter, String newName) async {
    await _lock.synchronized(() async {
      final newFilter = DynamicAlbumFilter(newName, oldFilter.filter);
      await _doRemove({oldFilter.name});
      await _doAdd({newFilter});
      notifyListeners();
      eventBus.fire(DynamicAlbumChangedEvent({oldFilter: newFilter}));
    });
  }

  Future<void> update(Map<DynamicAlbumFilter, DynamicAlbumFilter?> changes) async {
    await _lock.synchronized(() async {
      final oldFilterNames = changes.keys.map((v) => v.name).toSet();
      final newFilters = changes.values.nonNulls.toSet();
      await _doRemove(oldFilterNames);
      await _doAdd(newFilters);
      notifyListeners();
      eventBus.fire(DynamicAlbumChangedEvent(changes));
    });
  }

  Future<void> clear() async {
    await _lock.synchronized(() async {
      await localMediaDb.clearDynamicAlbums();
      _rows.clear();
      notifyListeners();
    });
  }

  DynamicAlbumFilter? get(String name) => _rows.firstWhereOrNull((row) => row.name == name);

  bool contains(String? name) => name != null && get(name) != null;

  Future<void> _onGroupUriChanged(Uri oldGroupUri, Uri newGroupUri) async {
    bool isOldGroupFilter(CollectionFilter filter) => filter is GroupBaseFilter && filter.uri == oldGroupUri;
    final oldDynamicAlbumFilters = _rows.where((v) => v.containsFilter(isOldGroupFilter)).toSet();
    if (oldDynamicAlbumFilters.isEmpty) return;

    final grouping = FilterGrouping.forUri(oldGroupUri);
    final newGroupFilter = grouping?.uriToFilter(newGroupUri);
    CollectionFilter? transformer(v) {
      if (isOldGroupFilter(v)) return v.reversed ? newGroupFilter?.reverse() : newGroupFilter;
      if (v is ContainerFilter) return v.replaceFilters(transformer);
      return v;
    }

    final newFilters = <DynamicAlbumFilter, DynamicAlbumFilter?>{};
    oldDynamicAlbumFilters.forEach((oldFilter) {
      final newFilter = oldFilter.replaceFilters(transformer);
      newFilters[oldFilter] = newFilter;
    });
    await update(newFilters);
  }

  // import/export

  List<String>? export() {
    final jsonList = all.map((row) => row.toJson()).toList();
    return jsonList.isNotEmpty ? jsonList : null;
  }

  void import(dynamic jsonList) {
    if (jsonList is! List) {
      debugPrint('failed to import dynamic albums for jsonMap=$jsonList');
      return;
    }

    jsonList.forEach((row) {
      final filter = CollectionFilter.fromJson(row);
      if (filter == null || filter is! DynamicAlbumFilter) {
        debugPrint('failed to import dynamic album for row=$row');
        return;
      }

      add(filter);
    });
  }
}

@immutable
class DynamicAlbumRow extends Equatable {
  final String name;
  final CollectionFilter filter;

  @override
  List<Object?> get props => [name, filter];

  const DynamicAlbumRow({
    required this.name,
    required this.filter,
  });

  static DynamicAlbumRow? fromMap(Map map) {
    final filter = CollectionFilter.fromJson(map['filter']);
    if (filter == null) return null;

    return DynamicAlbumRow(
      name: map['name'] as String,
      filter: filter,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'filter': filter.toJson(),
      };
}

@immutable
class DynamicAlbumChangedEvent {
  final Map<DynamicAlbumFilter, DynamicAlbumFilter?> changes;

  const DynamicAlbumChangedEvent(this.changes);
}
