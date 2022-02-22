import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

final Covers covers = Covers._private();

class Covers with ChangeNotifier {
  Set<CoverRow> _rows = {};

  Covers._private();

  Future<void> init() async {
    _rows = await metadataDb.loadAllCovers();
  }

  int get count => _rows.length;

  Set<CoverRow> get all => Set.unmodifiable(_rows);

  int? coverEntryId(CollectionFilter filter) => _rows.firstWhereOrNull((row) => row.filter == filter)?.entryId;

  Future<void> set(CollectionFilter filter, int? entryId) async {
    // erase contextual properties from filters before saving them
    if (filter is AlbumFilter) {
      filter = AlbumFilter(filter.album, null);
    }

    _rows.removeWhere((row) => row.filter == filter);
    if (entryId == null) {
      await metadataDb.removeCovers({filter});
    } else {
      final row = CoverRow(filter: filter, entryId: entryId);
      _rows.add(row);
      await metadataDb.addCovers({row});
    }

    notifyListeners();
  }

  Future<void> moveEntry(AvesEntry entry, {required bool persist}) async {
    final entryId = entry.id;
    final rows = _rows.where((row) => row.entryId == entryId).toSet();
    for (final row in rows) {
      final filter = row.filter;
      if (!filter.test(entry)) {
        _rows.remove(row);
        if (persist) {
          await metadataDb.removeCovers({filter});
        }
      }
    }

    notifyListeners();
  }

  Future<void> removeEntries(Set<AvesEntry> entries) => removeIds(entries.map((entry) => entry.id).toSet());

  Future<void> removeIds(Set<int> entryIds) async {
    final removedRows = _rows.where((row) => entryIds.contains(row.entryId)).toSet();

    await metadataDb.removeCovers(removedRows.map((row) => row.filter).toSet());
    _rows.removeAll(removedRows);

    notifyListeners();
  }

  Future<void> clear() async {
    await metadataDb.clearCovers();
    _rows.clear();

    notifyListeners();
  }

  // import/export

  List<Map<String, dynamic>>? export(CollectionSource source) {
    final visibleEntries = source.visibleEntries;
    final jsonList = covers.all
        .map((row) {
          final entryId = row.entryId;
          final path = visibleEntries.firstWhereOrNull((entry) => entryId == entry.id)?.path;
          if (path == null) return null;

          final volume = androidFileUtils.getStorageVolume(path)?.path;
          if (volume == null) return null;

          final relativePath = path.substring(volume.length);
          return {
            'filter': row.filter.toJson(),
            'volume': volume,
            'relativePath': relativePath,
          };
        })
        .whereNotNull()
        .toList();
    return jsonList.isNotEmpty ? jsonList : null;
  }

  void import(dynamic jsonList, CollectionSource source) {
    if (jsonList is! List) {
      debugPrint('failed to import covers for jsonMap=$jsonList');
      return;
    }

    final visibleEntries = source.visibleEntries;
    jsonList.forEach((row) {
      final filter = CollectionFilter.fromJson(row['filter']);
      if (filter == null) {
        debugPrint('failed to import cover for row=$row');
        return;
      }

      final volume = row['volume'];
      final relativePath = row['relativePath'];
      if (volume is String && relativePath is String) {
        final path = pContext.join(volume, relativePath);
        final entry = visibleEntries.firstWhereOrNull((entry) => entry.path == path && filter.test(entry));
        if (entry != null) {
          covers.set(filter, entry.id);
        } else {
          debugPrint('failed to import cover for path=$path, filter=$filter');
        }
      } else {
        debugPrint('failed to import cover for volume=$volume, relativePath=$relativePath, filter=$filter');
      }
    });
  }
}

@immutable
class CoverRow extends Equatable {
  final CollectionFilter filter;
  final int entryId;

  @override
  List<Object?> get props => [filter, entryId];

  const CoverRow({
    required this.filter,
    required this.entryId,
  });

  static CoverRow? fromMap(Map map) {
    final filter = CollectionFilter.fromJson(map['filter']);
    if (filter == null) return null;
    return CoverRow(
      filter: filter,
      entryId: map['entryId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'filter': filter.toJson(),
        'entryId': entryId,
      };
}
