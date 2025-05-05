import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

final DynamicAlbums dynamicAlbums = DynamicAlbums._private();

class DynamicAlbums with ChangeNotifier {
  Set<DynamicAlbumFilter> _rows = {};

  DynamicAlbums._private() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  Future<void> init() async {
    _rows = (await localMediaDb.loadAllDynamicAlbums()).map((v) => DynamicAlbumFilter(v.name, v.filter)).toSet();
  }

  int get count => _rows.length;

  Set<DynamicAlbumFilter> get all => Set.unmodifiable(_rows);

  Future<void> add(DynamicAlbumFilter filter) async {
    await localMediaDb.addDynamicAlbums({DynamicAlbumRow(name: filter.name, filter: filter.filter)});
    _rows.add(filter);

    notifyListeners();
  }

  Future<void> remove(Set<DynamicAlbumFilter> filters) async {
    await localMediaDb.removeDynamicAlbums(filters.map((filter) => filter.name).toSet());
    _rows.removeAll(filters);

    notifyListeners();
  }

  Future<void> clear() async {
    await localMediaDb.clearDynamicAlbums();
    _rows.clear();

    notifyListeners();
  }

  Future<void> rename(DynamicAlbumFilter filter, String newName) async {
    await localMediaDb.removeDynamicAlbums({filter.name});
    _rows.remove(filter);

    await add(DynamicAlbumFilter(newName, filter.filter));
  }

  DynamicAlbumFilter? get(String name) => _rows.firstWhereOrNull((row) => row.name == name);

  bool contains(String? name) => name != null && get(name) != null;

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
