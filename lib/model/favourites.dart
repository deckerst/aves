import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

final Favourites favourites = Favourites._private();

class Favourites with ChangeNotifier {
  Set<FavouriteRow> _rows = {};

  Favourites._private() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  Future<void> init() async {
    _rows = await localMediaDb.loadAllFavourites();
  }

  int get count => _rows.length;

  Set<int> get all => Set.unmodifiable(_rows.map((v) => v.entryId));

  bool isFavourite(AvesEntry entry) => _rows.any((row) => row.entryId == entry.id);

  FavouriteRow _entryToRow(AvesEntry entry) => FavouriteRow(entryId: entry.id);

  Future<void> add(Set<AvesEntry> entries) async {
    final newRows = entries.map(_entryToRow).toSet();

    await localMediaDb.addFavourites(newRows);
    _rows.addAll(newRows);

    notifyListeners();
  }

  Future<void> removeEntries(Set<AvesEntry> entries) => removeIds(entries.map((entry) => entry.id).toSet());

  Future<void> removeIds(Set<int> entryIds) async {
    final removedRows = _rows.where((row) => entryIds.contains(row.entryId)).toSet();

    await localMediaDb.removeFavourites(removedRows);
    removedRows.forEach(_rows.remove);

    notifyListeners();
  }

  Future<void> clear() async {
    await localMediaDb.clearFavourites();
    _rows.clear();

    notifyListeners();
  }

  // import/export

  Map<String, List<String>>? export(CollectionSource source) {
    final visibleEntries = source.visibleEntries;
    final ids = favourites.all;
    final paths = visibleEntries.where((entry) => ids.contains(entry.id)).map((entry) => entry.path).nonNulls.toSet();
    final byVolume = groupBy<String, StorageVolume?>(paths, androidFileUtils.getStorageVolume);
    final jsonMap = Map.fromEntries(byVolume.entries.map((kv) {
      final volume = kv.key?.path;
      if (volume == null) return null;
      final rootLength = volume.length;
      final relativePaths = kv.value.map((v) => v.substring(rootLength)).toList();
      return MapEntry(volume, relativePaths);
    }).nonNulls);
    return jsonMap.isNotEmpty ? jsonMap : null;
  }

  void import(dynamic jsonMap, CollectionSource source) {
    if (jsonMap is! Map) {
      debugPrint('failed to import favourites for jsonMap=$jsonMap');
      return;
    }

    final visibleEntries = source.visibleEntries;
    final foundEntries = <AvesEntry>{};
    final missedPaths = <String>{};
    jsonMap.forEach((volume, relativePaths) {
      if (volume is String && relativePaths is List) {
        relativePaths.forEach((relativePath) {
          final path = pContext.join(volume, relativePath);
          final entry = visibleEntries.firstWhereOrNull((entry) => entry.path == path);
          if (entry != null) {
            foundEntries.add(entry);
          } else {
            missedPaths.add(path);
          }
        });
      } else {
        debugPrint('failed to import favourites for volume=$volume, relativePaths=${relativePaths.runtimeType}');
      }

      if (foundEntries.isNotEmpty) {
        favourites.add(foundEntries);
      }
      if (missedPaths.isNotEmpty) {
        debugPrint('failed to import favourites with ${missedPaths.length} missed paths');
      }
    });
  }
}

@immutable
class FavouriteRow extends Equatable {
  final int entryId;

  @override
  List<Object?> get props => [entryId];

  const FavouriteRow({
    required this.entryId,
  });

  factory FavouriteRow.fromMap(Map map) {
    return FavouriteRow(
      entryId: map['id'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': entryId,
      };
}
